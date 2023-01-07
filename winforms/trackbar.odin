/*
    Created on : 03-Feb-2022 6:39:51 PM
    Name : TrackBar type.
*/

package winforms
import "core:runtime"
import "core:fmt"

// Constants
    TBS_AUTOTICKS :: 0x1
    TBS_VERT :: 0x2
    TBS_HORZ :: 0x0
    TBS_TOP :: 0x4
    TBS_BOTTOM :: 0x0
    TBS_LEFT :: 0x4
    TBS_RIGHT :: 0x0
    TBS_BOTH :: 0x8
    TBS_NOTICKS :: 0x10
    TBS_ENABLESELRANGE :: 0x20
    TBS_FIXEDLENGTH :: 0x40
    TBS_NOTHUMB :: 0x80
    TBS_TOOLTIPS :: 0x100
    TBS_REVERSED :: 0x200
    TBS_DOWNISLEFT :: 0x400

    THUMB_LINE_LOW :: 0
    THUMB_LINE_HIGH :: 1
    THUMB_PAGE_LOW :: 2
    THUMB_PAGE_HIGH :: 3
    TB_THUMBPOSITION :: 4
    TB_THUMBTRACK :: 5

    TBCD_TICS : u32 : 0x1
    TBCD_THUMB : u32 : 0x2
    TBCD_CHANNEL : u32 : 0x3

    BIG_CHANNEL_EDGE :: BF_ADJUST | BF_RECT | BF_FLAT


    /* We are converting these literals to dword pointer.
     * Because, at the custom draw area, we need to check the...
     * drawing stage with these literals. But odin didn't allow...
     * us to use dword pointer on lhs and a dword on rhs. So this will fix that problem. */
    TbTestCdraw := direct_cast( 0x0, DwordPtr)
    TkbTicsCdraw  := direct_cast(0x1, DwordPtr)
    TkbThumbCdraw := direct_cast( 0x2, DwordPtr)
    TkbChannelCdraw := direct_cast( 0x3, DwordPtr)
    TkbItemPrePaint := direct_cast(65537, DwordPtr)


// Constants End

WcTrackbarClassW : wstring
_def_tkb_width :: 150
_def_tkb_height :: 30

TrackBar :: struct {
    using control : Control,
    tic_pos : TicPosition,
    no_ticks : bool,
    channel_color,
    tic_color : uint,
    tic_width : int,
    min_range, max_range : int,
    frequency : i32,
    page_size : int,
    line_size : int,
    tic_len : i32,
    default_tics : bool,
    value : int,
    vertical : bool,
    reversed : bool,
    sel_range   : bool,
    no_thumb   : bool,
    tool_tip   : bool,
    cust_draw   : bool,
    free_move   : bool,
    sel_color : uint,
    channel_style : ChannelStyle,

    // Private members
    _bk_brush : Hbrush,
    _sel_brush : Hbrush,
    _channel_pen : Hpen,
    _tic_pen : Hpen,
    _tic_count : i32,
    _def_tics : bool,
    _channel_rc, _thumb_rc, _myrc : Rect,
    _tic_data : [dynamic]TicData,
    _thumb_half : i32,
    _p1, _p2 : i32,
    _range : i32,
    _channel_flag : Dword,

    // Event Members
    value_changed, dragging, dragged : EventHandler,
}

// This struct is to hold the tic's physical pos and logical pos.
TicData :: struct {
    phy_point : i32,
    log_point : i32,
}

// Define drawing style for channel.
ChannelStyle ::enum {classic, outline,}

@private new_ticdata :: proc(pp: i32, lp: i32) -> TicData {
    tc : TicData
    tc.phy_point = pp
    tc.log_point = lp
    return tc
}

new_trackbar :: proc{new_tbar1, new_tbar2, new_tbar3}

@private tbar_ctor :: proc(f : ^Form, x, y, w, h : int) -> TrackBar {
    if WcTrackbarClassW == nil {
        WcTrackbarClassW = to_wstring("msctls_trackbar32")
        app.iccx.dwIcc = 0x4
        InitCommonControlsEx(&app.iccx)
    }

    tkb : TrackBar
    tkb.kind = .Track_Bar
    tkb.parent = f
    tkb.font = f.font
    tkb.xpos = x
    tkb.ypos = y
    tkb.width = w
    tkb.height = h
    tkb.back_color = f.back_color
    tkb.channel_color = light_steel_blue
    tkb.tic_color = 0x000000
    tkb.frequency = 10
    tkb.tic_width = 1
    tkb.tic_len = 4
    tkb.line_size = 1
    tkb.page_size = 10
    tkb.tic_pos = TicPosition.Down_Side
    tkb.channel_style = ChannelStyle.outline
    tkb.min_range = 0
    tkb.max_range = 100

    tkb.channel_color = 0xc2c2a3
    tkb.sel_color = 0x99ff33
    tkb.tic_color = 0x3385ff

    tkb._style = WS_CHILD | WS_VISIBLE | TBS_AUTOTICKS
    tkb._ex_style = 0
    tkb.text = "my track"
    tkb._cls_name = WcTrackbarClassW
    tkb._before_creation = cast(CreateDelegate) tkb_before_creation
	tkb._after_creation = cast(CreateDelegate) tkb_after_creation
    tkb._channel_flag = BF_RECT | BF_ADJUST
    return tkb
}

@private new_tbar1 :: proc(parent : ^Form) -> TrackBar {
    tkb := tbar_ctor(parent, 10, 10, _def_tkb_width, _def_tkb_height)
    return tkb
}

@private new_tbar2 :: proc(parent : ^Form, x, y : int) -> TrackBar {
    tkb := tbar_ctor(parent, x, y, _def_tkb_width, _def_tkb_height)
    return tkb
}

@private new_tbar3 :: proc(parent : ^Form, x, y, w, h : int) -> TrackBar {
    tkb := tbar_ctor(parent, x, y, w, h)
    return tkb
}

@private tkb_adjust_styles :: proc(tkb : ^TrackBar) {
    if tkb.vertical {
        tkb._style |= TBS_VERT
        #partial switch tkb.tic_pos {
            case .Right_Side : tkb._style |= TBS_RIGHT
            case .Left_Side : tkb._style |= TBS_LEFT
            case .Both_Side : tkb._style |= TBS_BOTH
        }
    } else {
        #partial switch tkb.tic_pos {
            case .Down_Side : tkb._style |= TBS_BOTTOM
            case .Up_Side : tkb._style |= TBS_TOP
            case .Both_Side : tkb._style |= TBS_BOTH
        }
    }

    if tkb.sel_range{
        tkb._style |= TBS_ENABLESELRANGE
        tkb._channel_flag = BF_RECT | BF_ADJUST | BF_FLAT
        tkb.cust_draw = true
    }
    if tkb.reversed do tkb._style |= TBS_REVERSED
    if tkb.no_ticks do tkb._style |= TBS_NOTICKS
    if tkb.no_thumb do tkb._style |= TBS_NOTHUMB
    if tkb.tool_tip do tkb._style |= TBS_TOOLTIPS
    tkb._bk_brush = get_solid_brush(tkb.back_color)

}



@private setup_value_internal :: proc(tk : ^TrackBar, value : i32) {
    if tk.reversed {
        tk.value = int(U16MAX - value)
    } else {
        tk.value = int(value)
    }
}


@private draw_vertical_tics :: proc(hdc : Hdc, px : i32, py : i32, ticlen : i32) {
    MoveToEx(hdc, px, py, nil);
    LineTo(hdc, px + ticlen, py)
}

@private draw_horiz_tics_down :: proc(hdc : Hdc, px : i32, py : i32, ticlen : i32) {
    MoveToEx(hdc, px, py, nil);
    LineTo(hdc, px, py + ticlen)
}

@private draw_horiz_tics_upper :: proc(hdc : Hdc, px : i32, py : i32, ticlen : i32) {
    MoveToEx(hdc, px, py, nil);
    LineTo(hdc, px, py - ticlen)
}

@private draw_tics :: proc(tk : ^TrackBar, hdc : Hdc) {
    SelectObject(hdc, Hgdiobj(tk._tic_pen))
    if tk.vertical {
        #partial switch tk.tic_pos {
            case TicPosition.Right_Side, TicPosition.Left_Side:
                for p in tk._tic_data do draw_vertical_tics(hdc, tk._p1, p.phy_point, tk.tic_len)
            case TicPosition.Both_Side:
                for p in tk._tic_data {
                    draw_vertical_tics(hdc, tk._p1, p.phy_point, tk.tic_len)
                    draw_vertical_tics(hdc, tk._p2, p.phy_point, tk.tic_len)
                }
        }

    } else {
        #partial switch tk.tic_pos {
            case TicPosition.Up_Side, TicPosition.Down_Side:
                for p in tk._tic_data do draw_horiz_tics_down(hdc, p.phy_point, tk._p1, tk.tic_len)
            case TicPosition.Both_Side:
                for p in tk._tic_data {
                    draw_horiz_tics_down(hdc, p.phy_point, tk._p1, tk.tic_len)
                    draw_horiz_tics_upper(hdc, p.phy_point, tk._p2, tk.tic_len)
                }
        }
    }
}

@private calculate_tics :: proc(tk : ^TrackBar) {
    twidth, stpos, enpos,tic, numtics : i32
    pfactor, range, chanlen : f32

    // Collectiing required rects
    GetClientRect(tk.handle, &tk._myrc) // Get Trackbar rect
    SendMessage(tk.handle, TBM_GETTHUMBRECT, 0, direct_cast(&tk._thumb_rc, Lparam)) // Get the thumb rect
    SendMessage(tk.handle, TBM_GETCHANNELRECT, 0, direct_cast(&tk._channel_rc, Lparam)) // Get the channel rect

    //2. Calculate thumb offset
    if tk.vertical {
        twidth = tk._thumb_rc.bottom - tk._thumb_rc.top
    } else {
        twidth = tk._thumb_rc.right - tk._thumb_rc.left
    }

    tk._thumb_half = i32(twidth / 2)

    // Now calculate required variables
    tk._range = i32(tk.max_range - tk.min_range)
    numtics = tk._range / tk.frequency
    if int(tk._range) %% int(tk.frequency) == 0 do numtics -= 1
    // fmt.printf("tk._range = %d, tk.frequency = %d  modulo = %d\n", tk._range, tk.frequency,  (tk._range %% tk.frequency))
    // fmt.printf("tk._thumb_half = %d, \n", tk._thumb_half)
    stpos = tk._channel_rc.left + tk._thumb_half
    enpos = tk._channel_rc.right - tk._thumb_half - 1
    chanlen = f32(enpos - stpos)
    pfactor = chanlen / f32(tk._range)
    // fmt.printf("stpos = %d, enpos = %d, channel len = %d, pFactor = %f \n", stpos, enpos, chanlen, pfactor )

    // Let's fill the tic data array
    tic = i32(tk.min_range + int(tk.frequency))
    append(&tk._tic_data, new_ticdata(stpos, 0)) // Very first tic
    for i := 0; i < int(numtics); i += 1 {
        append(&tk._tic_data, new_ticdata(i32((f32(tic) * pfactor) + f32(stpos)), tic)) // Middle tics
        tic += i32(tk.frequency)
    }
    append(&tk._tic_data, new_ticdata(enpos, i32(tk._range))) // Last tic

    // Now, set up single point (x/y) for tics.
    if tk.vertical {
        #partial switch tk.tic_pos {
            case TicPosition.Left_Side: tk._p1 = tk._thumb_rc.left - 5
            case TicPosition.Right_Side: tk._p1 = tk._thumb_rc.right + 2
            case TicPosition.Both_Side:
                tk._p1 = tk._thumb_rc.right + 2
                tk._p2 = tk._thumb_rc.left - 5
        }
    } else {
        #partial switch (tk.tic_pos) {
            case TicPosition.Down_Side: tk._p1 = tk._thumb_rc.bottom + 1
            case TicPosition.Up_Side: tk._p1 = tk._thumb_rc.top - 4
            case TicPosition.Both_Side:
                tk._p1 = tk._thumb_rc.bottom + 1
                tk._p2 = tk._thumb_rc.top - 3
        }
    }

    // for t in tk._tic_data {
    //     fmt.printf("phy : %d, log : %d\n", t.phy_point, t.log_point)
    // }
}

@private get_thumb_rect :: proc(h : Hwnd) -> Rect {
    rc : Rect
    SendMessage(h, TBM_GETTHUMBRECT, 0, direct_cast(&rc, Lparam))
    return rc
}

@private fill_channel_rect :: proc(tk : ^TrackBar, nm : LPNMCUSTOMDRAW, trc : Rect) -> bool {
    /* If show_selection property is enabled in this trackbar,
     * we need to show the area between thumb and channel starting in diff color.
     * But we need to check if the trackbar is reversed or not.
     * NOTE: If we change the drawing flags for DrawEdge function in channel drawing area,
     * We need to reduce the rect size 1 point. Because, current flags working perfectly...
     * Without adsting rect. So change it carefully. */
    result : bool = false
    rct : Rect

    if tk.vertical {
        rct.left = nm.rc.left
        rct.right = nm.rc.right
        if tk.reversed {
            rct.top = trc.bottom
            rct.bottom = nm.rc.bottom
        } else {
            rct.top = nm.rc.top
            rct.bottom = trc.top
        }
    } else {
        rct.top = nm.rc.top
        rct.bottom = nm.rc.bottom
        if tk.reversed {
            rct.left = trc.right
            rct.right = nm.rc.right
        } else {
            rct.left = nm.rc.left
            rct.right = trc.left
        }
    }

    result = bool(FillRect(nm.hdc, &rct, tk._sel_brush))
    return result
}

@private send_initial_messages :: proc(tk : ^TrackBar) {
    if tk.reversed {
        SendMessage(tk.handle, TBM_SETRANGEMIN, Wparam(1), Lparam(tk.max_range * -1))
        SendMessage(tk.handle, TBM_SETRANGEMAX, Wparam(1), Lparam(tk.min_range))
    } else {
        SendMessage(tk.handle, TBM_SETRANGEMIN, Wparam(1), Lparam(tk.min_range))
        SendMessage(tk.handle, TBM_SETRANGEMAX, Wparam(1), Lparam(tk.max_range))
    }
    SendMessage(tk.handle, TBM_SETTICFREQ, Wparam(tk.frequency), 0)
    SendMessage(tk.handle, TBM_SETPAGESIZE, 0, Lparam(tk.page_size))
    SendMessage(tk.handle, TBM_SETLINESIZE, 0, Lparam(tk.line_size))
}

set_value :: proc(tk : ^TrackBar, value: int) {
    if value > tk.max_range || value < tk.min_range do return
    SendMessage(tk.handle, TBM_SETPOS, Wparam(1), Lparam(i32(value)) )
}


@private tkb_before_creation :: proc(tkb : ^TrackBar) {tkb_adjust_styles(tkb)}

@private tkb_after_creation :: proc(tkb : ^TrackBar) {
	set_subclass(tkb, tkb_wnd_proc)

    // Prepare for custom draw
    tkb._channel_pen = CreatePen(PS_SOLID, 1, get_color_ref(tkb.channel_color))
    tkb._tic_pen = CreatePen(PS_SOLID, i32(tkb.tic_width), get_color_ref(tkb.tic_color))

    // Send some important messages to Wndproc function.
    send_initial_messages(tkb)

    // Calculate tic positions.
    if tkb.cust_draw do calculate_tics(tkb)

    // Prepare our selection range brush if needed.
    if tkb.sel_range do tkb._sel_brush = get_solid_brush(tkb.sel_color)
}

@private finalize_trackbar :: proc(tk : ^TrackBar) {
    delete_gdi_object(tk._bk_brush)
    delete_gdi_object(tk._sel_brush)
    delete(tk._tic_data)
}







@private tkb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {
    context = runtime.default_context()
    tkb := control_cast(TrackBar, ref_data)
   // display_msg(msg)
    switch msg {
        case WM_DESTROY :
            finalize_trackbar(tkb)
            remove_subclass(tkb)


        case CM_CTLLCOLOR :
            hdc := direct_cast(wp, Hdc)
            SetTextColor(hdc, get_color_ref(tkb.fore_color))
            // tkb._bk_brush = CreateSolidBrush(get_color_ref(tkb.back_color))
            return direct_cast(tkb._bk_brush, Lresult)

        case CM_NOTIFY :
            nmh := direct_cast(lp, ^NMHDR)
            if nmh.code == NM_CUSTOMDRAW {
                if tkb.cust_draw {
                    nmcd := direct_cast(lp, ^NMCUSTOMDRAW)
                    switch nmcd.dwDrawStage {
                        case CDDS_PREPAINT: return CDRF_NOTIFYITEMDRAW

                        case CDDS_ITEMPREPAINT:
                            switch nmcd.dwItemSpec {

                                // TkbTicsCdraw is not a magical value. Explanation is given at line 39
                                case TkbTicsCdraw:
                                    if (!tkb.no_ticks) {
                                        draw_tics(tkb, nmcd.hdc)
                                        return CDRF_SKIPDEFAULT
                                    }

                                // TkbChannelCdraw is not a magical value. Explanation is given at line 39
                                case TkbChannelCdraw:
                                    /* In Python proect i am using EDGE_SUNKEN style without BF_FLAT.
                                        * But in D, it gives a strange outline in those flags. So I decided to use...
                                        * these flags. But in this case, we don't need to reduce 1 point from...
                                        * the coloring rect. It looks perfect without changing rect. */
                                    if !tkb.sel_range {
                                        if tkb.channel_style == ChannelStyle.classic {
                                            DrawEdge(nmcd.hdc, &nmcd.rc, BDR_SUNKENOUTER, tkb._channel_flag)
                                        } else {
                                            SelectObject(nmcd.hdc, Hgdiobj(tkb._channel_pen))
                                            Rectangle(nmcd.hdc, nmcd.rc.left, nmcd.rc.top, nmcd.rc.right, nmcd.rc.bottom );
                                        }
                                    } else {
                                        /* This gives a pleasant look when sel_range is enabled.
                                            * Without a border(or edge), channel looks ugly. */
                                        DrawEdge(nmcd.hdc, &nmcd.rc, BDR_OUTER, BIG_CHANNEL_EDGE)
                                        rc : Rect = get_thumb_rect(hw)
                                        if fill_channel_rect(tkb, nmcd, rc) do InvalidateRect(hw, &nmcd.rc, false)
                                    }

                                    return CDRF_SKIPDEFAULT
                            }
                    }
                } else {
                    return CDRF_DODEFAULT
                }
            }


         case WM_LBUTTONDOWN:
           // tkb._draw_focus_rct = true
            tkb._mdown_happened = true
            if tkb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.left_mouse_down(tkb, &mea)
                return 0
            }


        case WM_RBUTTONDOWN :
            tkb._mrdown_happened = true
            if tkb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.right_mouse_down(tkb, &mea)
            }

        case WM_LBUTTONUP :
            if tkb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.left_mouse_up(tkb, &mea)
            }
            if tkb._mdown_happened {
                tkb._mdown_happened = false
                SendMessage(tkb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            tkb._mdown_happened = false
            if tkb.mouse_click != nil {
                ea := new_event_args()
                tkb.mouse_click(tkb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            if tkb.double_click != nil {
                ea := new_event_args()
                tkb.double_click(tkb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if tkb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.right_mouse_up(tkb, &mea)
            }
            if tkb._mrdown_happened {
                tkb._mrdown_happened = false
                SendMessage(tkb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            tkb._mrdown_happened = false
            if tkb.right_click != nil {
                ea := new_event_args()
                tkb.right_click(tkb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if tkb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.mouse_scroll(tkb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if tkb._is_mouse_entered {
                if tkb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    tkb.mouse_move(tkb, &mea)
                }
            }
            else {
                tkb._is_mouse_entered = true
                if tkb.mouse_enter != nil  {
                    ea := new_event_args()
                    tkb.mouse_enter(tkb, &ea)
                }
            }

        case WM_MOUSELEAVE :
            tkb._is_mouse_entered = false
            if tkb.mouse_leave != nil {
                ea := new_event_args()
                tkb.mouse_leave(tkb, &ea)
            }

        case WM_HSCROLL, WM_VSCROLL:
            lwp := loword_wparam(wp)
            switch lwp {
                case TB_THUMBPOSITION:
                    setup_value_internal(tkb, i32(hiword_wparam(wp)))
                    if !tkb.free_move {
                        pos : i32 = i32(tkb.value)
                        half : f32 = f32(tkb.frequency) / 2
                        diff : i32 = pos %% i32(tkb.frequency)

                        if diff >= i32(half) {
                            pos = (i32(tkb.frequency) - diff) + i32(tkb.value)
                        } else if diff < i32(half) {
                            pos =  i32(tkb.value) - diff
                        }

                        if tkb.reversed {
                            SendMessage(hw, TBM_SETPOS, Wparam(1), Lparam(pos * -1))
                        } else {
                            SendMessage(hw, TBM_SETPOS, Wparam(1), Lparam(pos))
                        }

                        tkb.value = int(pos)
                    }

                    // We need to refresh Trackbar in order to display our new drawings.
                    InvalidateRect(hw, &tkb._channel_rc, false)

                    if tkb.dragged != nil {
                        ea := new_event_args()
                        tkb.dragged(tkb, &ea)
                    }

                    if tkb.value_changed != nil {
                        ea := new_event_args()
                        tkb.value_changed(tkb, &ea)
                    }

                case THUMB_LINE_HIGH, THUMB_LINE_LOW, THUMB_PAGE_HIGH, THUMB_PAGE_LOW:
                    setup_value_internal(tkb, i32(SendMessage(hw, TBM_GETPOS, 0, 0)))
                    if tkb.value_changed != nil {
                        ea := new_event_args()
                        tkb.value_changed(tkb, &ea)
                    }

                case TB_THUMBTRACK:
                    setup_value_internal(tkb, i32(SendMessage(hw, TBM_GETPOS, 0, 0)))
                    if tkb.dragging != nil {
                        ea := new_event_args()
                        tkb.dragging(tkb, &ea)
                    }
            }
    }
    return DefSubclassProc(hw, msg, wp, lp)
}

