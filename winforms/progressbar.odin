// Created on 30-Jan-2022 12:37 AM

package winforms
import "core:runtime"
// import "core:fmt"

ICC_PROGRESS_CLASS :: 0x20

// Constants
    
    PBS_SMOOTH :: 0x1
    PBS_VERTICAL :: 0x4
    PBS_MARQUEE :: 0x8
    PBM_SETBKCOLOR :: (0x2000 + 1)
    PBM_SETMARQUEE :: (WM_USER + 10)

    PBTM :: enum {
        PP_BAR = 1,
        PP_BARVERT = 2,
        PP_CHUNK = 3,
        PP_CHUNKVERT = 4,
        PP_FILL = 5,
        PP_FILLVERT = 6,
        PP_PULSEOVERLAY = 7,
        PP_MOVEOVERLAY = 8,
        PP_PULSEOVERLAYVERT = 9,
        PP_MOVEOVERLAYVERT = 10,
        PP_TRANSPARENTBAR = 11,
        PP_TRANSPARENTBARVERT = 12,
    }


// Constants End

WcProgressClassW : wstring 
ProgressBar :: struct {
    using control : Control,
    min_value,
    max_value : int,
    step : int,
    style : BarStyle,
    orientation : BarAlign,
    value : int,
    

    _theme : BarTheme,
    _is_paused : bool,
    _hvstm : Htheme,



}

BarStyle :: enum {Block, Marquee}
BarAlign :: enum {Horizontal, Vertical}
BarTheme :: enum {System_Color, Custom_Color }

@private pb_ctor :: proc(f : ^Form, x, y, w, h : int) -> ProgressBar {
    if WcProgressClassW == nil {
        WcProgressClassW = to_wstring("msctls_progress32")
        app.iccx.dwIcc = ICC_PROGRESS_CLASS
        InitCommonControlsEx(&app.iccx)
    }
    pb : ProgressBar
    pb.kind = .Progress_Bar
    pb.parent = f
    pb.font = f.font
    pb.xpos = x
    pb.ypos = y
    pb.width = w
    pb.height = h
    pb.min_value = 0
    pb.max_value = 100
    pb.step = 1
    pb._theme = .System_Color
    pb._cls_name = WcProgressClassW
    pb._before_creation = cast(CreateDelegate) pb_before_creation
	pb._after_creation = cast(CreateDelegate) pb_after_creation

    pb._style = WS_CHILD | WS_VISIBLE | WS_TABSTOP | PBS_SMOOTH 
    pb._ex_style = WS_EX_STATICEDGE

    return pb
} 

@private pb_dtor :: proc(pb : ^ProgressBar) {
    if pb._hvstm != nil do CloseThemeData(pb._hvstm)
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
    if pb.style == .Marquee do pb._style |= PBS_MARQUEE
    if pb.orientation == .Vertical do pb._style |= PBS_VERTICAL
}

// Remove visual styles from progress bar. 
// You can set back color & fore color now. 
// progressbar_set_theme :: proc(pb : ^ProgressBar, border : bool, fclr : uint, bclr : uint = 0xFFFFFF) {
//     pb._theme = .custom_color
//     pb.fore_color = fclr
//     pb.back_color = bclr
//     //if border do pb._style |= WS_BORDER
// }

// Increment progress bar value one step.
progressbar_increment :: proc(pb : ^ProgressBar) {SendMessage(pb.handle, PBM_STEPIT, 0, 0)}

// Start marquee animation in progress bar. 
progressbar_start_marquee :: proc(pb : ^ProgressBar, speed : int = 30) {  
    if pb.style == .Marquee {
        pb._style |= PBS_MARQUEE
        SetWindowLongPtr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
        SendMessage(pb.handle, PBM_SETMARQUEE, Wparam(1), Lparam(i32(speed)))
    }    
}

// Pause marquee animation in progress bar
progressbar_pause_marquee :: proc(pb : ^ProgressBar) { 
    if pb.style == .Marquee {        
        SendMessage(pb.handle, PBM_SETMARQUEE, Wparam(0), Lparam(0))
        pb._is_paused = true
    }
}

// Restart marquee animation in a paused progress bar
progressbar_restart_marquee :: proc(pb : ^ProgressBar) { 
    if pb.style == .Marquee && pb._is_paused {
        SendMessage(pb.handle, PBM_SETMARQUEE, Wparam(1), Lparam(0))
        pb._is_paused = false
    }
}

// Stop marquee animation in progress bar.
progressbar_stop_marquee :: proc(pb : ^ProgressBar) {  
    if pb.style == .Marquee {
        SendMessage(pb.handle, PBM_SETMARQUEE, Wparam(0), Lparam(0))
        pb._style ~= PBS_MARQUEE
        SetWindowLongPtr(pb.handle, GWL_STYLE, LongPtr(pb._style) )        
    }
}

// Toggle the style of progress bar. 
// If it is a block style, it will be marquee and vice versa.
progressbar_change_style :: proc(pb : ^ProgressBar) { 
    if pb.style == .Block {
        pb._style |= PBS_MARQUEE
        SetWindowLongPtr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
        pb.style = .Marquee
    } else {
        pb._style ~= PBS_MARQUEE
        SetWindowLongPtr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
        pb.style = .Block
    }
}

// Set the value for progress bar. Only applicable for block styles
progressbar_set_value :: proc(pb : ^ProgressBar, ival : int) { 
    if pb.style == .Block {
        SendMessage(pb.handle, PBM_SETPOS, Wparam(i32(ival)), 0)
        pb.value = ival
    }
}



@private pb_set_range_internal :: proc(pb : ^ProgressBar) {
    if pb.min_value != 0 || pb.max_value != 100 {
        wpm := Wparam(i32(pb.min_value))
        lpm := Lparam(i32(pb.max_value))
        SendMessage(pb.handle, PBM_SETRANGE32, wpm, lpm)
    }
    SendMessage(pb.handle, PBM_SETSTEP, Wparam(i32(pb.step)), 0)
}

@private pb_before_creation :: proc(pb : ^ProgressBar) {
    pb_adjust_styles(pb)
}

@private pb_after_creation :: proc(pb : ^ProgressBar) {
    pb_set_range_internal(pb)
    
}


    
//     if pb.handle != nil {
//         pb._is_created = true
//         set_subclass(pb, pb_wnd_proc) 
//         setfont_internal(pb)
//         pb_set_range_internal(pb)
//         // if pb._theme == .custom_color {
//         //     SetWindowTheme(pb.handle, empty_wstring, empty_wstring)
//         //     SendMessage(pb.handle, PBM_SETBARCOLOR, 0, Lparam(get_color_ref(pb.fore_color)))
//         //     if pb.back_color != 0xFFFFFF do SendMessage(pb.handle, PBM_SETBKCOLOR, 0, Lparam(get_color_ref(pb.back_color)))
//         // }
 
//     }
// }

TMT_FILLCOLOR :: 3802
DTT_COLORPROP :: 128
DTT_SHADOWCOLOR :: 4

@private pb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {    
    
    context = runtime.default_context()
   // ps : PAINTSTRUCT
    //frb := CreateSolidBrush(get_color_ref(0x0000FF))
    pb := control_cast(ProgressBar, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY :
            remove_subclass(pb)

        

       // case WM_ERASEBKGND :
            
          // if lp == 4 {
               
                // if pb._theme == .custom_color {
                //     hdc := direct_cast(wp, Hdc)
                //     rc := get_rect(hw)
                //     ht := OpenThemeData(hw, to_wstring("PROGRESSS"))
                //     cref : ColorRef
                //     iflag := i32(PBThemeData.PP_BAR)
                //     ret := GetThemeColor(ht, hdc, iflag, 1, TMT_FILLCOLOR, &cref)
                //     print("dtd res - ", ret)
                //     ptf("pb color - %X\n", cref)
                //     CloseThemeData(ht)
                //     return 0

                // }
           //}
        case WM_PAINT :             
         
            if pb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                pb.paint(pb, &pea)
                EndPaint(hw, &ps)
                return 0
            }
            // if pb._theme == .custom_color {
            //     ps : PAINTSTRUCT
            //     hdc := BeginPaint(hw, &ps)
            //     ht := OpenThemeData(hw, to_wstring("PROGRESSS"))
            //     flg := i32(PBTM.PP_CHUNK)
            //     if ht != nil {
            //         dopt : DTBGOPTS
            //         dopt.dwSize = size_of(dopt)
            //         dopt.dwFlags |= u32(128) | u32(4)
            //         dopt.rcClip = ps.rcPaint
            //         ret := DrawThemeBackgroundEx(ht, hdc, flg, 1, &ps.rcPaint, &dopt)
            //         print("dtd res - ", ret)
            //     }
                
            //     EndPaint(hw, &ps)
            //     CloseThemeData(ht)
            //     return 1 // DefSubclassProc(hw, msg, wp, lp) 
            // }
           // return 0
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
            if pb._mdown_happened {
                pb._mdown_happened = false
                SendMessage(pb.handle, CM_LMOUSECLICK, 0, 0)
            }

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
            if pb._mrdown_happened {
                pb._mrdown_happened = false
                SendMessage(pb.handle, CM_LMOUSECLICK, 0, 0) 
            }
            
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
    return DefSubclassProc(hw, msg, wp, lp)
}

// modify_theme :: proc(pb : ^ProgressBar, dc : Hdc, htm : Htheme, state : i32) {

// }