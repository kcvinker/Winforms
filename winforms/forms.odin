
package winforms

import "core:fmt"
import "base:runtime"
import "core:mem"
import "core:time"
import api "core:sys/windows"


// Some better window colors
/*
    0xF5FFFA
    0xF5F5F5
    0xF8F8F8
    0xF8F8FF
    0xF0FFF0
    0xEEEEE4
*/


menuTxtFlag :: DT_LEFT | DT_SINGLELINE | DT_VCENTER


Form :: struct
{
    using control : Control, 
    start_pos : StartPosition,
    style : FormStyle,
    minimizeBox, maximizeBox : bool,
    windowState : FormState,
    menubar : ^MenuBar,

    onLoad : EventHandler,
    onActivate,
    onDeActivate : EventHandler,
    onMoving, onMoved : EventHandler,
    onResizing,onResized : SizeEventHandler,

    onMinimized,
    onMaximized,
    onRestored,
    onClosing,
    onClosed : EventHandler,
    onThreadMsg: ThreadMsgHandler,

    _isLoaded : bool,
    _gdraw : FormGradient,
    _drawMode : FormDrawMode,
    _cDrawChilds : [dynamic]HWND,
    _uDrawChilds : map[UINT]HWND,
    _controls : [dynamic]^Control,
    _gdBrush: HBRUSH,
    _comboData : [dynamic]ComboData,
    _menuItemMap : map[uint]^MenuItem,
    _menubarUsed: bool,
    _timerMap: map[UINT_PTR]^Timer,
    _formID: int,

}

Timer :: struct {
	interval: u32,
	onTick: EventHandler,
	_parentHwnd: HWND,
    _idNum: UINT_PTR,
    _isEnabled: bool,
}




print_points :: proc(frm: ^Form) { frm.onMouseUp = print_point_func }

// Set the colors to draw a gradient background in form.
form_set_gradient :: proc(this: ^Form, clr1, clr2 : uint,top_bottom := true)
{
    this._gdraw.c1 = new_color(clr1)
    this._gdraw.c2 = new_color(clr2)
    this._gdraw.t2b = top_bottom
    this._drawMode = .Gradient
    this.backColor = clr1
    if this._isCreated do InvalidateRect(this.handle, nil, false)
}

/*=====================================================
This will display the window.
And it will check if the main loop is started or not.
If not started, it will start the main loop 
========================================================*/
start_mainloop :: proc(this: ^Form)
{
    create_child_handles(this)

    //app.mainLoopStarted = true
    ms : MSG
    for GetMessage(&ms, nil, 0, 0) != 0
    {
        TranslateMessage(&ms)
        DispatchMessage(&ms)
    }
    app_finalize(app)
}

form_show :: proc(f : Form) { ShowWindow(f.handle, SW_SHOW) }
form_hide :: proc(f : Form) { ShowWindow(f.handle, SW_HIDE) }
form_setstate :: proc(frm : Form, state : FormState) { ShowWindow(frm.handle, cast(i32) state ) }

/* Add a new timer control to form. Interval is in milliseconds */
form_addTimer :: proc(this: ^Form, interval: u32 = 100, tickHandler: EventHandler = nil) -> ^Timer
{
    tm := new(Timer)
    tm.interval = interval
    tm.onTick = tickHandler
    tm._parentHwnd = this.handle
    tm._idNum = cast(UINT_PTR)tm
    this._timerMap[tm._idNum] = tm
    return tm
}

timer_start :: proc(this: ^Timer)
{
    this._isEnabled = true
    SetTimer(this._parentHwnd, this._idNum, this.interval, nil)
}

timer_stop :: proc(this: ^Timer)
{
    KillTimer(this._parentHwnd, this._idNum)
    this._isEnabled = false
}

@private timer_dtor :: proc(this: ^Timer)
{
    if this._isEnabled do KillTimer(this._parentHwnd, this._idNum)
    free(this)
}


FormDrawMode :: enum { Default, Flat_Color, Gradient,}
//GradientStyle :: enum {Top_To_Bottom, Left_To_Right,}
StartPosition :: enum
{
    Top_Left,
    Top_Mid,
    Top_Right,
    Mid_Left,
    Center,
    Mid_Right,
    Bottom_Left,
    Bottom_Mid,
    Bottom_Right,
    Manual,
}

FormStyle :: enum { Default, Fixed_Single, Fixed_3D, Fixed_Dialog, Fixed_Tool, Sizable_Tool, }
FormState :: enum {Normal = 1, Minimized, Maximized}
FormGradient :: struct {c1, c2 : Color, t2b : bool, }

@private form_ctor :: proc( t : string = "", w : int = 500, h : int = 400 ) -> ^Form
{
    if app.formCount == 0 do global_context = context
    app.formCount += 1
    // app.curr_context = ctx
    // ptf("form context ui %d\n", context.user_index)
    f := new(Form, global_context.allocator)

    f.kind = .Form
    f.text = t == "" ? concat_number("Form_", app.formCount) : t
    f.width = w
    f.height = h
    f.start_pos = .Center
    f.style = .Default
    f.maximizeBox = true
    f.minimizeBox = true
    f.font = new_font()
    f._drawMode = .Default
    f.backColor = def_window_color
    f.foreColor = app.clrBlack
    f._formID = app.formCount
    f.windowState = .Normal
    f._uDrawChilds = make(map[UINT]HWND)

    return  f
}

@private new_form1 :: proc() -> ^Form { return form_ctor() }

@private new_form2 :: proc( txt : string, w : int = 500, h : int = 400) -> ^Form
{
    return form_ctor( txt, w, h)
}

new_form :: proc{new_form1, new_form2}

@private delete_childs :: proc(this: ^Form)
{
    if len(this._controls) > 0 {
        // for ctl in this._controls do SendMessage(ctl.handle, CM_RUN_DTOR, 0, 0)
        delete(this._controls)
    }
}

@private form_dtor :: proc(this : ^Form)
{
    delete_gdi_object(this.font.handle)
    delete(this._uDrawChilds)
    delete(this._cDrawChilds)
    delete(this._comboData)

    delete_gdi_object(this._gdBrush)
    if this._menubarUsed
    {
        menubar_dtor(this.menubar)
        delete(this._menuItemMap)

    }
    if len(this._timerMap) > 0 {
        for key, tmr in this._timerMap do timer_dtor(tmr)
        delete(this._timerMap)
        // print("Timers freed")
    }
    delete_childs(this)
    free_all(context.temp_allocator)
    free(this)
    // ptf("Form freed res %s\n", x)
}

@private set_form_font_internal :: proc(frm : ^Form) // deprecated
{
    if app.globalFont.handle == nil do CreateFont_handle(&app.globalFont, frm.handle)
    if frm.font.name == def_font_name && frm.font.size == def_font_size
    {
        // User did not made any changes in font. So use default font handle.
        // frm.font = app.globalFont
        SendMessage(frm.handle, WM_SETFONT, WPARAM(frm.font.handle), LPARAM(1))
    }
    else
    {
        if frm.font.handle == nil
        {
            // User just changed the font name and/or size. Create the font handle
            CreateFont_handle(&frm.font, frm.handle)
            SendMessage(frm.handle, WM_SETFONT, WPARAM(frm.font.handle), LPARAM(1))
        }
        else { SendMessage(frm.handle, WM_SETFONT, WPARAM(frm.font.handle), LPARAM(1)) }
    }
}

@private create_child_handles :: proc(this: ^Form)
{
    if this._menubarUsed do menubar_create_handle(this.menubar)
    if len(this._controls) > 0 {
        for ctl in this._controls {
            if ctl.handle == nil do create_control(ctl)
        }
    }
}

// Users can call 'create_handle' instead of this.
create_form :: proc(frm : ^Form )
{
    if app.mainHandle == nil {register_class()}
    if frm.backColor != def_window_color && frm._drawMode != .Gradient do frm._drawMode = .Flat_Color
    set_start_position(frm)
    set_form_style(frm)
    frm.handle = CreateWindowEx(  frm._exStyle,
                                    &winFormsClass[0],
                                    to_wstring(frm.text),
                                    frm._style,
                                    i32(frm.xpos),
                                    i32(frm.ypos),
                                    i32(frm.width),
                                    i32(frm.height),
                                    nil,
                                    nil,
                                    app.hInstance,
                                    nil )
    if frm.handle == nil {
        fmt.println("Error in CreateWindowEx,", GetLastError()) }
    else {
        app.winMap[frm.handle] = frm
        frm._isCreated = true
        app.formCount += 1
        if app.mainHandle == nil {
            app.mainHandle = frm.handle
            app.startState = frm.windowState
        }
        // set_form_font_internal(frm)
        if frm.font.handle == nil do CreateFont_handle(&frm.font, frm.handle)
        SetWindowLongPtr(frm.handle, GWLP_USERDATA, cast(LONG_PTR) cast(UINT_PTR) frm)
        ShowWindow(app.mainHandle, cast(i32) app.startState )
    }
    // free_all(context.temp_allocator)
}

print_point_func :: proc(c: ^Control, mea : ^MouseEventArgs)
{
    @static x : int = 1
    fmt.printf("[%d] X: %d,  Y: %d\n", x, mea.x, mea.y)
    x+= 1
    // for _, v in wftrack.allocation_map { ptf("winforms: %v leaked %v bytes\n", v.location, v.size) }
}

@private register_class :: proc()
{
    win_class : WNDCLASSEXW
    win_class.cbSize = size_of(win_class)
    win_class.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC
    win_class.lpfnWndProc = window_proc
    win_class.cbClsExtra = 0
    win_class.cbWndExtra = 0
    win_class.hInstance = app.hInstance
    win_class.hIcon = LoadIcon(nil, IDI_APPLICATION)
    win_class.hCursor = LoadCursor(nil, IDC_ARROW)
    win_class.hbrBackground = CreateSolidBrush(get_color_ref(def_window_color)) //cast(HBRUSH) (cast(UINT_PTR) Color_Window + 1)
    win_class.lpszMenuName = nil
    win_class.lpszClassName = &winFormsClass[0]
    res := RegisterClassEx(&win_class)
}

@private set_start_position :: proc(frm : ^Form)
{
    #partial switch frm.start_pos
    {
    case .Center:
        frm.xpos = (app.screenWidth - frm.width) / 2
        frm.ypos = (app.screenHeight - frm.height) / 2
    case .Top_Mid :
        frm.xpos = (app.screenWidth - frm.width) / 2
    case .Top_Right :
        frm.xpos = app.screenWidth - frm.width ;
    case .Mid_Left :
        frm.ypos = (app.screenHeight - frm.height) / 2
    case .Mid_Right:
        frm.xpos = app.screenWidth - frm.width ;
        frm.ypos = (app.screenHeight - frm.height) / 2
    case .Bottom_Left:
        frm.ypos = app.screenHeight - frm.height
    case .Bottom_Mid :
        frm.xpos = (app.screenWidth - frm.width) / 2
        frm.ypos = app.screenHeight - frm.height
    case .Bottom_Right :
        frm.xpos = app.screenWidth - frm.width
        frm.ypos = app.screenHeight - frm.height
    }
}

@private set_form_style :: proc(frm : ^Form)
{
    #partial switch frm.style {
        case .Default :
            frm._exStyle = normal_form_ex_style
            frm._style = normal_form_style
            if !frm.maximizeBox do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimizeBox do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_3D :
            frm._exStyle = fixed_3d_ex_style
            frm._style = fixed_3d_style
            if !frm.maximizeBox do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimizeBox do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_Dialog :
            frm._exStyle = fixed_dialog_ex_style
            frm._style = fixed_dialog_style
            if !frm.maximizeBox do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimizeBox do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_Single :
            frm._exStyle = fixed_single_ex_style
            frm._style = fixed_single_style
            if !frm.maximizeBox do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimizeBox do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_Tool :
            frm._exStyle = fixed_tool_ex_style
            frm._style = sizable_tool_style
        case .Sizable_Tool :
            frm._exStyle = sizable_tool_ex_style
            frm._style = sizable_tool_style
    }
}

@private track_mouse_move :: proc(hw : HWND)
{
    tme : TRACKMOUSEEVENT
    tme.cbSize = size_of(tme)
    tme.dwFlags = TME_HOVER | TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    TrackMouseEvent(&tme)
}

// @private form_gradient_bkg :: proc(this: ^Form, hdc: HDC, rct: RECT)
// {
//     tempRct : RECT
//     brush : HBRUSH
//     c1 := this._gdraw.c1
//     c2 := this._gdraw.c2
//     t2b := this._gdraw.t2b
//     x := int(c2.red - c1.red)
//     y := int(c2.green - c1.green)
//     z := int(c2.blue - c1.blue)
//     loopEnd := int(rct.bottom if t2b else rct.right)
//     for i in 0..<loopEnd
//     {
//         r, g, b : uint = 0, 0, 0
//         r = uint(int(c1.red) + int((int(i) * x) / loopEnd))
//         g = uint(int(c1.green) + int((int(i) * y) / loopEnd))
//         b = uint(int(c1.blue) + int((int(i) * z) / loopEnd))
//         // tBrush = CreateSolidBrush((b << 16) | (g << 8) | r)
//         // rc = RECT()
//         tempRct.left = 0 if t2b else i32(i)
//         tempRct.top = i32(i) if t2b else 0
//         tempRct.right = rct.right if t2b else i32(i + 1)
//         tempRct.bottom = i32(i) + i32(1) if t2b else i32(loopEnd)
//         brush = CreateSolidBrush(get_color_ref(r, g, b))
//         FillRect(hdc, &tempRct, brush)
//     }
// }

@private set_back_clr_internal :: proc(this : ^Form, hdc : HDC)
{
    rct : RECT
    hbr : HBRUSH
    GetClientRect(this.handle, &rct)
    if this._drawMode == .Flat_Color {
        this._gdBrush = CreateSolidBrush(get_color_ref(this.backColor))
    } else if this._drawMode == .Gradient {
        this._gdBrush = create_gradient_brush(hdc, rct, this._gdraw.c1, this._gdraw.c2, this._gdraw.t2b)
    }
    api.FillRect(hdc, &rct, this._gdBrush)
    // DeleteObject(HGDIOBJ(hbr))
}

FindHwnd :: enum {lb_hwnd, tb_hwnd}

 // Display windows message names in wndproc function.
@private display_msg :: proc(umsg : u32, )
{
    @static counter : int = 1
    win_msg := cast(Msg_map) umsg
    ptf("[%d] Message -  %s", counter, win_msg)
    counter += 1
}

@private getMenuFromHmenu :: proc(this: ^Form, hmenu: HMENU) -> (bool, ^MenuItem)
{
    if len(this._menuItemMap) > 0 {
        for _, menu in this._menuItemMap {
            if menu.handle == hmenu do return true, menu
        }
    }
    return false, nil
}

@private form_property_setter :: proc(this: ^Form, prop: FormProps, value: $T)
{
    switch prop {
		case .Start_Pos:break
		case .Style: break
		case .Minimize_Box: break
		case .Window_State: when T == FormState do form_setstate(this, value)
    }
}


// It's a private function. Combobox module is the caller.
collect_combo_data :: proc(frm: ^Form, cd : ComboData) {append(&frm._comboData, cd)}

//It's a private function. Combobox module is the caller.
update_combo_data :: proc(frm: ^Form, cd : ComboData)
{
    for &c in frm._comboData {
        if c.comboID == cd.comboID {
            c.comboHwnd = cd.comboHwnd
            c.listBoxHwnd = cd.listBoxHwnd
            return
        }
    }
}

@private find_combo_data :: proc(frm : ^Form, list_hwnd : HWND) -> (HWND, bool) {
    // We will search for the appropriate data in our combo data list.
    if len(frm._comboData) > 0 {
        for cd in frm._comboData {
            if cd.listBoxHwnd == list_hwnd do return cd.comboHwnd, true
        }
    }
    return nil, false
}

@private form_timer_handler :: proc(this: ^Form, wpm: WPARAM)
{
    key := cast(UINT_PTR)wpm
    timer, okay := this._timerMap[key]
    if okay && timer.onTick != nil {
        ea := new_event_args()
        timer.onTick(this, &ea)
    }
}

/*
    This type is used for holding information about the program for whole run time.
    We need to keep some info from the very beginning to the very end.
*/

sw : time.Stopwatch


@private
window_proc :: proc "fast" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM ) -> LRESULT
{
    context = global_context
    //display_msg(msg)
    switch msg {
        // case WM_PARENTNOTIFY :
        //    // display_msg(msg)
        //     if lo_word(DWORD(wp)) == WM_CREATE {
        //         chw := get_lparam_value(lp, HWND)
        //         return SendMessage(chw, CM_PARENTNOTIFY, 0, 0)
        //         //ptf("handle from parent notify - %d\n", chw)
        //     }
        // case WM_CREATE:
        //     return 0
        case CM_THREAD_MSG:
            frm := app.winMap[hw]
            if frm.onThreadMsg != nil do frm.onThreadMsg(wp, lp)

        case WM_TIMER:
            frm := app.winMap[hw]
            form_timer_handler(frm, wp)

        case WM_HSCROLL :
            ctl_hw := direct_cast(lp, HWND)
            return SendMessage(ctl_hw, WM_HSCROLL, wp, lp)

        case WM_VSCROLL:
            ctl_hw := direct_cast(lp, HWND)
            return SendMessage(ctl_hw, WM_VSCROLL, wp, lp)

        case WM_PAINT :
            frm := app.winMap[hw]
            if frm.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                frm.paint(frm, &pea)
                EndPaint(hw, &ps)
                return 0
            }
            // return 1


        // case WM_DRAWITEM :
        //     ctl_hwnd, hwnd_found := frm._uDrawChilds[UINT(wp)]
        //     if hwnd_found
        //     {
        //         return SendMessage(ctl_hwnd, CM_LABELDRAW, 0, lp)
        //     }
        //     else do return 0


        case WM_CTLCOLOREDIT :
            ctl_hwnd := direct_cast(lp, HWND)
            return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORSTATIC :
            ctl_hwnd := direct_cast(lp, HWND)
            return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORLISTBOX :
            /* ================================================================================
            If user uses a ComboBox, it contains a ListBox in it.
            So, 'ctlHwnd' might be a handle of that ListBox. Or it might be a normal ListBox too.
            So, we need to check it before disptch this message to that listbox.
            Because, if it is from Combo's listbox, there is no Wndproc function for that ListBox. 
            =======================================================================================*/
            frm := app.winMap[hw]
            ctl_hwnd := direct_cast(lp, HWND)
            cmb_hwnd, okay := find_combo_data(frm, ctl_hwnd)
            if okay  {
                // This message is from a combo's listbox. Divert it to that combo box.
                return SendMessage(cmb_hwnd, CM_COMBOLBCOLOR, wp, lp)
            } else {
                // This message is from a normal listbox. send it to it's wndproc.
                return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)
            }

        // case LB_GETITEMHEIGHT :
        //     fmt.println("LB_GETITEMHEIGHT")
                // ctl_hwnd := direct_cast(lp, HWND)
                // return SendMessage(ctl_hwnd, WM_CTLCOLORBTN, wp, lp )

        case WM_COMMAND :
            frm := app.winMap[hw]
            switch hi_word(auto_cast(wp)) {
                case 0:
                    if len(frm._menuItemMap) > 0 {
                        menu := frm._menuItemMap[cast(uint)(lo_word(auto_cast(wp)))]
                        if menu != nil && menu.onClick != nil {
                            ea := new_event_args()
                            menu.onClick(menu, &ea)
                            return 0
                        }
                    }
                case 1: break
                case :
                    ctl_hwnd := direct_cast(lp, HWND)
                    return SendMessage(ctl_hwnd, CM_CTLCOMMAND, wp, lp)
            }

        case WM_SHOWWINDOW:
            // print("WM_SHOWWINDOW")
            frm := app.winMap[hw]
            if !frm._isLoaded {
                frm._isLoaded = true
                if frm.onLoad != nil {
                    ea := new_event_args()
                    frm->onLoad(&ea)
                    return 0
                }
            }
            return 0

        case WM_ACTIVATEAPP :
            frm := app.winMap[hw]
            if frm.onActivate != nil || frm.onDeActivate != nil {
                ea := new_event_args()
                b_flag := BOOL(wp)
                if !b_flag {
                    if frm.onDeActivate != nil do frm->onDeActivate(&ea)
                } else {
                    if frm.onActivate != nil do frm->onActivate(&ea)
                }
            }
            return 0

        case WM_KEYUP, WM_SYSKEYUP :
            frm := app.winMap[hw]
            if frm.onKeyUp != nil {
                kea := new_key_event_args(wp)
                frm.onKeyUp(frm, &kea)
            }

        case WM_KEYDOWN, WM_SYSKEYDOWN :
            frm := app.winMap[hw]
            if frm.onKeyDown != nil {
                kea := new_key_event_args(wp)
                frm.onKeyDown(frm, &kea)
            }

        case WM_CHAR :
            frm := app.winMap[hw]
            if frm.onKeyPress != nil {
                kea := new_key_event_args(wp)
                frm.onKeyPress(frm, &kea)
                return 0
            }

        case WM_LBUTTONDOWN:
            // time.stopwatch_start(&sw)            
            frm := app.winMap[hw]
            // time.stopwatch_stop(&sw)
            // ptf("frm getting time %s", time.stopwatch_duration(sw))
            // time.stopwatch_reset(&sw)
            frm._mDownHappened = true
            if frm.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseDown(frm, &mea)
            }

        case WM_RBUTTONDOWN:
            frm := app.winMap[hw]
            frm._mRDownHappened = true
            if frm.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onRightMouseDown(frm, &mea)
            }

        case WM_LBUTTONUP :
            frm := app.winMap[hw]
            if frm.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseUp(frm, &mea)
            }
            if frm._mDownHappened {
                frm._mDownHappened = false
                SendMessage(frm.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            frm := app.winMap[hw]
            if frm.onMouseClick != nil {
                ea := new_event_args()
                frm->onMouseClick(&ea)
            }

        case WM_RBUTTONUP :
            frm := app.winMap[hw]
            if frm.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onRightMouseUp(frm, &mea)
            }
            if frm._mRDownHappened {
                frm._mRDownHappened = false
                SendMessage(frm.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            frm := app.winMap[hw]
            if frm.onRightClick != nil {
                ea := new_event_args()
                frm.onRightClick(frm, &ea)
            }

        case WM_LBUTTONDBLCLK :
            frm := app.winMap[hw]
            if frm.onDoubleClick != nil {
                ea := new_event_args()
                frm.onDoubleClick(frm, &ea)
                return 0
            }

        case WM_MOUSEWHEEL :
            frm := app.winMap[hw]
            if frm.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseScroll(frm, &mea)
            }

        case WM_MOUSEMOVE :
            frm := app.winMap[hw]
            if !frm._isMouseTracking {
                frm._isMouseTracking = true
                track_mouse_move(hw)
                if !frm._isMouseEntered {
                    frm._isMouseEntered = true
                    if frm.onMouseEnter != nil {
                        ea := new_event_args()
                        frm.onMouseEnter(frm, &ea)
                    }
                }
            } //---------------------------------------

            if frm.onMouseMove != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseMove(frm, &mea)
            }

        case WM_MOUSEHOVER :
            frm := app.winMap[hw]
            if frm._isMouseTracking do frm._isMouseTracking = false
            if frm.onMouseHover != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseHover(frm, &mea)
            }

        case WM_MOUSELEAVE :
            frm := app.winMap[hw]
            if frm._isMouseTracking {
                frm._isMouseTracking = false
                frm._isMouseEntered = false
            }

            if frm.onMouseLeave != nil {
                ea := new_event_args()
                frm.onMouseLeave(frm, &ea)
            }

        case WM_SIZING :
            frm := app.winMap[hw]
            sea := new_size_event_args(msg, wp, lp)
            frm.width = int(sea.formRect.right - sea.formRect.left)
            frm.height = int(sea.formRect.bottom - sea.formRect.top)
            if frm.onResizing != nil {
                frm.onResizing(frm, &sea)
                return 1
            }
            return 1
        //case WM_WINDOWPOSCHANGING:
            //alert("Pos changing")
            /*
            wps := direct_cast(lp, ^WINDOWPOS)
            frm.xpos = int(wps.x)
            frm.ypos = int(wps.y)
            frm.width = int(wps.cx)
            frm.height = int(wps.cy)
            if frm._size_started {
                frm._size_started = false
                if frm.onSizeChanging != nil {
                    ea := new_event_args()
                    frm.onSizeChanging(frm, &ea)
                    return 1
                }
            }

        //case WM_WINDOWPOSCHANGED:
            //alert("Pos changed")
            //wps := direct_cast(lp, ^WINDOWPOS) */

        case WM_SIZE :
            frm := app.winMap[hw]
            sea := new_size_event_args(msg, wp, lp)
            if frm.onSizeChanged != nil {
                ea := new_event_args()
                frm.onSizeChanged(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVE :
            frm := app.winMap[hw]
            frm.xpos = get_x_lparam(lp)
            frm.ypos = get_y_lparam(lp)
            if frm.onMoved != nil {
                ea := new_event_args()
                frm.onMoved(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVING :
            frm := app.winMap[hw]
            rct := direct_cast(lp, ^RECT)
            frm.xpos = int(rct.left)
            frm.ypos = int(rct.top)
            if frm.onMoving != nil {
                ea := new_event_args()
                frm.onMoving(frm, &ea)
                return LRESULT(1)
            }
            return 0

        case WM_SYSCOMMAND :
            frm := app.winMap[hw]
            sys_msg := UINT(wp & 0xFFF0)
            switch sys_msg {
            case SC_MINIMIZE :
                if frm.onMinimized != nil {
                    ea := new_event_args()
                    frm.onMinimized(frm, &ea)
                }
            case SC_MAXIMIZE :
                if frm.onMaximized != nil {
                    ea := new_event_args()
                    frm.onMaximized(frm, &ea)
                }
            case SC_RESTORE :
                if frm.onRestored != nil {
                    ea := new_event_args()
                    frm.onRestored(frm, &ea)
                }
            }
        case WM_ERASEBKGND :
            frm := app.winMap[hw]
            if frm._drawMode != .Default {
                set_back_clr_internal(frm, HDC(wp))
                return 1
            }
            // return 0

        case WM_CLOSE :
            frm := app.winMap[hw]
            if frm.onClosing != nil {
                ea := new_event_args()
                frm.onClosing(frm, &ea)
                if ea.cancelled do return 0
            }
            // return 0

        case WM_NOTIFY :
            nm := direct_cast(lp, ^NMHDR)
            return SendMessage(nm.hwndFrom, CM_NOTIFY, wp, lp )

        case WM_DESTROY:
            frm := app.winMap[hw]
            if frm.onClosed != nil {
                ea:= new_event_args()
                frm.onClosed(frm, &ea)
            }
            form_dtor(frm) // Freeing all resources.
            frm = nil
            // return 0

        case WM_NCDESTROY:
            if hw == app.mainHandle do PostQuitMessage(0)
            // return 0

        // Menu related
        case WM_MEASUREITEM:
            pmi := direct_cast(lp, LPMEASUREITEMSTRUCT)
            mi := direct_cast(pmi.itemData, ^MenuItem)
            // ptf("wm measure item - menu name : %s\n", mi.text)
            if mi.kind == .Base_Menu || mi.kind == .Popup {
                hdc := GetDC(hw)
                size : SIZE
                GetTextExtentPoint32(hdc, mi._wideText, len(mi.text), &size)
                ReleaseDC(hw, hdc)
                pmi.itemWidth = auto_cast(size.width)
                pmi.itemHeight = auto_cast(size.height + 10)
            } else {
                pmi.itemWidth = 150
                pmi.itemHeight = 25
            }
            return to_lresult(true)

        case WM_DRAWITEM:
            frm := app.winMap[hw]
            dis := direct_cast(lp, LPDRAWITEMSTRUCT)
            mi := direct_cast(dis.itemData, ^MenuItem)
            // ptf("wm draw item - menu name : %s\n", mi.text)
            txtClrRef := mi.fgColor.ref

            if dis.itemState == 320 || dis.itemState == 257 {
                rc : RECT
                if mi._isEnabled {

                    rc = RECT{dis.rcItem.left + 4, dis.rcItem.top + 2, dis.rcItem.right, dis.rcItem.bottom - 2}
                    api.FillRect(dis.hDC, &rc, frm.menubar._menuHotBgBrush)
                    FrameRect(dis.hDC, &rc, frm.menubar._menuFrameBrush)
                    txtClrRef = 0x00000000
                } else {

                    api.FillRect(dis.hDC, &rc, frm.menubar._menuGrayBrush)
                    txtClrRef = frm.menubar._menuGrayCref
                }
            } else {
                // ptf("draw menu : %s\n", mi.text)
                api.FillRect(dis.hDC, &dis.rcItem, frm.menubar._menuDefBgBrush)
                if !mi._isEnabled do txtClrRef = frm.menubar._menuGrayCref
            }

            SetBkMode(dis.hDC, 1)
            if mi.kind == .Base_Menu  {
                dis.rcItem.left += 10
            } else {
                dis.rcItem.left += 25
            }
            SelectObject(dis.hDC, cast(HGDIOBJ)(frm.menubar.font.handle))
            SetTextColor(dis.hDC, txtClrRef)
            DrawText(dis.hDC, mi._wideText, -1, &dis.rcItem, menuTxtFlag)
            return 0

        case WM_CONTEXTMENU:
            frm := app.winMap[hw]
		    if frm.contextMenu != nil do contextmenu_show(frm.contextMenu, lp)
            return 0

        case WM_MENUSELECT:
            frm := app.winMap[hw]
            menu_okay, pmenu := getMenuFromHmenu(frm, direct_cast(lp, HMENU))
            mid := cast(uint)(lo_word(auto_cast(wp))) // Could be an id of a child menu or index of a child menu
            hwwpm := hi_word(auto_cast(wp))
            if menu_okay {
                menu_okay = false
                menu : ^MenuItem
                switch (hwwpm) {
                    case 33152: // A normal child menu. We can use mid ad menu id.
                        menu = frm._menuItemMap[mid]
                    case 33168: // A popup child menu. We can use mid as index.
                        menu_okay, menu = get_child_menu_from_id(pmenu, mid)
                }
                if menu_okay && menu.onFocus != nil {
                    ea:= new_event_args()
                    menu.onFocus(menu, &ea)
                }
            }

        case WM_INITMENUPOPUP:
            frm := app.winMap[hw]
            menu_okay, menu := getMenuFromHmenu(frm, direct_cast(wp, HMENU))
            if menu_okay && menu.onPopup != nil {
                ea:= new_event_args()
                menu.onPopup(menu, &ea)
            }

        case WM_UNINITMENUPOPUP:
            frm := app.winMap[hw]
            menu_okay, menu := getMenuFromHmenu(frm, direct_cast(wp, HMENU))
            if menu_okay && menu.onCloseup != nil {
                ea:= new_event_args()
                menu.onCloseup(menu, &ea)
            }

        case :
            return DefWindowProc(hw, msg, wp, lp)
    }
    return DefWindowProc(hw, msg, wp, lp)
}
