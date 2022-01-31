// Created on 30-Jan-2022 12:37 AM

package winforms
import "core:runtime"

ICC_PROGRESS_CLASS :: 0x20

// Constants
    
    PBS_SMOOTH :: 0x1
    PBS_VERTICAL :: 0x4
    PBS_MARQUEE :: 0x8
    PBM_SETBKCOLOR :: (0x2000 + 1)
    PBM_SETMARQUEE :: (WM_USER + 10)
// Constants End

WcProgressClassW : wstring 
ProgressBar :: struct {
    using control : Control,
    min_value,
    max_value : int,
    step : int,
    style : BarStyle,
    alignment : BarAlign,
    value : int,
    

    _theme : BarTheme,
    _is_paused : bool,



}

BarStyle :: enum {block, marquee}
BarAlign :: enum {horizontal, vertical}
BarTheme :: enum {system_color, custom_color }

@private pb_ctor :: proc(f : ^Form, x, y, w, h : int) -> ProgressBar {
    if WcProgressClassW == nil {
        WcProgressClassW = to_wstring("msctls_progress32")
        app.iccx.dwIcc = ICC_PROGRESS_CLASS
        init_comm_ctrl_ex(&app.iccx)
    }
    pb : ProgressBar
    pb.kind = .progress_bar
    pb.parent = f
    pb.font = f.font
    pb.xpos = x
    pb.ypos = y
    pb.width = w
    pb.height = h
    pb.min_value = 0
    pb.max_value = 100
    pb.step = 1
    

    pb._style = WS_CHILD | WS_VISIBLE | WS_TABSTOP | PBS_SMOOTH
    pb._ex_style = 0

    return pb
} 

@private pb_dtor :: proc(pb : ^ProgressBar) {
    
}

new_progressbar :: proc{pb_new1, pb_new2}

@private pb_new1 :: proc(parent : ^Form) -> ProgressBar {
    pb := pb_ctor(parent, 10, 10, 150, 25)
    return pb
}

@private pb_new2 :: proc(parent : ^Form, x, y, w, h : int) -> ProgressBar {
    pb := pb_ctor(parent, x, y, w, h)
    return pb
}

@private pb_adjust_styles :: proc(pb : ^ProgressBar) {
    if pb.style == .marquee do pb._style |= PBS_MARQUEE
    if pb.alignment == .vertical do pb._style |= PBS_VERTICAL
    

}

// Remove visual styles from progress bar. 
// You can set back color & fore color now. 
progressbar_set_theme :: proc(pb : ^ProgressBar, border : bool, fclr : uint, bclr : uint = 0xFFFFFF) {
    pb._theme = .custom_color
    pb.fore_color = fclr
    pb.back_color = bclr
    if border do pb._style |= WS_BORDER
}

// Increment progress bar value one step.
progressbar_increment :: proc(pb : ^ProgressBar) {send_message(pb.handle, PBM_STEPIT, 0, 0)}

// Start marquee animation in progress bar. 
progressbar_start_marquee :: proc(pb : ^ProgressBar, speed : int = 30) {  
    if pb.style == .marquee {
        pb._style |= PBS_MARQUEE
        set_window_long_ptr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
        send_message(pb.handle, PBM_SETMARQUEE, Wparam(1), Lparam(i32(speed)))
    }    
}

// Pause marquee animation in progress bar
progressbar_pause_marquee :: proc(pb : ^ProgressBar) { 
    if pb.style == .marquee {        
        send_message(pb.handle, PBM_SETMARQUEE, Wparam(0), Lparam(0))
        pb._is_paused = true
    }
}

// Restart marquee animation in a paused progress bar
progressbar_restart_marquee :: proc(pb : ^ProgressBar) { 
    if pb.style == .marquee && pb._is_paused {
        send_message(pb.handle, PBM_SETMARQUEE, Wparam(1), Lparam(0))
        pb._is_paused = false
    }
}

// Stop marquee animation in progress bar.
progressbar_stop_marquee :: proc(pb : ^ProgressBar) {  
    if pb.style == .marquee {
        send_message(pb.handle, PBM_SETMARQUEE, Wparam(0), Lparam(0))
        pb._style ~= PBS_MARQUEE
        set_window_long_ptr(pb.handle, GWL_STYLE, LongPtr(pb._style) )        
    }
}

// Toggle the style of progress bar. 
// If it is a block style, it will be marquee and vice versa.
progressbar_change_style :: proc(pb : ^ProgressBar) { 
    if pb.style == .block {
        pb._style |= PBS_MARQUEE
        set_window_long_ptr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
        pb.style = .marquee
    } else {
        pb._style ~= PBS_MARQUEE
        set_window_long_ptr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
        pb.style = .block
    }
}

// Set the value for progress bar. Only applicable for block styles
progressbar_set_value :: proc(pb : ^ProgressBar, ival : int) { 
    if pb.style == .block {
        send_message(pb.handle, PBM_SETPOS, Wparam(i32(ival)), 0)
        pb.value = ival
    }
}



@private pb_set_range_internal :: proc(pb : ^ProgressBar) {
    if pb.min_value != 0 || pb.max_value != 100 {
        wpm := Wparam(i32(pb.min_value))
        lpm := Lparam(i32(pb.max_value))
        send_message(pb.handle, PBM_SETRANGE32, wpm, lpm)
    }
    send_message(pb.handle, PBM_SETSTEP, Wparam(i32(pb.step)), 0)
}

// Create the handle of a progress bar
create_progressbar :: proc(pb : ^ProgressBar) {
    _global_ctl_id += 1
    pb.control_id = _global_ctl_id 
    pb_adjust_styles(pb)
    pb.handle = create_window_ex(   pb._ex_style, 
                                    WcProgressClassW, 
                                    to_wstring(pb.text),
                                    pb._style, 
                                    i32(pb.xpos), 
                                    i32(pb.ypos), 
                                    i32(pb.width), 
                                    i32(pb.height),
                                    pb.parent.handle, 
                                    direct_cast(pb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if pb.handle != nil {
        pb._is_created = true
        set_subclass(pb, pb_wnd_proc) 
        setfont_internal(pb)
        pb_set_range_internal(pb)
        if pb._theme == .custom_color {
            set_window_theme(pb.handle, empty_wstring, empty_wstring)
            send_message(pb.handle, PBM_SETBARCOLOR, 0, Lparam(get_color_ref(pb.fore_color)))
            if pb.back_color != 0xFFFFFF do send_message(pb.handle, PBM_SETBKCOLOR, 0, Lparam(get_color_ref(pb.back_color)))
        }
 
    }
}

@private pb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {    
    
    context = runtime.default_context()
   // ps : PAINTSTRUCT
    //frb := create_solid_brush(get_color_ref(0x0000FF))
    pb := control_cast(ProgressBar, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY :
            remove_subclass(pb)
        
        case WM_PAINT :
            if pb.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                pb.paint(pb, &pea)
                end_paint(hw, &ps)
                return 0
            }
        case WM_LBUTTONDOWN:
           // pb._draw_focus_rct = true
            pb._mdown_happened = true
            if pb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.left_mouse_down(pb, &mea)
                return 0
            }
            

        case WM_RBUTTONDOWN :
            pb._mrdown_happened = true
            if pb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.right_mouse_down(pb, &mea)
            }
            
        case WM_LBUTTONUP :
            if pb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.left_mouse_up(pb, &mea)
            }
            if pb._mdown_happened do send_message(pb.handle, CM_LMOUSECLICK, 0, 0)

        case CM_LMOUSECLICK :
            pb._mdown_happened = false
            if pb.mouse_click != nil {
                ea := new_event_args()
                pb.mouse_click(pb, &ea)
                return 0
            }
        
        case WM_LBUTTONDBLCLK :
            if pb.double_click != nil {
                ea := new_event_args()
                pb.double_click(pb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if pb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.right_mouse_up(pb, &mea)
            }
            if pb._mrdown_happened do send_message(pb.handle, CM_LMOUSECLICK, 0, 0) 
            
        case CM_RMOUSECLICK :
            pb._mrdown_happened = false
            if pb.right_click != nil {
                ea := new_event_args()
                pb.right_click(pb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if pb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.mouse_scroll(pb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if pb._is_mouse_entered {
                if pb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    pb.mouse_move(pb, &mea)
                }
            }
            else {
                pb._is_mouse_entered = true
                if pb.mouse_enter != nil  {
                    ea := new_event_args()
                    pb.mouse_enter(pb, &ea)
                }
            }
        
        case WM_MOUSELEAVE :
            pb._is_mouse_entered = false
            if pb.mouse_leave != nil {
                ea := new_event_args()
                pb.mouse_leave(pb, &ea)
            }
            
                
               
    }
    return def_subclass_proc(hw, msg, wp, lp)
}