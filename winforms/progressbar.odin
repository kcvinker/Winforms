// Created on 30-Jan-2022 12:37 AM

package winforms
import "core:runtime"
import "core:fmt"

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
    show_percentage : bool,


    _theme : BarTheme,
    _is_paused : bool,
    _hvstm : Htheme,
    speed : i32,




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
    pb.speed = 30
    pb.style = .Block
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
progressbar_increment :: proc(this : ^ProgressBar) {
    if this._is_created {
        if (this.value == this.max_value) {this.value = this.step} else {this.value += this.step}
        SendMessage(this.handle, PBM_STEPIT, 0, 0)
    }

}

// Start marquee animation in progress bar.
progressbar_start_marquee :: proc(pb : ^ProgressBar, speed : int = 30) {
    if pb.style == .Marquee {
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
    if pb._is_created && pb.style == .Marquee  {
        SendMessage(pb.handle, PBM_SETMARQUEE, Wparam(0), Lparam(0))
        // pb._style ~= PBS_MARQUEE
        // SetWindowLongPtr(pb.handle, GWL_STYLE, LongPtr(pb._style) )
    }
}

// Toggle the style of progress bar.
// If it is a block style, it will be marquee and vice versa.
progressbar_change_style :: proc(this : ^ProgressBar, style: BarStyle, marqueeSpeed: i32 = 0) {
    if style != this.style && this._is_created {
        this.value = 0
        if style == .Block {
            this._style ~= PBS_MARQUEE
            this._style |= PBS_SMOOTH
        } else {
            this._style ~= PBS_SMOOTH
            this._style |= PBS_MARQUEE
        }
        SetWindowLongPtr(this.handle, GWL_STYLE, LongPtr(this._style) )
        if style == .Marquee do SendMessage(this.handle, PBM_SETMARQUEE, Wparam(1), Lparam(this.speed));
    }
    if marqueeSpeed != 0 do this.speed = marqueeSpeed
    this.style = style
}

// Set the value for progress bar. Only applicable for block styles
progressbar_set_value :: proc(pb : ^ProgressBar, ival : int) {
    if pb._is_created && pb.style == .Block {
        pb.value = ival
        SendMessage(pb.handle, PBM_SETPOS, Wparam(i32(ival)), 0)

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

@private pb_draw_percentage :: proc(this: ^ProgressBar, hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam) -> Lresult {

    if this.show_percentage && this.style != .Marquee {
        ret := DefSubclassProc(hw, msg, wp, lp)
        ss:Size
        vtext:= fmt.tprintf("%d%%", this.value)
        tlen:= i32(len(vtext))
        wtext:= to_wstring(vtext)
        hdc: Hdc = GetDC(hw)
        defer ReleaseDC(hw, hdc)
        SelectObject(hdc, Hgdiobj(this.font.handle))
        GetTextExtentPoint32(hdc, wtext, tlen, &ss)
        x: i32 = (i32(this.width) - ss.width) / 2;
        y: i32 = (i32(this.height) - ss.height) / 2;
        SetBkMode(hdc, 1);
        SetTextColor(hdc, get_color_ref(this.fore_color));
        TextOut(hdc, x, y, wtext, tlen)
        return ret
    } else {

        return DefSubclassProc(hw, msg, wp, lp)
    }

}

@private pb_before_creation :: proc(pb : ^ProgressBar) {
    pb_adjust_styles(pb)
}

@private pb_after_creation :: proc(pb : ^ProgressBar) {
    set_subclass(pb, pb_wnd_proc)
    pb_set_range_internal(pb)


}


@private pb_finalize :: proc(pb: ^ProgressBar, scid: UintPtr) {
    RemoveWindowSubclass(pb.handle, pb_wnd_proc, scid)
}


TMT_FILLCOLOR :: 3802
DTT_COLORPROP :: 128
DTT_SHADOWCOLOR :: 4

@private pb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {

    context = runtime.default_context()
    pb := control_cast(ProgressBar, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : pb_finalize(pb, sc_id)

        case WM_PAINT : return pb_draw_percentage(pb, hw, msg, wp, lp)

            // if pb.paint != nil {
            //     ps : PAINTSTRUCT
            //     hdc := BeginPaint(hw, &ps)
            //     pea := new_paint_event_args(&ps)
            //     pb.paint(pb, &pea)
            //     EndPaint(hw, &ps)
            //     return 0
            // }

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