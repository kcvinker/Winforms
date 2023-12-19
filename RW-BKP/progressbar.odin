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

ProgressBar :: struct 
{
    using control : Control,
    minValue,
    maxValue : int,
    step : int,
    style : BarStyle,
    orientation : BarAlign,
    value : int,
    showPercentage : bool,


    _theme : BarTheme,
    _isPaused : bool,
    _hvstm : HTHEME,
    speed : i32,
}

BarStyle :: enum {Block, Marquee}
BarAlign :: enum {Horizontal, Vertical}
BarTheme :: enum {System_Color, Custom_Color }

@private pb_ctor :: proc(f : ^Form, x, y, w, h : int) -> ProgressBar 
{
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
    pb.minValue = 0
    pb.maxValue = 100
    pb.step = 1
    pb.speed = 30
    pb.style = .Block
    pb._theme = .System_Color
    pb._clsName = WcProgressClassW
    pb._beforeCreation = cast(CreateDelegate) pb_before_creation
	pb._afterCreation = cast(CreateDelegate) pb_after_creation

    pb._style = WS_CHILD | WS_VISIBLE | WS_TABSTOP | PBS_SMOOTH
    pb._exStyle = WS_EX_STATICEDGE

    return pb
}

@private pb_dtor :: proc(pb : ^ProgressBar) {
    if pb._hvstm != nil do CloseThemeData(pb._hvstm)
}

newProgressBar :: proc{pb_new1, pb_new2}

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
// progressbar_set_theme :: proc(pb : ^ProgressBar, border : bool, fclr : UINT,bclr : uint = 0xFFFFFF) {
//     pb._theme = .custom_color
//     pb.foreColor = fclr
//     pb.backColor = bclr
//     //if border do pb._style |= WS_BORDER
// }

// Increment progress bar value one step.
progressbar_increment :: proc(this : ^ProgressBar) {
    if this._isCreated {
        if (this.value == this.maxValue) {this.value = this.step} else {this.value += this.step}
        SendMessage(this.handle, PBM_STEPIT, 0, 0)
    }

}

// Start marquee animation in progress bar.
progressbar_start_marquee :: proc(pb : ^ProgressBar, speed : int = 30) {
    if pb.style == .Marquee {
        SendMessage(pb.handle, PBM_SETMARQUEE, WPARAM(1), LPARAM(i32(speed)))
    }
}

// Pause marquee animation in progress bar
progressbar_pause_marquee :: proc(pb : ^ProgressBar) {
    if pb.style == .Marquee {
        SendMessage(pb.handle, PBM_SETMARQUEE, WPARAM(0), LPARAM(0))
        pb._isPaused = true
    }
}

// Restart marquee animation in a paused progress bar
progressbar_restart_marquee :: proc(pb : ^ProgressBar) {
    if pb.style == .Marquee && pb._isPaused {
        SendMessage(pb.handle, PBM_SETMARQUEE, WPARAM(1), LPARAM(0))
        pb._isPaused = false
    }
}

// Stop marquee animation in progress bar.
progressbar_stop_marquee :: proc(pb : ^ProgressBar) {
    if pb._isCreated && pb.style == .Marquee  {
        SendMessage(pb.handle, PBM_SETMARQUEE, WPARAM(0), LPARAM(0))
        // pb._style ~= PBS_MARQUEE
        // SetWindowLongPtr(pb.handle, GWL_STYLE, LONG_PTR(pb._style) )
    }
}

// Toggle the style of progress bar.
// If it is a block style, it will be marquee and vice versa.
progressbar_change_style :: proc(this : ^ProgressBar, style: BarStyle, marqueeSpeed: i32 = 0) {
    if style != this.style && this._isCreated {
        this.value = 0
        if style == .Block {
            this._style ~= PBS_MARQUEE
            this._style |= PBS_SMOOTH
        } else {
            this._style ~= PBS_SMOOTH
            this._style |= PBS_MARQUEE
        }
        SetWindowLongPtr(this.handle, GWL_STYLE, LONG_PTR(this._style) )
        if style == .Marquee do SendMessage(this.handle, PBM_SETMARQUEE, WPARAM(1), LPARAM(this.speed));
    }
    if marqueeSpeed != 0 do this.speed = marqueeSpeed
    this.style = style
}

// Set the value for progress bar. Only applicable for block styles
progressbar_set_value :: proc(pb : ^ProgressBar, ival : int) {
    if pb._isCreated && pb.style == .Block {
        pb.value = ival
        SendMessage(pb.handle, PBM_SETPOS, WPARAM(i32(ival)), 0)

    }
}



@private pb_set_range_internal :: proc(pb : ^ProgressBar) {
    if pb.minValue != 0 || pb.maxValue != 100 {
        wpm := WPARAM(i32(pb.minValue))
        lpm := LPARAM(i32(pb.maxValue))
        SendMessage(pb.handle, PBM_SETRANGE32, wpm, lpm)
    }
    SendMessage(pb.handle, PBM_SETSTEP, WPARAM(i32(pb.step)), 0)
}

@private pb_draw_percentage :: proc(this: ^ProgressBar, hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM) -> LRESULT {

    if this.showPercentage && this.style != .Marquee {
        ret := DefSubclassProc(hw, msg, wp, lp)
        ss:SIZE
        vtext:= fmt.tprintf("%d%%", this.value)
        tlen:= i32(len(vtext))
        wtext:= to_wstring(vtext)
        hdc: HDC = GetDC(hw)
        defer ReleaseDC(hw, hdc)
        SelectObject(hdc, HGDIOBJ(this.font.handle))
        GetTextExtentPoint32(hdc, wtext, tlen, &ss)
        x: i32 = (i32(this.width) - ss.width) / 2;
        y: i32 = (i32(this.height) - ss.height) / 2;
        SetBkMode(hdc, 1);
        SetTextColor(hdc, get_color_ref(this.foreColor));
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


@private pb_finalize :: proc(pb: ^ProgressBar, scid: UINT_PTR) {
    RemoveWindowSubclass(pb.handle, pb_wnd_proc, scid)
}


TMT_FILLCOLOR :: 3802
DTT_COLORPROP :: 128
DTT_SHADOWCOLOR :: 4

@private pb_wnd_proc :: proc "std" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM, sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT {

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
            pb._mDownHappened = true
            if pb.onLeftMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.onLeftMouseDown(pb, &mea)
                return 0
            }


        case WM_RBUTTONDOWN :
            pb._mRDownHappened = true
            if pb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.onRightMouseDown(pb, &mea)
            }

        case WM_LBUTTONUP :
            if pb.onLeftMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.onLeftMouseUp(pb, &mea)
            }
            if pb._mDownHappened {
                pb._mDownHappened = false
                SendMessage(pb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            pb._mDownHappened = false
            if pb.onMouseClick != nil {
                ea := new_event_args()
                pb.onMouseClick(pb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            if pb.onDoubleClick != nil {
                ea := new_event_args()
                pb.onDoubleClick(pb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if pb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.onRightMouseUp(pb, &mea)
            }
            if pb._mRDownHappened {
                pb._mRDownHappened = false
                SendMessage(pb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            pb._mRDownHappened = false
            if pb.onRightClick != nil {
                ea := new_event_args()
                pb.onRightClick(pb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if pb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                pb.onMouseScroll(pb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if pb._isMouseEntered {
                if pb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    pb.onMouseMove(pb, &mea)
                }
            }
            else {
                pb._isMouseEntered = true
                if pb.onMouseEnter != nil  {
                    ea := new_event_args()
                    pb.onMouseEnter(pb, &ea)
                }
            }

        case WM_MOUSELEAVE :
            pb._isMouseEntered = false
            if pb.onMouseLeave != nil {
                ea := new_event_args()
                pb.onMouseLeave(pb, &ea)
            }



    }
    return DefSubclassProc(hw, msg, wp, lp)
}

// modify_theme :: proc(pb : ^ProgressBar, dc : HDC, htm : HTHEME, state : i32) {

// }