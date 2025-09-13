
/*===========================================Form Docs=========================================================
    Form struct
        Constructor: new_form() -> ^Form
        Properties:
            Al props from Control struct
            start_pos       : StartPosition - An enum in this file.
            style           : FormStyle     - An enum in this file.
            minimizeBox     : bool
            maximizeBox     : bool 
            createChilds    : bool 
            windowState     : FormState     - An enum in this file.
            menubar         : ^MenuBar      - See menu.odin
        Functions:
            form_set_gradient()     : Set gradient background for form
            start_mainloop()        : Show the form and start the main loop
            form_show()             : Show the form
            form_hide()             : Hide the form
            form_setstate()         : Set the minimize/maximize state
            form_addTimer()         : Adds a timer to form.
            create_handle()         : Create the handle of form
            print_points()          : Print the mouse cordinates when clicked.
        Events:
            EventHandler type -proc(^Control, ^EventArgs) [See events.odin]
                onLoad 
                onActivate
                onDeActivate
                onMoving
                onMoved 
                onMinimized
                onMaximized
                onRestored
                onClosing
                onClosed 
            SizeEventHandler type - proc(^Control, ^SizeEventArgs) [See events.odin]
                 onResizing
                 onResized 
            ThreadMsgHandler type - proc(WPARAM, LPARAM)
                onThreadMsg

==============================================================================================================*/
package winforms

import "core:fmt"
import "base:runtime"
import "core:mem"
import "core:time"
import api "core:sys/windows"


// Some window colors
/*
    0xF5FFFA
    0xF5F5F5
    0xF8F8F8
    0xF8F8FF
    0xF0FFF0
    0xEEEEE4
*/



Form :: struct
{
    using control : Control, 
    start_pos : StartPosition,
    style : FormStyle,
    minimizeBox, maximizeBox : bool,
    createChilds: bool,
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
    _cDrawChilds : [dynamic]HWND, // Holds Child handles which needs special draw
    _uDrawChilds : map[UINT]HWND,
    _controls : [dynamic]^Control,
    _gdBrush: HBRUSH,
    _comboData : [dynamic]ComboData,
    _menuItemMap : map[u32]^MenuItem,
    _menubarUsed: bool,
    _timerMap: map[UINT_PTR]^Timer,
    _formID: int,
}

// Create new form
new_form :: proc{new_form1, new_form2}

// Users can call 'create_handle()' instead of this.
create_form :: proc(this : ^Form )
{
    // if app.mainHandle == nil {}
    if this.backColor != def_window_color && this._drawMode != .Gradient do this._drawMode = .Flat_Color
    set_start_position(this)
    set_form_style(this)
    this.handle = CreateWindowEx(this._exStyle, &winFormsClass[0],
                                to_wstring(this.text), this._style,
                                i32(this.xpos), i32(this.ypos),
                                i32(this.width), i32(this.height),
                                nil, nil, app.hInstance, nil )
    if this.handle == nil {
        fmt.println("Error in CreateWindowEx,", GetLastError()) }
    else {
        app.winMap[this.handle] = this
        this._isCreated = true
        app.formCount += 1
        if app.mainHandle == nil {
            app.mainHandle = this.handle
            app.startState = this.windowState
        }
        // set_form_font_internal(this)
        if this.font.handle == nil do font_create_handle(&this.font)
        SetWindowLongPtr(this.handle, GWLP_USERDATA, cast(LONG_PTR) cast(UINT_PTR) this)
        ShowWindow(app.mainHandle, cast(i32) app.startState )
    }
    // free_all(context.temp_allocator)
}

// Print the mouse coordinates where it clicked
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

// Start the main loop and display the form
start_mainloop :: proc(this: ^Form)
{
    create_child_handles(this)
    // ShowWindow(this.handle, 5)
    UpdateWindow(this.handle)
    ms : MSG
    for GetMessage(&ms, nil, 0, 0) != 0
    {
        TranslateMessage(&ms)
        DispatchMessage(&ms)
    }
    app_finalize(app)
}

// Show the form
form_show :: proc(f : Form) { ShowWindow(f.handle, SW_SHOW) }

// Hide the form
form_hide :: proc(f : Form) { ShowWindow(f.handle, SW_HIDE) }

// Set the maximize/minimize/restore states
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


// Private ??
FormGradient :: struct {c1, c2 : Color, t2b : bool, }

//=================================================================Private Functions=========================

@private form_ctor :: proc( t : string = "", w : int = 500, h : int = 400 ) -> ^Form
{
    if app.formCount == 0 do global_context = context
    if app.isFormReg == false do initFormDefaults()
    app.formCount += 1
    // app.curr_context = ctx
    // ptf("form context ui %d\n", context.user_index)
    f := new(Form, global_context.allocator)

    f.kind = .Form
    f.text = t == "" ? conc_num("Form_", app.formCount) : t
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
    // ptf("font name: %s", f.font.name)
    return  f
}

@private new_form1 :: proc() -> ^Form { return form_ctor() }

@private new_form2 :: proc( txt : string, w : int = 500, h : int = 400) -> ^Form
{
    return form_ctor( txt, w, h)
}

@private delete_childs :: proc(this: ^Form)
{
    if len(this._controls) > 0 {
        // for ctl in this._controls do SendMessage(ctl.handle, CM_RUN_DTOR, 0, 0)
        delete(this._controls)
    }
}

@private form_dtor :: proc(this : ^Form)
{
    // delete_gdi_object(this.font.handle)
    font_destroy(&this.font)
    delete(this._uDrawChilds)
    delete(this._cDrawChilds)
    delete(this._comboData)

    delete_gdi_object(this._gdBrush)
    if this._menubarUsed {
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


form_setfont :: proc(this : ^Form, fname: string, fsize: int, fweight: FontWeight = .Normal, useGlobal: b32 = true) 
{
    this.font = new_font(fname, fsize, fweight)
    lf : LOGFONT
    font_fill_logfont(&this.font, &lf)
    this.font.handle = CreateFontIndirect(&lf)
    if this._isCreated do ctl_send_msg(this.handle, WM_SETFONT,this.font.handle, 1)
    if useGlobal do app.lfont = lf      
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

@private print_point_func :: proc(c: ^Control, mea : ^MouseEventArgs)
{
    @static x : int = 1
    fmt.printf("[%d] X: %d,  Y: %d\n", x, mea.x, mea.y)
    x+= 1
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
}



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
@private collect_combo_data :: proc(frm: ^Form, cd : ComboData) {append(&frm._comboData, cd)}

//It's a private function. Combobox module is the caller.
@private update_combo_data :: proc(frm: ^Form, cd : ComboData)
{
    for &c in frm._comboData {
        if c.comboID == cd.comboID {
            c.comboHwnd = cd.comboHwnd
            c.listBoxHwnd = cd.listBoxHwnd
            return
        }
    }
}

@private find_combo_data :: proc(frm : ^Form, list_hwnd : HWND) -> (HWND, bool) 
{
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

@private
window_proc :: proc "stdcall" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM ) -> LRESULT
{
    context = global_context
    //display_msg(msg)
    switch msg {
        case CM_THREAD_MSG:
            frm := app.winMap[hw]
            if frm.onThreadMsg != nil do frm.onThreadMsg(wp, lp)

        case WM_TIMER:
            frm := app.winMap[hw]
            form_timer_handler(frm, wp)

        case WM_HSCROLL :
            ctl_hw := dir_cast(lp, HWND)
            return SendMessage(ctl_hw, WM_HSCROLL, wp, lp)

        case WM_VSCROLL:
            ctl_hw := dir_cast(lp, HWND)
            return SendMessage(ctl_hw, WM_VSCROLL, wp, lp)

        case WM_PAINT :
            frm := app.winMap[hw]
            if frm.onPaint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                frm.onPaint(frm, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CTLCOLOREDIT :
            ctl_hwnd := dir_cast(lp, HWND)
            return SendMessage(ctl_hwnd, CM_EDIT_COLOR, wp, lp)

        case WM_CTLCOLORSTATIC :
            ctl_hwnd := dir_cast(lp, HWND)
            return SendMessage(ctl_hwnd, CM_STATIC_COLOR, wp, lp)

        case WM_CTLCOLORLISTBOX :
            /* ================================================================================
            If user uses a ComboBox, it contains a ListBox in it.
            So, 'ctlHwnd' might be a handle of that ListBox. Or it might be a normal ListBox too.
            So, we need to check it before disptch this message to that listbox.
            Because, if it is from Combo's listbox, there is no Wndproc function for that ListBox. 
            =======================================================================================*/
            frm := app.winMap[hw]
            ctl_hwnd := dir_cast(lp, HWND)
            cmb_hwnd, okay := find_combo_data(frm, ctl_hwnd)
            if okay  {
                // This message is from a combo's listbox. Divert it to that combo box.
                return SendMessage(cmb_hwnd, CM_COMBOLBCOLOR, wp, lp)
            } else {
                // This message is from a normal listbox. send it to it's wndproc.
                return SendMessage(ctl_hwnd, CM_LIST_COLOR, wp, lp)
            }

        case WM_COMMAND :
            frm := app.winMap[hw]
            switch HIWORD(wp) {
                case 0:
                    if len(frm._menuItemMap) > 0 {
                        menu := frm._menuItemMap[cast(u32)(LOWORD(wp))]
                        if menu != nil && menu.onClick != nil {
                            ea := new_event_args()
                            menu.onClick(menu, &ea)
                            return 0
                        }
                    }
                case 1: break
                case :
                    ctl_hwnd := dir_cast(lp, HWND)
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
            frm := app.winMap[hw]
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
            if frm.onClick != nil {
                ea := new_event_args()
                frm->onClick(&ea)
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
            frm.xpos = int(get_x_lpm(lp))
            frm.ypos = int(get_y_lpm(lp))
            if frm.onMoved != nil {
                ea := new_event_args()
                frm.onMoved(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVING :
            frm := app.winMap[hw]
            rct := dir_cast(lp, ^RECT)
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
            nm := dir_cast(lp, ^NMHDR)
            return SendMessage(nm.hwndFrom, CM_NOTIFY, wp, lp )

        case WM_DESTROY:
            frm := app.winMap[hw]
            if frm.onClosed != nil {
                ea:= new_event_args()
                frm.onClosed(frm, &ea)
            }

        case WM_NCDESTROY:
            frm := app.winMap[hw]
            if hw == app.mainHandle do PostQuitMessage(0)
            form_dtor(frm) // Freeing all resources.
            delete_key(&app.winMap, hw)
            frm = nil
            // return 0

        // Menu related
        case WM_MEASUREITEM:
            pmi := dir_cast(lp, LPMEASUREITEMSTRUCT)
            if pmi.CtlType == ODT_MENU {
                mi := dir_cast(pmi.itemData, ^MenuItem)            
                if mi.kind == .Base_Menu || mi.kind == .Popup {
                    hdc := GetDC(hw)
                    defer ReleaseDC(hw, hdc)
                    size : SIZE
                    GetTextExtentPoint32(hdc, mi._wideText, len(mi.text), &size)                    
                    pmi.itemWidth = auto_cast(size.cx)
                    pmi.itemHeight = auto_cast(size.cy + 10)
                } else {
                    pmi.itemWidth = 150
                    pmi.itemHeight = 25
                }
                return toLRES(true)
            }            

        case WM_DRAWITEM:
            frm := app.winMap[hw]
            dis := dir_cast(lp, LPDRAWITEMSTRUCT)
            if dis.ctlType == ODT_MENU {
                menubar_draw_menu_items(frm.menubar, dis)
                return 0
            }

        case WM_CONTEXTMENU:
            frm := app.winMap[hw]
		    if frm.contextMenu != nil do contextmenu_show(frm.contextMenu, lp)
            return 0

        case WM_MENUSELECT:
            frm := app.winMap[hw]
            menu_okay, pmenu := getMenuFromHmenu(frm, dir_cast(lp, HMENU))
            mid := cast(u32)(LOWORD(wp)) // Could be an id of a child menu or index of a child menu
            hwwpm := HIWORD(wp)
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
            menu_okay, menu := getMenuFromHmenu(frm, dir_cast(wp, HMENU))
            if menu_okay && menu.onPopup != nil {
                ea:= new_event_args()
                menu.onPopup(menu, &ea)
            }

        case WM_UNINITMENUPOPUP:
            frm := app.winMap[hw]
            menu_okay, menu := getMenuFromHmenu(frm, dir_cast(wp, HMENU))
            if menu_okay && menu.onCloseup != nil {
                ea:= new_event_args()
                menu.onCloseup(menu, &ea)
            }

        case :
            return DefWindowProc(hw, msg, wp, lp)
    }
    return DefWindowProc(hw, msg, wp, lp)
}

