
package winforms


import "core:fmt"
import "core:runtime"

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
app := start_app() // Global variable for storing data needed to create a window.
//mcd : MouseClickData

/* 
    This type is used for holding information about the program for whole run time.
    We need to keep some info from the very beginning to the very end.
*/
@private Application :: struct {
    main_handle : Hwnd,
    main_loop_started : bool,
    class_name : string,
    h_instance : Hinstance,
    screen_width, screen_height : int,
    form_count : int,
    start_state : FormState,
    global_font : Font,
    date_class_init : b64,
    //_back_color : uint,
}

@private start_app :: proc() -> Application {
    appl : Application
    appl.global_font = new_font(def_font_name, def_font_size)
    appl.class_name = "WingLib_Form"
    appl.h_instance = get_module_handle_w(nil)
    appl.screen_width = int(get_system_metrics(0))
    appl.screen_height = int(get_system_metrics(1))

    return appl
}

Form :: struct {
    using control : Control,  // By this, form is a child of control.
    start_pos : StartPosition,
    style : FormStyle,
    minimize_box, maximize_box : b32,
    window_state : FormState,    

    load : EventHandler,
    activate,
    de_activate : EventHandler,
    moving, moved : MoveEventHandler, 
    
    minimized, 
    maximized, 
    restored, 
    closing, 
    closed : EventHandler,

    _is_loaded : b32,   
    _gradient_style : GradientStyle,
    _gradient_color : GradientColors,
    _draw_mode : FormDrawMode,
    _cdraw_childs : [dynamic]Hwnd,
    _udraw_ids : map[Uint]Hwnd,
    _combo_list : [dynamic]ComboInfo,
   
    
    //cb_hwnd : Hwnd,
}

FormDrawMode :: enum { default, flat_color, gradient,}
//GradientStyle :: enum {top_to_bottom, left_to_right,}
StartPosition :: enum {
    top_left,
    top_mid,
    top_right,
    mid_left,
    center,
    mid_right,
    bottom_left,
    bottom_mid,
    bottom_right,
    manual,
}

FormStyle :: enum { default, fixed_single, fixed_3d, fixed_dialog, fixed_tool, sizable_tool, }
FormState :: enum {normal = 1, minimized, maximized}
GradientColors :: struct {color1, color2 : RgbColor,}

new_form :: proc{new_form1, new_form2} 

@private new_form_internal :: proc(t : string = "", w : int = 500, h : int = 400) -> Form {
    app.form_count += 1
    f : Form
    f.kind = .form    
    f.text = t == "" ? concat_number("Form_", app.form_count) : t
    f.width = w
    f.height = h
    f.start_pos = .center
    f.style = .default
    f.maximize_box = true
    f.minimize_box = true
    f.font = new_font()
    f._draw_mode = .default
    f.back_color = def_window_color
    f._gradient_style = .top_to_bottom
    f.window_state = .normal
    f._udraw_ids = make(map[Uint]Hwnd)
    return  f
}

@private new_form1 :: proc() -> Form {
    frm := new_form_internal()
    return frm
}

@private new_form2 :: proc(txt : string, w : int = 500, h : int = 400) -> Form {
    frm := new_form_internal(txt, w, h)
    return frm
}

@private form_dtor :: proc(frm : ^Form) {
    delete_gdi_object(frm.font.handle)
    delete(frm._udraw_ids)
    delete(frm._cdraw_childs)
    delete(frm._combo_list)
    
}

@private set_form_font_internal :: proc(frm : ^Form) {
    if app.global_font.handle == nil do create_font_handle(&app.global_font, frm.handle)
    if frm.font.name == def_font_name && frm.font.size == def_font_size {
        // User did not made any changes in font. So use default font handle.
        frm.font = app.global_font
        send_message(frm.handle, WM_SETFONT, Wparam(frm.font.handle), Lparam(1))
    }
    else {
        if frm.font.handle == nil {
            // User just changed the font name and/or size. Create the font handle
            create_font_handle(&frm.font, frm.handle)
            send_message(frm.handle, WM_SETFONT, Wparam(frm.font.handle), Lparam(1))
        }
        else {
            send_message(frm.handle, WM_SETFONT, Wparam(frm.font.handle), Lparam(1))
        }
    }
}



create_form :: proc(frm : ^Form ) {    
    if app.main_handle == nil {register_class()}
    if frm.back_color != def_window_color {
        frm._draw_mode = .flat_color
    }
    set_start_position(frm)
    set_form_style(frm)
    frm.handle = create_window_ex(  frm._ex_style, 
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
    if frm.handle == nil {        
        fmt.println("Error in CreateWindoeEx,", get_last_error())        
    }
    else {
        frm._is_created = true 
        app.form_count += 1       
        if app.main_handle == nil {
            app.main_handle = frm.handle
            app.start_state = frm.window_state
        }
        set_form_font_internal(frm)
        set_window_long_ptr(frm.handle, GWLP_USERDATA, cast(LongPtr) cast(uintptr) frm)        
    }
    
}

/* This will display the window.
    And it will check if the main loop is started or not.
    If not started, it will start the main loop */
start_form :: proc() {
    showing_window(app.main_handle, cast(i32) app.start_state )    
    //app.main_loop_started = true
    ms : Msg
    for get_message_w(&ms, nil, 0, 0) != 0 {        
        translate_message(&ms)
        dispatch_message_w(&ms)
    }    
}

show_form :: proc(f : Form) { showing_window(f.handle, SW_SHOW) }
hide_form :: proc(f : Form) { showing_window(f.handle, SW_HIDE) }
set_form_state :: proc(frm : Form, state : FormState) { showing_window(frm.handle, cast(i32) state ) }

// Set the colors to draw a gradient background in form.
set_gradient_form :: proc(f : ^Form, clr1, clr2 : uint, style : GradientStyle = .top_to_bottom) {
    f._gradient_color.color1 = new_rgb_color(clr1)
    f._gradient_color.color2 = new_rgb_color(clr2)
    f._draw_mode = .gradient
    f._gradient_style = style
    if f._is_created do invalidate_rect(f.handle, nil, true)    
}


@private register_class :: proc() {
    win_class : WNDCLASSEXW
    win_class.cbSize = size_of(win_class)
    win_class.style = CS_HREDRAW | CS_VREDRAW
    win_class.lpfnWndProc = window_proc
    win_class.cbClsExtra = 0
    win_class.cbWndExtra = 0
    win_class.hInstance = app.h_instance
    win_class.hIcon = load_icon_w(nil, IDI_APPLICATION)
    win_class.hCursor = load_cursor_w(nil, IDC_ARROW)
    win_class.hbrBackground = create_solid_brush(get_color_ref(def_window_color)) //cast(Hbrush) (cast(uintptr) Color_Window + 1)
    win_class.lpszMenuName = nil
    win_class.lpszClassName = to_wstring(app.class_name)

    res := register_class_ex_w(&win_class)
    if res == 0 {print("reg window class error -- ", get_last_error())}
    //icc_ex := INITCOMMONCONTROLSEX{dw_size = size_of(INITCOMMONCONTROLSEX), dw_icc = ICC_STANDARD_CLASSES}
    //init_comm_ctrl_ex(&icc_ex)

}

@private set_start_position :: proc(frm : ^Form) {
    #partial switch frm.start_pos {
    case .center:
        frm.xpos = (app.screen_width - frm.width) / 2
        frm.ypos = (app.screen_height - frm.height) / 2
    case .top_mid :
        frm.xpos = (app.screen_width - frm.width) / 2
    case .top_right :
        frm.xpos = app.screen_width - frm.width ;
    case .mid_left :
        frm.ypos = (app.screen_height - frm.height) / 2
    case .mid_right:
        frm.xpos = app.screen_width - frm.width ;
        frm.ypos = (app.screen_height - frm.height) / 2
    case .bottom_left:
        frm.ypos = app.screen_height - frm.height
    case .bottom_mid :
        frm.xpos = (app.screen_width - frm.width) / 2
        frm.ypos = app.screen_height - frm.height
    case .bottom_right :
        frm.xpos = app.screen_width - frm.width
        frm.ypos = app.screen_height - frm.height
    }
}

@private set_form_style :: proc(frm : ^Form) {
    #partial switch frm.style {
        case .default :
            frm._ex_style = normal_form_ex_style
            frm._style = normal_form_style
            if !frm.maximize_box {frm._style = frm._style ~ WS_MAXIMIZEBOX }
            if !frm.minimize_box {frm._style = frm._style ~ WS_MINIMIZEBOX }
        case .fixed_3d :
            frm._ex_style = fixed_3d_ex_style
            frm._style = fixed_3d_style
            if !frm.maximize_box {frm._style = frm._style ~ WS_MAXIMIZEBOX }
            if !frm.minimize_box {frm._style = frm._style ~ WS_MINIMIZEBOX }
        case .fixed_dialog :
            frm._ex_style = fixed_dialog_ex_style
            frm._style = fixed_dialog_style
            if !frm.maximize_box {frm._style = frm._style ~ WS_MAXIMIZEBOX }
            if !frm.minimize_box {frm._style = frm._style ~ WS_MINIMIZEBOX }
        case .fixed_single :
            frm._ex_style = fixed_single_ex_style
            frm._style = fixed_single_style
            if !frm.maximize_box {frm._style = frm._style ~ WS_MAXIMIZEBOX }
            if !frm.minimize_box {frm._style = frm._style ~ WS_MINIMIZEBOX }    
        case .fixed_tool :
            frm._ex_style = fixed_tool_ex_style
            frm._style = sizable_tool_style
        case .sizable_tool :
            frm._ex_style = sizable_tool_ex_style
            frm._style = sizable_tool_style
    }
}

@private track_mouse_move :: proc(hw : Hwnd) {
    tme : TrackMouseEvent
    tme.cbSize = size_of(tme)
    tme.dwFlags = TME_HOVER | TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    track_mouse_event(&tme)
}

@private set_back_clr_internal :: proc(f : ^Form, hdc : Hdc) {
    rct : Rect
    hbr : Hbrush     
    get_client_rect(f.handle, &rct)
    if f._draw_mode == .flat_color {
        hbr = create_solid_brush(get_color_ref(f.back_color))
    }
    else if f._draw_mode == .gradient {        
        hbr = create_gradient_brush(f._gradient_color, f._gradient_style, hdc, rct)
    }
    fill_rect(hdc, &rct, hbr)
    delete_object(Hgdiobj(hbr))
}

FindHwnd :: enum {lb_hwnd, tb_hwnd}

@private find_combo_data :: proc(frm : ^Form, hw : Hwnd, item : FindHwnd) -> ComboInfo {
    ci : ComboInfo
    if item == .lb_hwnd {
        for c in frm._combo_list {        
            if c.lb_handle == hw {
                ci = c
                break
            }
        }
    } else {
        for c in frm._combo_list {        
            if c.tb_handle == hw {
                ci = c
                break
            }
        }
    }    
    return ci
}


@private display_msg :: proc(umsg : u32, ) {
    @static counter : int = 1
    mmap := make_mes_map()
    for k, v in mmap {
        if v == umsg {
            ptf("message number - [%d] - %s\n", counter, k)
            counter += 1
            break
        }
    }
}


@private window_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam ) -> Lresult {
    context = runtime.default_context()    
    frm := direct_cast(get_window_long_ptr(hw, GWLP_USERDATA), ^Form)   
   // display_msg(msg)
    switch msg {          

        // case WM_PARENTNOTIFY :
        //    // display_msg(msg)
        //     if lo_word(Dword(wp)) == WM_CREATE {
        //         chw := get_lparam_value(lp, Hwnd)
        //         return send_message(chw, CM_PARENTNOTIFY, 0, 0)
        //         //ptf("handle from parent notify - %d\n", chw)
        //     }

        case WM_PAINT :
            if frm.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                frm.paint(frm, &pea)
                end_paint(hw, &ps)
                return 0
            }

        case WM_DRAWITEM :            
            ctl_hwnd, hwnd_found := frm._udraw_ids[Uint(wp)]
            if hwnd_found {                
                return send_message(ctl_hwnd, CM_LABELDRAW, 0, lp)
            } else do return 0     

        case WM_CTLCOLOREDIT :
            ctl_hwnd := get_lparam_value(lp, Hwnd)            
            ci := find_combo_data(frm, ctl_hwnd, FindHwnd.tb_hwnd)
            if ci.combo_handle == nil {
                return send_message(ctl_hwnd, CM_CTLLCOLOR, wp, 0)
            } else {  
                if !ci.no_tb_msg do return send_message(ci.combo_handle, CM_COMBOTBCOLOR, wp, 0)
            }
            
        case WM_CTLCOLORSTATIC :
            ctl_hwnd := get_lparam_value(lp, Hwnd)            
            return send_message(ctl_hwnd, CM_CTLLCOLOR, wp, lp)

        case WM_CTLCOLORLISTBOX :
            ctl_hwnd := get_lparam_value(lp, Hwnd)
            //print("list box handle - ", ctl_hwnd)
            ci := find_combo_data(frm, ctl_hwnd, FindHwnd.lb_hwnd)
            if ci.combo_handle != nil {
                return send_message(ci.combo_handle, CM_COMBOLBCOLOR, wp, 0)
            } // Need and else statement when e create ListBox
        
        
        
        case WM_COMMAND :
            ctl_hwnd := get_lparam_value(lp, Hwnd)
            send_message(ctl_hwnd, CM_CTLCOMMAND, wp, lp)

        case WM_SHOWWINDOW:
            if !frm._is_loaded {
                frm._is_loaded = true
                if frm.load != nil {
                    ea := new_event_args()
                    frm.load(frm, &ea)
                }
            }

        case WM_ACTIVATEAPP :
            if frm.activate != nil || frm.de_activate != nil {
                ea := new_event_args()
                b_flag := Bool(wp)
                if !b_flag {
                    if frm.de_activate != nil do frm.de_activate(frm, &ea)
                }
                else {
                    if frm.activate != nil {frm.activate(frm, &ea)}
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
        
        
            if frm.right_click != nil {
                mea := new_event_args()
                frm.right_click(frm, &mea)
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
            if frm._mdown_happened do send_message(frm.handle, CM_LMOUSECLICK, 0, 0) 
            
        case CM_LMOUSECLICK :
            frm._mdown_happened = false
            if frm.mouse_click != nil {
                ea := new_event_args()
                frm.mouse_click(frm, &ea)
                return 0
            }
            
        case WM_RBUTTONUP :            
            if frm.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                frm.right_mouse_up(frm, &mea)
            } 
            if frm._mrdown_happened do send_message(frm.handle, CM_RMOUSECLICK, 0, 0)           

        case CM_RMOUSECLICK :
            frm._mrdown_happened = false
            if frm.right_click != nil {
                ea := new_event_args()
                frm.right_click(frm, &ea)
                return 0
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
            }
            //---------------------------------------
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
            if frm.size_changing != nil {
                ea := new_event_args()
                frm.size_changing(frm, &ea)
                return 1
            }
        
        case WM_SIZE :
            if frm.size_changed != nil {
                ea := new_event_args()
                frm.size_changed(frm, &ea)
                return 1
            }
        case WM_MOVE :
            if frm.moved != nil {
                mea := new_move_event_args(msg, lp)
                frm.moved(frm, &mea)
                return 0
            }

        case WM_MOVING :
            if frm.moving != nil {
                mea := new_move_event_args(msg, lp)                
                frm.moving(frm, &mea)
                return Lresult(1)
            }

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
            if frm._draw_mode != .default {
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
            return send_message(nm.hwndFrom, CM_NOTIFY, 0, lp )

            //-------------------------------------------------------
            //is_hwnd := slice.contains(frm._cdraw_childs[:], nmcd.hdr.hwnd_from )                     

        case WM_DESTROY:
            if frm.closed != nil {
                ea:= new_event_args()
                frm.closed(frm, &ea)
            }

            form_dtor(frm) // Freeing all resources. 

            if hw == app.main_handle {
                post_quit_message(0)
            }        
        }
    return def_window_proc_w(hw, msg, wp, lp)
}
