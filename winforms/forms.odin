
package winforms

import "core:fmt"
import "core:runtime"
import "core:mem"

nph : HWND
wftrack: mem.Tracking_Allocator
global_context: runtime.Context


// Some better window colors
/*
    0xF5FFFA
    0xF5F5F5
    0xF8F8F8
    0xF8F8FF
    0xF0FFF0
    0xEEEEE4
*/
def_window_color :uint: 0xF5F5F5
def_fore_color :uint: 0x000000
pure_white :uint: 0xFFFFFF
pure_black :uint: 0x000000
def_font_name :: "Tahoma"
def_font_size :: 11
empty_wstring := to_wstring(" ") // This is just for testing purpose. Remove it when you finished this lib.
app := start_app() // Global variable for storing data needed to create a window.
def_bgc : Color
def_fgc : Color

//mcd : MouseClickData


/*
    This type is used for holding information about the program for whole run time.
    We need to keep some info from the very beginning to the very end.
*/
@private
Application :: struct
{
    mainHandle : HWND,
    mainLoopStarted : bool,
    className : string,
    hInstance : HINSTANCE,
    screenWidth, screenHeight : int,
    formCount : int,
    startState : FormState,
    globalFont : Font,
    iccx : INITCOMMONCONTROLSEX,
    clrWhite : uint,
    clrBlack : uint,
    curr_context: ^runtime.Context,
    wftrack: ^mem.Tracking_Allocator
}

@private
start_app :: proc() -> Application
{
    // cont := runtime.default_context
    appl : Application
    // appl.globalFont = new_font(def_font_name, def_font_size)
    appl.className = "WingLib Window in Odin"
    appl.hInstance = GetModuleHandle(nil)
    appl.screenWidth = int(GetSystemMetrics(0))
    appl.screenHeight = int(GetSystemMetrics(1))

    appl.iccx.dwSize = size_of(appl.iccx)
    appl.iccx.dwIcc = ICC_STANDARD_CLASSES
    InitCommonControlsEx(&appl.iccx)    // Iinitializing standard common controls.
    // fmt.println("init commoms")
    // def_bgc = new_color(def_window_color)
    // def_fgc = new_color(def_fore_color)
    appl.clrWhite = pure_white
    appl.clrBlack = pure_black
    // appl.curr_context = &cont

    return appl
}

winforms_init :: proc(trk: ^mem.Tracking_Allocator) {
    // global_context = runtime.default_context() if cont == nil else cont^
    // print("u i ", context.user_index)
    // // global_context = context
    // mem.tracking_allocator_init(trk, context.allocator)
    // context.allocator = mem.tracking_allocator(trk)
    // global_context = context
    app.wftrack = trk
}

show_memory_report :: proc(track: ^mem.Tracking_Allocator) 
{
    for _, v in track.allocation_map { ptf("%v leaked %v bytes\n", v.location, v.size) }
    for bf in track.bad_free_array { ptf("%v allocation %p was freed badly\n", bf.location, bf.memory) }
}

Form :: struct
{
    using control : Control,  // By this, form is a child of control.
    start_pos : StartPosition,
    style : FormStyle,
    minimizeBox, maximizeBox : bool,
    windowState : FormState,

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

    _isLoaded : bool,
    _gdraw : FormGradient,
    _drawMode : FormDrawMode,
    _cDrawChilds : [dynamic]HWND,
    _uDrawChilds : map[UINT]HWND,
    // _combo_list : [dynamic]ComboInfo,
    _comboData : [dynamic]ComboData,
}

FormDrawMode :: enum { Default, flat_color, gradient,}
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

new_form :: proc{new_form1, new_form2}

@private
form_ctor :: proc( t : string = "", w : int = 500, h : int = 400) -> ^Form
{
    if app.formCount == 0 do global_context = context
    app.formCount += 1
    // app.curr_context = ctx
    f := new(Form)
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

    f.windowState = .Normal
    f._uDrawChilds = make(map[UINT]HWND)

    return  f
}

@private
new_form1 :: proc() -> ^Form
{
    return form_ctor()

}

@private
new_form2 :: proc( txt : string, w : int = 500, h : int = 400) -> ^Form
{
    return form_ctor( txt, w, h)
}

@private
form_dtor :: proc(frm : ^Form)
{
    delete_gdi_object(frm.font.handle)
    delete(frm._uDrawChilds)
    delete(frm._cDrawChilds)
    delete(frm._comboData)
    free(frm)

}

@private
set_form_font_internal :: proc(frm : ^Form)
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


// Users can call 'create_handle' instead of this.
create_form :: proc(frm : ^Form )
{
    if app.mainHandle == nil {register_class()}
    if frm.backColor != def_window_color do frm._drawMode = .flat_color
    set_start_position(frm)
    set_form_style(frm)
    frm.handle = CreateWindowEx(  frm._exStyle,
                                    to_wstring(app.className),
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
    if frm.handle == nil { fmt.println("Error in CreateWindoeEx,", GetLastError()) }
    else
    {
        frm._isCreated = true
        app.formCount += 1
        if app.mainHandle == nil
        {
            app.mainHandle = frm.handle
            app.startState = frm.windowState
        }
        set_form_font_internal(frm)
        SetWindowLongPtr(frm.handle, GWLP_USERDATA, cast(LONG_PTR) cast(UINT_PTR) frm)
    }
}

/* This will display the window.
    And it will check if the main loop is started or not.
    If not started, it will start the main loop */
form_start :: proc()
{
    ShowWindow(app.mainHandle, cast(i32) app.startState )
    //app.mainLoopStarted = true
    ms : MSG
    for GetMessage(&ms, nil, 0, 0) != 0
    {
        TranslateMessage(&ms)
        DispatchMessage(&ms)
    }

}

form_show :: proc(f : Form) { ShowWindow(f.handle, SW_SHOW) }
form_hide :: proc(f : Form) { ShowWindow(f.handle, SW_HIDE) }
form_setstate :: proc(frm : Form, state : FormState) { ShowWindow(frm.handle, cast(i32) state ) }


print_point_func :: proc(c: ^Control, mea : ^MouseEventArgs) 
{
    @static x : int = 1
    fmt.printf("[%d] X: %d,  Y: %d\n", x, mea.x, mea.y)
    x+= 1
    // for _, v in wftrack.allocation_map { ptf("winforms: %v leaked %v bytes\n", v.location, v.size) }
}

print_points :: proc(frm: ^Form) { frm.onMouseUp = print_point_func }

// Set the colors to draw a gradient background in form.
set_gradient_form :: proc(f : ^Form, clr1, clr2 : uint,top_bottom := true)
{
    f._gdraw.c1 = new_color(clr1)
    f._gdraw.c2 = new_color(clr2)
    f._gdraw.t2b = top_bottom
    f._drawMode = .gradient
    if f._isCreated do InvalidateRect(f.handle, nil, false)
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
    win_class.lpszClassName = to_wstring(app.className)

    res := RegisterClassEx(&win_class)
    // global_context = context
    // print("u i ", context.user_index)
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

@private set_form_style :: proc(frm : ^Form) {
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

@private track_mouse_move :: proc(hw : HWND) {
    tme : TRACKMOUSEEVENT
    tme.cbSize = size_of(tme)
    tme.dwFlags = TME_HOVER | TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    TrackMouseEvent(&tme)
}

@private set_back_clr_internal :: proc(f : ^Form, hdc : HDC)
{
    rct : RECT
    hbr : HBRUSH
    GetClientRect(f.handle, &rct)
    if f._drawMode == .flat_color {
        hbr = CreateSolidBrush(get_color_ref(f.backColor))
    } else if f._drawMode == .gradient {
        hbr = create_gradient_brush(hdc, rct, f._gdraw.c1, f._gdraw.c2, f._gdraw.t2b)
    }
    FillRect(hdc, &rct, hbr)
    DeleteObject(HGDIOBJ(hbr))
}

FindHwnd :: enum {lb_hwnd, tb_hwnd}


 // Display windows message names in wndproc function.
@private display_msg :: proc(umsg : u32, )
{
    @static counter : int = 1
    win_msg := cast(Msg_map) umsg
    ptf("[%d] Message -  %s\n", counter, win_msg)
    counter += 1
}

// It's a private function. Combobox module is the caller.
collect_combo_data :: proc(frm: ^Form, cd : ComboData) {append(&frm._comboData, cd)}

//It's a private function. Combobox module is the caller.
update_combo_data :: proc(frm: ^Form, cd : ComboData) {
    for c in &frm._comboData {
        if c.comboID == cd.comboID {
            c.comboHwnd = cd.comboHwnd
            c.listBoxHwnd = cd.listBoxHwnd
            return
        }
    }
}

// @private
// find_combo_data :: proc(frm : ^Form, list_hwnd : HWND) -> HWND {
//     // We will search for the appropriate date in our combo data list.
//     for cd in frm._comboData {
//         if cd.listBoxHwnd == list_hwnd {
//             return cd.comboHwnd
//         }
//     }
//     return nil
// }

@private
window_proc :: proc "std" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM ) -> LRESULT
{

    context = global_context
    // context = runtime.default_context()
    // context.allocator = app.mem_tracker^
    frm := direct_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^Form)
    //display_msg(msg)
    switch msg
    {


        // case WM_PARENTNOTIFY :
        //    // display_msg(msg)
        //     if lo_word(DWORD(wp)) == WM_CREATE {
        //         chw := get_lparam_value(lp, HWND)
        //         return SendMessage(chw, CM_PARENTNOTIFY, 0, 0)
        //         //ptf("handle from parent notify - %d\n", chw)
        //     }

        case WM_HSCROLL :
            ctl_hw := direct_cast(lp, HWND)
            return SendMessage(ctl_hw, WM_HSCROLL, wp, lp)

        case WM_VSCROLL:
            ctl_hw := direct_cast(lp, HWND)
            return SendMessage(ctl_hw, WM_VSCROLL, wp, lp)


        case WM_PAINT :
            if frm.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                frm.paint(frm, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_DRAWITEM :
            ctl_hwnd, hwnd_found := frm._uDrawChilds[UINT(wp)]
            if hwnd_found {
                return SendMessage(ctl_hwnd, CM_LABELDRAW, 0, lp)
            } else do return 0


        case WM_CTLCOLOREDIT :
            ctl_hwnd := direct_cast(lp, HWND)
            return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORSTATIC :
            ctl_hwnd := direct_cast(lp, HWND)
            // fmt.println("label color ", ctl_hwnd)
            return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORLISTBOX :
            /* If user uses a ComboBox, it contains a ListBox in it.
             * So, 'ctlHwnd' might be a handle of that ListBox. Or it might be a normal ListBox too.
             * So, we need to check it before disptch this message to that listbox.
             * Because, if it is from Combo's listbox, there is no Wndproc function for that ListBox. */
            ctl_hwnd := direct_cast(lp, HWND)
            // cmb_hwnd := find_combo_data(frm, ctl_hwnd)
            // if cmb_hwnd != nil {
            //     // This message is from a combo's listbox. Divert it to that combo box.

            //     return SendMessage(cmb_hwnd, CM_COMBOLBCOLOR, wp, lp)
            // } else {
            //     // This message is from a normal listbox. send it to it's wndproc.
            //     return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)
            // }

        // case LB_GETITEMHEIGHT :
        //     fmt.println("LB_GETITEMHEIGHT")
                // ctl_hwnd := direct_cast(lp, HWND)
                // return SendMessage(ctl_hwnd, WM_CTLCOLORBTN, wp, lp )

        case WM_COMMAND :
            ctl_hwnd := direct_cast(lp, HWND)
            SendMessage(ctl_hwnd, CM_CTLCOMMAND, wp, lp)

        case WM_SHOWWINDOW:
            if !frm._isLoaded {
                frm._isLoaded = true
                if frm.onLoad != nil {
                    ea := new_event_args()
                    frm->onLoad(&ea)
                    return 0
                }
            }

        case WM_ACTIVATEAPP :
            if frm.onActivate != nil || frm.onDeActivate != nil {
                ea := new_event_args()
                b_flag := BOOL(wp)
                if !b_flag {
                    if frm.onDeActivate != nil do frm->onDeActivate(&ea)
                }
                else {
                    if frm.onActivate != nil {frm->onActivate(&ea)}
                }
            }

        case WM_KEYUP, WM_SYSKEYUP :
            if frm.onKeyUp != nil {
                kea := new_key_event_args(wp)
                frm.onKeyUp(frm, &kea)
            }

        case WM_KEYDOWN, WM_SYSKEYDOWN :
            if frm.onKeyDown != nil {
                kea := new_key_event_args(wp)
                frm.onKeyDown(frm, &kea)
            }

        case WM_CHAR :
            if frm.onKeyPress != nil {
                kea := new_key_event_args(wp)
                frm.onKeyPress(frm, &kea)
                return 0
            }

        case WM_LBUTTONDOWN:
            frm._mDownHappened = true
            if frm.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseDown(frm, &mea)
            }

        case WM_RBUTTONDOWN:
            frm._mRDownHappened = true
            if frm.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onRightMouseDown(frm, &mea)
            }

        case WM_LBUTTONUP :
            if frm.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseUp(frm, &mea)
            }
            if frm._mDownHappened {
                frm._mDownHappened = false
                SendMessage(frm.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if frm.onMouseClick != nil {
                ea := new_event_args()
                frm->onMouseClick(&ea)
            }

        case WM_RBUTTONUP :
            if frm.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onRightMouseUp(frm, &mea)
            }
            if frm._mRDownHappened {
                frm._mRDownHappened = false
                SendMessage(frm.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            if frm.onRightClick != nil {
                ea := new_event_args()
                frm.onRightClick(frm, &ea)
            }

        case WM_LBUTTONDBLCLK :
            if frm.onDoubleClick != nil {
                ea := new_event_args()
                frm.onDoubleClick(frm, &ea)
                return 0
            }

        case WM_MOUSEWHEEL :
            if frm.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseScroll(frm, &mea)
            }

        case WM_MOUSEMOVE :
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
            if frm._isMouseTracking {frm._isMouseTracking = false }
            if frm.onMouseHover != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.onMouseHover(frm, &mea)
            }

        case WM_MOUSELEAVE :
            if frm._isMouseTracking {
                frm._isMouseTracking = false
                frm._isMouseEntered = false
            }

            if frm.onMouseLeave != nil {
                ea := new_event_args()
                frm.onMouseLeave(frm, &ea)
            }

        case WM_SIZING :
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
            sea := new_size_event_args(msg, wp, lp)
            if frm.onSizeChanged != nil {
                ea := new_event_args()
                frm.onSizeChanged(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVE :
            frm.xpos = get_x_lparam(lp)
            frm.ypos = get_y_lparam(lp)
            if frm.onMoved != nil {
                ea := new_event_args()
                frm.onMoved(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVING :
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
            if frm._drawMode != .Default {
                dc_handle := HDC(wp)
                set_back_clr_internal(frm, dc_handle)
                return 1
            }

        case WM_CLOSE :
            if frm.onClosing != nil {
                ea := new_event_args()
                frm.onClosing(frm, &ea)
                if ea.cancelled {
                    return 0
                }
            }


        case WM_NOTIFY :
            nm := direct_cast(lp, ^NMHDR)
            return SendMessage(nm.hwndFrom, CM_NOTIFY, wp, lp )

        case WM_DESTROY:
            if frm.onClosed != nil {
                ea:= new_event_args()
                frm.onClosed(frm, &ea)
            }
            form_dtor(frm) // Freeing all resources.
            if hw == app.mainHandle {

                PostQuitMessage(0)
                // if app.wftrack != nil do show_memory_report()
            }


        case :
            return DefWindowProc(hw, msg, wp, lp)

    }
    return DefWindowProc(hw, msg, wp, lp)
}
