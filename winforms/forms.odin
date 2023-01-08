
package winforms


import "core:fmt"
import "core:runtime"
nph : Hwnd
// Some better window colors
/*
    0xF5FFFA
    0xF5F5F5
    0xF8F8F8
    0xF8F8FF
    0xF0FFF0
    0xEEEEE4
*/
def_window_color :: 0xF5F5F5
def_font_name :: "Calibri"
def_font_size :: 12
empty_wstring := to_wstring(" ") // This is just for testing purpose. Remove it when you finished this lib.
app := start_app() // Global variable for storing data needed to create a window.
//mcd : MouseClickData

/*
    This type is used for holding information about the program for whole run time.
    We need to keep some info from the very beginning to the very end.
*/
@private
Application :: struct
{
    main_handle : Hwnd,
    main_loop_started : bool,
    class_name : string,
    h_instance : Hinstance,
    screen_width, screen_height : int,
    form_count : int,
    start_state : FormState,
    global_font : Font,
    iccx : INITCOMMONCONTROLSEX,
    //_back_color : uint,
}

@private
start_app :: proc() -> Application
{
    appl : Application
    appl.global_font = new_font(def_font_name, def_font_size)
    appl.class_name = "WingLib Window in Odin"
    appl.h_instance = GetModuleHandle(nil)
    appl.screen_width = int(GetSystemMetrics(0))
    appl.screen_height = int(GetSystemMetrics(1))

    appl.iccx.dwSize = size_of(appl.iccx)
    appl.iccx.dwIcc = ICC_STANDARD_CLASSES
    InitCommonControlsEx(&appl.iccx)    // Iinitializing standard common controls.
    // fmt.println("init commoms")
    return appl
}

Form :: struct
{
    using control : Control,  // By this, form is a child of control.
    start_pos : StartPosition,
    style : FormStyle,
    minimize_box, maximize_box : bool,
    window_state : FormState,

    load : EventHandler,
    activate,
    de_activate : EventHandler,
    moving, moved : EventHandler,
    resizing,resized : SizeEventHandler,

    minimized,
    maximized,
    restored,
    closing,
    closed : EventHandler,

    _is_loaded : bool,
    _gradient_style : GradientStyle,
    _gradient_color : GradientColors,
    _draw_mode : FormDrawMode,
    _cdraw_childs : [dynamic]Hwnd,
    _udraw_ids : map[Uint]Hwnd,
    // _combo_list : [dynamic]ComboInfo,
    _combo_data : [dynamic]ComboData,



    //cb_hwnd : Hwnd,
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
GradientColors :: struct {color1, color2 : RgbColor,}

new_form :: proc{new_form1, new_form2}

@private
new_form_internal :: proc(t : string = "", w : int = 500, h : int = 400) -> Form
{
    app.form_count += 1
    f : Form
    f.kind = .Form
    f.text = t == "" ? concat_number("Form_", app.form_count) : t
    f.width = w
    f.height = h
    f.start_pos = .Center
    f.style = .Default
    f.maximize_box = true
    f.minimize_box = true
    f.font = new_font()
    f._draw_mode = .Default
    f.back_color = def_window_color
    f._gradient_style = .Top_To_Bottom
    f.window_state = .Normal
    f._udraw_ids = make(map[Uint]Hwnd)
    return  f
}

@private
new_form1 :: proc() -> Form
{
    frm := new_form_internal()
    return frm
}

@private
new_form2 :: proc(txt : string, w : int = 500, h : int = 400) -> Form
{
    frm := new_form_internal(txt, w, h)
    return frm
}

@private
form_dtor :: proc(frm : ^Form)
{
    delete_gdi_object(frm.font.handle)
    delete(frm._udraw_ids)
    delete(frm._cdraw_childs)
    // delete(frm._combo_list)
    delete(frm._combo_data)
}

@private
set_form_font_internal :: proc(frm : ^Form)
{
    if app.global_font.handle == nil do CreateFont_handle(&app.global_font, frm.handle)
    if frm.font.name == def_font_name && frm.font.size == def_font_size
    {
        // User did not made any changes in font. So use default font handle.
        frm.font = app.global_font
        SendMessage(frm.handle, WM_SETFONT, Wparam(frm.font.handle), Lparam(1))
    }
    else
    {
        if frm.font.handle == nil
        {
            // User just changed the font name and/or size. Create the font handle
            CreateFont_handle(&frm.font, frm.handle)
            SendMessage(frm.handle, WM_SETFONT, Wparam(frm.font.handle), Lparam(1))
        }
        else { SendMessage(frm.handle, WM_SETFONT, Wparam(frm.font.handle), Lparam(1)) }
    }
}



create_form :: proc(frm : ^Form )
{
    if app.main_handle == nil {register_class()}
    if frm.back_color != def_window_color { frm._draw_mode = .flat_color }
    set_start_position(frm)
    set_form_style(frm)
    frm.handle = CreateWindowEx(  frm._ex_style,
                                    to_wstring(app.class_name),
                                    to_wstring(frm.text),
                                    frm._style,
                                    i32(frm.xpos),
                                    i32(frm.ypos),
                                    i32(frm.width),
                                    i32(frm.height),
                                    nil,
                                    nil,
                                    app.h_instance,
                                    nil )
    if frm.handle == nil { fmt.println("Error in CreateWindoeEx,", GetLastError()) }
    else
    {
        frm._is_created = true
        app.form_count += 1
        if app.main_handle == nil
        {
            app.main_handle = frm.handle
            app.start_state = frm.window_state
        }
        set_form_font_internal(frm)
        SetWindowLongPtr(frm.handle, GWLP_USERDATA, cast(LongPtr) cast(uintptr) frm)
    }

}

/* This will display the window.
    And it will check if the main loop is started or not.
    If not started, it will start the main loop */
start_form :: proc()
{
    ShowWindow(app.main_handle, cast(i32) app.start_state )
    //app.main_loop_started = true
    ms : Msg
    for GetMessage(&ms, nil, 0, 0) != 0
    {
        TranslateMessage(&ms)
        DispatchMessage(&ms)
    }
}

show_form :: proc(f : Form) { ShowWindow(f.handle, SW_SHOW) }
hide_form :: proc(f : Form) { ShowWindow(f.handle, SW_HIDE) }
set_form_state :: proc(frm : Form, state : FormState) { ShowWindow(frm.handle, cast(i32) state ) }

print_point :: proc(mea : ^MouseEventArgs) {
    @static x : int = 1
    fmt.printf("[%d] X: %d,  Y: %d\n", x, mea.x, mea.y)
    x+= 1
}

// Set the colors to draw a gradient background in form.
set_gradient_form :: proc(f : ^Form, clr1, clr2 : uint, style : GradientStyle = .Top_To_Bottom)
{
    f._gradient_color.color1 = new_rgb_color(clr1)
    f._gradient_color.color2 = new_rgb_color(clr2)
    f._draw_mode = .gradient
    f._gradient_style = style
    if f._is_created do InvalidateRect(f.handle, nil, true)
}


@private
register_class :: proc()
{
    win_class : WNDCLASSEXW
    win_class.cbSize = size_of(win_class)
    win_class.style = CS_HREDRAW | CS_VREDRAW
    win_class.lpfnWndProc = window_proc
    win_class.cbClsExtra = 0
    win_class.cbWndExtra = 0
    win_class.hInstance = app.h_instance
    win_class.hIcon = LoadIcon(nil, IDI_APPLICATION)
    win_class.hCursor = LoadCursor(nil, IDC_ARROW)
    win_class.hbrBackground = CreateSolidBrush(get_color_ref(def_window_color)) //cast(Hbrush) (cast(uintptr) Color_Window + 1)
    win_class.lpszMenuName = nil
    win_class.lpszClassName = to_wstring(app.class_name)

    res := RegisterClassEx(&win_class)
    //print("I have reached here")
    if res == 0 {print("reg window class error -- ", GetLastError())}
    //icc_ex := INITCOMMONCONTROLSEX{dw_size = size_of(INITCOMMONCONTROLSEX), dw_icc = ICC_STANDARD_CLASSES}
    //InitCommonControlsEx(&icc_ex)

}

@private
set_start_position :: proc(frm : ^Form)
{
    #partial switch frm.start_pos
    {
    case .Center:
        frm.xpos = (app.screen_width - frm.width) / 2
        frm.ypos = (app.screen_height - frm.height) / 2
    case .Top_Mid :
        frm.xpos = (app.screen_width - frm.width) / 2
    case .Top_Right :
        frm.xpos = app.screen_width - frm.width ;
    case .Mid_Left :
        frm.ypos = (app.screen_height - frm.height) / 2
    case .Mid_Right:
        frm.xpos = app.screen_width - frm.width ;
        frm.ypos = (app.screen_height - frm.height) / 2
    case .Bottom_Left:
        frm.ypos = app.screen_height - frm.height
    case .Bottom_Mid :
        frm.xpos = (app.screen_width - frm.width) / 2
        frm.ypos = app.screen_height - frm.height
    case .Bottom_Right :
        frm.xpos = app.screen_width - frm.width
        frm.ypos = app.screen_height - frm.height
    }
}

@private
set_form_style :: proc(frm : ^Form) {
    #partial switch frm.style {
        case .Default :
            frm._ex_style = normal_form_ex_style
            frm._style = normal_form_style
            if !frm.maximize_box do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimize_box do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_3D :
            frm._ex_style = fixed_3d_ex_style
            frm._style = fixed_3d_style
            if !frm.maximize_box do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimize_box do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_Dialog :
            frm._ex_style = fixed_dialog_ex_style
            frm._style = fixed_dialog_style
            if !frm.maximize_box do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimize_box do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_Single :
            frm._ex_style = fixed_single_ex_style
            frm._style = fixed_single_style
            if !frm.maximize_box do frm._style = frm._style ~ WS_MAXIMIZEBOX
            if !frm.minimize_box do frm._style = frm._style ~ WS_MINIMIZEBOX
        case .Fixed_Tool :
            frm._ex_style = fixed_tool_ex_style
            frm._style = sizable_tool_style
        case .Sizable_Tool :
            frm._ex_style = sizable_tool_ex_style
            frm._style = sizable_tool_style
    }
}

@private
track_mouse_move :: proc(hw : Hwnd) {
    tme : TRACKMOUSEEVENT
    tme.cbSize = size_of(tme)
    tme.dwFlags = TME_HOVER | TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    TrackMouseEvent(&tme)
}

@private
set_back_clr_internal :: proc(f : ^Form, hdc : Hdc) {
    rct : Rect
    hbr : Hbrush
    GetClientRect(f.handle, &rct)
    if f._draw_mode == .flat_color { hbr = CreateSolidBrush(get_color_ref(f.back_color)) }
    else if f._draw_mode == .gradient { hbr = create_gradient_brush(f._gradient_color, f._gradient_style, hdc, rct) }
    FillRect(hdc, &rct, hbr)
    DeleteObject(Hgdiobj(hbr))
}

FindHwnd :: enum {lb_hwnd, tb_hwnd}


@private // Display windows message names in wndproc function.
display_msg :: proc(umsg : u32, ) {
    @static counter : int = 1
    win_msg := cast(Msg_map) umsg
    ptf("[%d] Message -  %s\n", counter, win_msg)
    counter += 1
}

// It's a private function. Combobox module is the caller.
collect_combo_data :: proc(frm: ^Form, cd : ComboData) {append(&frm._combo_data, cd)}

// It's a private function. Combobox module is the caller.
update_combo_data :: proc(frm: ^Form, cd : ComboData) {
    for c in &frm._combo_data {
        if c.combo_id == cd.combo_id {
            c.combo_hwnd = cd.combo_hwnd
            c.list_box_hwnd = cd.list_box_hwnd
            return
        }
    }
}

@private
find_combo_data :: proc(frm : ^Form, list_hwnd : Hwnd) -> Hwnd {
    // We will search for the appropriate date in our combo data list.
    for cd in frm._combo_data {
        if cd.list_box_hwnd == list_hwnd {
            return cd.combo_hwnd
        }
    }
    return nil
}

@private
window_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam ) -> Lresult
{
    context = runtime.default_context()
    frm := direct_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^Form)
    //display_msg(msg)
    switch msg
    {


        // case WM_PARENTNOTIFY :
        //    // display_msg(msg)
        //     if lo_word(Dword(wp)) == WM_CREATE {
        //         chw := get_lparam_value(lp, Hwnd)
        //         return SendMessage(chw, CM_PARENTNOTIFY, 0, 0)
        //         //ptf("handle from parent notify - %d\n", chw)
        //     }

        case WM_HSCROLL :
            ctl_hw := direct_cast(lp, Hwnd)
            return SendMessage(ctl_hw, WM_HSCROLL, wp, lp)

        case WM_VSCROLL:
            ctl_hw := direct_cast(lp, Hwnd)
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
            ctl_hwnd, hwnd_found := frm._udraw_ids[Uint(wp)]
            if hwnd_found {
                return SendMessage(ctl_hwnd, CM_LABELDRAW, 0, lp)
            } else do return 0


        case WM_CTLCOLOREDIT :
            ctl_hwnd := direct_cast(lp, Hwnd)
            return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORSTATIC :
            ctl_hwnd := direct_cast(lp, Hwnd)
            return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORLISTBOX :
            /* If user uses a ComboBox, it contains a ListBox in it.
             * So, 'ctlHwnd' might be a handle of that ListBox. Or it might be a normal ListBox too.
             * So, we need to check it before disptch this message to that listbox.
             * Because, if it is from Combo's listbox, there is no Wndproc function for that ListBox. */
            ctl_hwnd := direct_cast(lp, Hwnd)
            cmb_hwnd := find_combo_data(frm, ctl_hwnd)
            if cmb_hwnd != nil {
                // This message is from a combo's listbox. Divert it to that combo box.
                return SendMessage(cmb_hwnd, CM_COMBOLBCOLOR, wp, lp)
            } else {
                // This message is from a normal listbox. send it to it's wndproc.
                return SendMessage(ctl_hwnd, CM_CTLLCOLOR, wp, lp)
            }

            // case WM_CTLCOLORBTN :
            //     ctl_hwnd := direct_cast(lp, Hwnd)
            //     return SendMessage(ctl_hwnd, WM_CTLCOLORBTN, wp, lp )

        case WM_COMMAND :
            ctl_hwnd := direct_cast(lp, Hwnd)
            SendMessage(ctl_hwnd, CM_CTLCOMMAND, wp, lp)

        case WM_SHOWWINDOW:
            if !frm._is_loaded {
                frm._is_loaded = true
                if frm.load != nil {
                    ea := new_event_args()
                    frm->load(&ea)
                    return 0
                }
            }

        case WM_ACTIVATEAPP :
            if frm.activate != nil || frm.de_activate != nil {
                ea := new_event_args()
                b_flag := Bool(wp)
                if !b_flag {
                    if frm.de_activate != nil do frm->de_activate(&ea)
                }
                else {
                    if frm.activate != nil {frm->activate(&ea)}
                }
            }

        case WM_KEYUP, WM_SYSKEYUP :
            if frm.key_up != nil {
                kea := new_key_event_args(wp)
                frm.key_up(frm, &kea)
            }

        case WM_KEYDOWN, WM_SYSKEYDOWN :
            if frm.key_down != nil {
                kea := new_key_event_args(wp)
                frm.key_down(frm, &kea)
            }

        case WM_CHAR :
            if frm.key_press != nil {
                kea := new_key_event_args(wp)
                frm.key_press(frm, &kea)
                return 0
            }

        case WM_LBUTTONDOWN:
            frm._mdown_happened = true
            if frm.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.left_mouse_down(frm, &mea)
            }

        case WM_RBUTTONDOWN:
            frm._mrdown_happened = true
            if frm.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.right_mouse_down(frm, &mea)
            }

        case WM_LBUTTONUP :
            if frm.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.left_mouse_up(frm, &mea)
            }
            if frm._mdown_happened {
                frm._mdown_happened = false
                SendMessage(frm.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if frm.mouse_click != nil {
                ea := new_event_args()
                frm->mouse_click(&ea)
            }

        case WM_RBUTTONUP :
            if frm.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.right_mouse_up(frm, &mea)
            }
            if frm._mrdown_happened {
                frm._mrdown_happened = false
                SendMessage(frm.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            if frm.right_click != nil {
                ea := new_event_args()
                frm.right_click(frm, &ea)
            }

        case WM_LBUTTONDBLCLK :
            if frm.double_click != nil {
                ea := new_event_args()
                frm.double_click(frm, &ea)
                return 0
            }

        case WM_MOUSEWHEEL :
            if frm.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.mouse_scroll(frm, &mea)
            }

        case WM_MOUSEMOVE :
            if !frm._is_mouse_tracking {
                frm._is_mouse_tracking = true
                track_mouse_move(hw)
                if !frm._is_mouse_entered {
                    if frm.mouse_enter != nil {
                        frm._is_mouse_entered = true
                        ea := new_event_args()
                        frm.mouse_enter(frm, &ea)
                    }
                }
            } //---------------------------------------

            if frm.mouse_move != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.mouse_move(frm, &mea)
            }

        case WM_MOUSEHOVER :
            if frm._is_mouse_tracking {frm._is_mouse_tracking = false }
            if frm.mouse_hover != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.mouse_hover(frm, &mea)
            }

        case WM_MOUSELEAVE :
            if frm._is_mouse_tracking {
                frm._is_mouse_tracking = false
                frm._is_mouse_entered = false
            }

            if frm.mouse_leave != nil {
                ea := new_event_args()
                frm.mouse_leave(frm, &ea)
            }

        case WM_SIZING :
            sea := new_size_event_args(msg, wp, lp)
            frm.width = int(sea.form_rect.right - sea.form_rect.left)
            frm.height = int(sea.form_rect.bottom - sea.form_rect.top)
            if frm.resizing != nil {
                frm.resizing(frm, &sea)
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
                if frm.size_changing != nil {
                    ea := new_event_args()
                    frm.size_changing(frm, &ea)
                    return 1
                }
            }

        //case WM_WINDOWPOSCHANGED:
            //alert("Pos changed")
            //wps := direct_cast(lp, ^WINDOWPOS) */

        case WM_SIZE :
            sea := new_size_event_args(msg, wp, lp)
            if frm.size_changed != nil {
                ea := new_event_args()
                frm.size_changed(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVE :
            frm.xpos = get_x_lparam(lp)
            frm.ypos = get_y_lparam(lp)
            if frm.moved != nil {
                ea := new_event_args()
                frm.moved(frm, &ea)
                return 0
            }
            return 0

        case WM_MOVING :
            rct := direct_cast(lp, ^Rect)
            frm.xpos = int(rct.left)
            frm.ypos = int(rct.top)
            if frm.moving != nil {
                ea := new_event_args()
                frm.moving(frm, &ea)
                return Lresult(1)
            }
            return 0

        case WM_SYSCOMMAND :
            sys_msg := uint(wp & 0xFFF0)
            switch sys_msg {
            case SC_MINIMIZE :
                if frm.minimized != nil {
                    ea := new_event_args()
                    frm.minimized(frm, &ea)
                }
            case SC_MAXIMIZE :
                if frm.maximized != nil {
                    ea := new_event_args()
                    frm.maximized(frm, &ea)
                }
            case SC_RESTORE :
                if frm.restored != nil {
                    ea := new_event_args()
                    frm.restored(frm, &ea)
                    }
            }
        case WM_ERASEBKGND :
            if frm._draw_mode != .Default {
                dc_handle := Hdc(wp)
                set_back_clr_internal(frm, dc_handle)
                return 1
            }

        case WM_CLOSE :
            if frm.closing != nil {
                ea := new_event_args()
                frm.closing(frm, &ea)
                if ea.cancelled {
                    return 0
                }
            }


        case WM_NOTIFY :

            //nmcd := get_lparam_value(lp, ^NMCUSTOMDRAW)
            nm := direct_cast(lp, ^NMHDR)
            return SendMessage(nm.hwndFrom, CM_NOTIFY, wp, lp )

            //-------------------------------------------------------
            //is_hwnd := slice.contains(frm._cdraw_childs[:], nmcd.hdr.hwnd_from )

        case WM_DESTROY:
            if frm.closed != nil {
                ea:= new_event_args()
                frm.closed(frm, &ea)
            }
            form_dtor(frm) // Freeing all resources.
            if hw == app.main_handle {
                PostQuitMessage(0)
            }


        case :
            return DefWindowProc(hw, msg, wp, lp)

    }
    return DefWindowProc(hw, msg, wp, lp)
}
