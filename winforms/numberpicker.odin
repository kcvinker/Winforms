package winforms

import "core:runtime"
import "core:fmt"
import "core:strconv"

// Constants ----------
    is_np_inited : bool = false
    ICC_UPDOWN_CLASS :: 0x10
    WcNumPickerW : wstring

    UD_MAXVAL :: 0x7fff
    UD_MINVAL :: (-UD_MAXVAL)

    UDS_WRAP :: 0x1
    UDS_SETBUDDYINT :: 0x2
    UDS_ALIGNRIGHT :: 0x4
    UDS_ALIGNLEFT :: 0x8
    UDS_AUTOBUDDY :: 0x10
    UDS_ARROWKEYS :: 0x20
    UDS_HORZ :: 0x40
    UDS_NOTHOUSANDS :: 0x80
    UDS_HOTTRACK :: 0x100

    EN_UPDATE :: 1024
    UDN_FIRST :: (UINT_MAX - 721)
    UDN_DELTAPOS :: (UDN_FIRST - 1)
    swp_flag : Dword: SWP_SHOWWINDOW | SWP_NOACTIVATE | SWP_NOZORDER

// Constants

NumberPicker :: struct {
    using control : Control,
    btn_on_left: bool,
    text_alignment : SimpleTextAlignment,
    min_range, max_range : f32,
    has_separator : bool,
    auto_rotate : bool, // use UDS_WRAP style
    hide_caret : bool,
    value : f32,
    format_string : string,
    decimal_precision : int,
    track_mouse_leave : bool,
    // hide_selection : bool,

    step : f32,

    _buddy_handle : Hwnd,
    _buddy_style : Dword,
    _buddy_exstyle : Dword,
    _buddy_sc_id : int,
    _buddy_proc : SUBCLASSPROC,
    _bk_brush : Hbrush,
    _tbrc : Rect,
    _udrc : Rect,
    _myrc : Rect,
    _updated_text : string,

    _top_edge_flag : Dword,
    _bot_edge_flag : Dword,
    _txt_pos : SimpleTextAlignment,
    _bg_clr_ref : ColorRef,
    _linex : i32,

    // Events
    button_paint,
    text_paint : PaintEventHandler,
    value_changed : EventHandler,
}

StepOprator :: enum {Add, Sub}
ButtonAlignment :: enum {Right, Left}
NMUPDOWN :: struct {
    hdr : NMHDR,
    iPos : i32,
    iDelta : i32,
}



@private np_ctor :: proc(p : ^Form, x, y, w, h : int) -> NumberPicker {
    if !is_np_inited { // Then we need to initialize the date class control.
        is_np_inited = true
        app.iccx.dwIcc = ICC_UPDOWN_CLASS
        WcNumPickerW = to_wstring("msctls_updown32")
        InitCommonControlsEx(&app.iccx)
    }
    np : NumberPicker
    np.kind = .Number_Picker
    np.parent = p
    np.font = p.font
    np.width = w
    np.height = h
    np.xpos = x
    np.ypos = y
    np.step = 1
    np.back_color = app.clr_white
    np.fore_color = app.clr_black
    np.min_range = 0
    np.max_range = 100
    np.decimal_precision = 0
    np._cls_name = WcNumPickerW
	np._before_creation = cast(CreateDelegate) np_before_creation
	np._after_creation = cast(CreateDelegate) np_after_creation

    np._style =  WS_VISIBLE | WS_CHILD | UDS_ALIGNRIGHT | UDS_ARROWKEYS | UDS_AUTOBUDDY | UDS_HOTTRACK
    np._buddy_style = WS_CHILD | WS_VISIBLE | ES_NUMBER | WS_TABSTOP | WS_BORDER
    np._buddy_exstyle = WS_EX_LTRREADING | WS_EX_LEFT
    np._ex_style = 0x00000000
    np._top_edge_flag = BF_TOPLEFT
    np._bot_edge_flag = BF_BOTTOM

    return np
}



@private np_ctor1 :: proc(parent : ^Form) -> NumberPicker {
    np := np_ctor(parent,10, 10, 80, 25 )
    return np
}

@private np_ctor2 :: proc(parent : ^Form, x, y, w, h : int) -> NumberPicker {
    np := np_ctor(parent, x, y, w, h)
    return np
}

new_numberpicker :: proc{np_ctor1, np_ctor2}

@private set_np_styles :: proc(np : ^NumberPicker) {
    if np.btn_on_left {
        np._style ~= UDS_ALIGNRIGHT
        np._style |= UDS_ALIGNLEFT
        np._top_edge_flag = BF_TOP
        np._bot_edge_flag = BF_BOTTOMRIGHT
        if np._txt_pos == SimpleTextAlignment.Left {np._txt_pos = SimpleTextAlignment.Right}
    }

    switch np.text_alignment {
        case .Left : np._buddy_style |= ES_LEFT
        case .Center : np._buddy_style |= ES_CENTER
        case .Right : np._buddy_style |= ES_RIGHT
    }

    // if !np.has_separator do np._style |= UDS_NOTHOUSANDS
}

numberpicker_set_range :: proc(np : ^NumberPicker, max_val, min_val : int) {
    np.max_range = f32(max_val)
    np.min_range = f32(min_val)
    if np._is_created {
        wpm := direct_cast(min_val, Wparam)
        lpm := direct_cast(max_val, Lparam)
        SendMessage(np.handle, UDM_SETRANGE32, wpm, lpm)
    }
}

@private np_set_range_internal :: proc(np : ^NumberPicker) {
    wpm := direct_cast(i32(np.min_range), Wparam)
    lpm := direct_cast(i32(np.max_range), Lparam)
    SendMessage(np.handle, UDM_SETRANGE32, wpm, lpm)
}

@private np_set_value_internal :: proc(np : ^NumberPicker, idelta : i32) {
    new_val : f32 = np.value + (f32(idelta) * np.step)
    if np.auto_rotate {
        if new_val > np.max_range {  // 100.25 > 100.00
            np.value = np.min_range
        } else if new_val < np.min_range {
            np.value = np.max_range
        } else {
            np.value = new_val
        }
    } else {
        np.value = clamp(new_val, np.min_range, np.max_range)
        // fmt.println(np.value)
    }

    np_display_value_internal(np)
}

@private np_display_value_internal :: proc(np : ^NumberPicker) {
    val_str := fmt.tprintf(np.format_string, np.value)
    SetWindowText(np._buddy_handle, to_wstring(val_str))
}

@private set_rects_and_size :: proc(np : ^NumberPicker) {
    /* Mouse leave from a number picker is big problem. Since it is a combo control,
     * So here, we are trying to solve it somehow.
     * There is no magic in it. We just create a big Rect. It can comprise the edit & updown.
     * So, we will map the mouse points into parent's client rect size. Then we will
     * check if those points are inside our big rect. If yes, mouse is on us. Otherwise mouse leaved. */
    SetRect(&np._myrc, i32(np.xpos), i32(np.ypos), i32(np.xpos + np.width), i32(np.ypos + np.height))
    np._tbrc = get_rect(np._buddy_handle) // Textbox rect
    np._udrc = get_rect(np.handle) // Updown btn rect
}

@private resize_buddy :: proc(np : ^NumberPicker) {
    // Here we are adjusting the edit control near to updown control.
    if np.btn_on_left {
        SetWindowPos(np._buddy_handle, nil, i32(np.xpos) + np._udrc.right, i32(np.ypos), np._tbrc.right, np._tbrc.bottom, swp_flag)
        np._linex = np._tbrc.left
    } else {
        SetWindowPos(np._buddy_handle, nil, i32(np.xpos), i32(np.ypos), np._tbrc.right - 2, np._tbrc.bottom, swp_flag)
        np._linex = np._tbrc.right - 3
    }
}

@private np_hide_selection :: proc(np : ^NumberPicker) {
    wpm : i32 = -1
    SendMessage(np._buddy_handle, EM_SETSEL, Wparam(wpm), 0)
}



@private np_before_creation :: proc(np : ^NumberPicker) {
    if !is_np_inited {
        icex : INITCOMMONCONTROLSEX
        icex.dwSize = size_of(icex)
        icex.dwIcc = ICC_UPDOWN_CLASS
        InitCommonControlsEx(&icex)
        is_np_inited = true
    }
    set_np_styles(np)
    np._bg_clr_ref = get_color_ref(np.back_color)
}



@private np_after_creation :: proc(np : ^NumberPicker) {
    ctl_id : Uint = _global_ctl_id // Use global control ID & update it.
    _global_ctl_id += 1
    np._buddy_handle = CreateWindowEx( np._buddy_exstyle,
                                        to_wstring("Edit"),
                                        nil,
                                        np._buddy_style,
                                        i32(np.xpos),
                                        i32(np.ypos),
                                        i32(np.width),
                                        i32(np.height),
                                        np.parent.handle,
                                        direct_cast(ctl_id, Hmenu),
                                        app.h_instance,
                                        nil )

    if np.handle != nil && np._buddy_handle != nil {
        // Hwnd oldBuddy = Hwnd(SendMessage(np.handle, UDM_SETBUDDY, convert_to(Wparam, np._buddy_handle), 0))
        set_np_subclass(np, np_wnd_proc, buddy_wnd_proc)
        if np.font.handle != np.parent.font.handle || np.font.handle == nil do CreateFont_handle(&np.font, np._buddy_handle)
        SendMessage(np._buddy_handle, WM_SETFONT, Wparam(np.font.handle), Lparam(1))

        usb := SendMessage(np.handle, UDM_SETBUDDY, Wparam(np._buddy_handle), 0)
        oldBuddy : Hwnd = direct_cast(usb, Hwnd)
        SendMessage(np.handle, UDM_SETRANGE32, Wparam(np.min_range), Lparam(np.max_range))

        if np.format_string == "" do np.format_string = fmt.tprintf("%%.%df", np.decimal_precision)
        set_rects_and_size(np)
        resize_buddy(np)
        if oldBuddy != nil do SendMessage(oldBuddy, CM_BUDDY_RESIZE, 0, 0)
        np_display_value_internal(np)

    }

}


@private np_finalize :: proc(np: ^NumberPicker, scid: UintPtr) {
    delete_gdi_object(np._bk_brush)
    RemoveWindowSubclass(np.handle, np_wnd_proc, scid)
}


@private np_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {
    context = runtime.default_context()
    np := control_cast(NumberPicker, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : np_finalize(np, sc_id)

        case WM_PAINT :
            if np.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                np.button_paint(np, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case CM_NOTIFY :
            nm := direct_cast(lp, ^NMUPDOWN)
            if nm.hdr.code == UDN_DELTAPOS {
                tbstr : string = get_ctrl_text_internal(np._buddy_handle)
                new_val, _ := strconv.parse_f32(tbstr)
                np.value = new_val
                np_set_value_internal(np, nm.iDelta)
            }

            if np.value_changed != nil {
                ea := new_event_args()
                np.value_changed(np, &ea)
            }

        case WM_MOUSEMOVE :
            if np._is_mouse_entered {
                if np.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    np.mouse_move(np, &mea)
                }
            }
            else {
                np._is_mouse_entered = true
                if np.mouse_enter != nil  {
                    ea := new_event_args()
                    np.mouse_enter(np, &ea)
                }
            }

        case WM_MOUSELEAVE :
            if np.track_mouse_leave {
                if !is_mouse_on_me(np) {
                    np._is_mouse_entered = false
                    ea := new_event_args()
                    np.mouse_leave(np, &ea)
                }
            }

        case WM_ENABLE :
            EnableWindow(hw, bool(wp))
            EnableWindow(np._buddy_handle, bool(wp))
            return 0

        //case WM_CANCELMODE : print("WM_CANCELMODE")

        case : return DefSubclassProc(hw, msg, wp, lp)

    }
    return DefSubclassProc(hw, msg, wp, lp)
}

@private buddy_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {
    context = runtime.default_context()
    tb := control_cast(NumberPicker, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY: RemoveWindowSubclass(hw, buddy_wnd_proc, sc_id)
        case WM_PAINT :
            // if tb.paint != nil {
            //     ps : PAINTSTRUCT
            //     hdc := BeginPaint(hw, &ps)
            //     pea := new_paint_event_args(&ps)
            //     tb.text_paint(tb, &pea)
            //     EndPaint(hw, &ps)
            //     return 0
            // }
            /* We are drawing the edge line over the edit border.
             * Because, we need our edit & updown look like a single control. */
            DefSubclassProc(hw, msg, wp, lp)
            hdc : Hdc = GetDC(hw)
            DrawEdge(hdc, &tb._tbrc, BDR_SUNKENOUTER, tb._top_edge_flag) // Right code
            DrawEdge(hdc, &tb._tbrc, BDR_RAISEDINNER, tb._bot_edge_flag )
            fpen : Hpen = CreatePen(PS_SOLID, 1, tb._bg_clr_ref) // We use Edit's back color.
            SelectObject(hdc, Hgdiobj(fpen))
            MoveToEx(hdc, tb._linex, 1, nil)
            LineTo(hdc, tb._linex, tb.height - 1)
            ReleaseDC(hw, hdc)
            DeleteObject(Hgdiobj(fpen))
            return 0

        case CM_CTLLCOLOR :
            if tb.fore_color != def_fore_clr || tb.back_color != def_back_clr {
                dc_handle := direct_cast(wp, Hdc)
                SetBkMode(dc_handle, Transparent)

                if tb.fore_color != 0x000000 do SetTextColor(dc_handle, get_color_ref(tb.fore_color))
                if tb._bk_brush == nil do tb._bk_brush = CreateSolidBrush(get_color_ref(tb.back_color))
                return to_lresult(tb._bk_brush)
            }

        case EM_SETSEL: return 1

        case WM_KEYDOWN :
            kea := new_key_event_args(wp)
            if tb.key_down != nil {
                tb.key_down(tb, &kea)
            }

        case CM_CTLCOMMAND :
            ncode := hiword_wparam(wp)
            if ncode == EN_UPDATE {
                if tb.hide_caret do HideCaret(hw)
            }

        case WM_KEYUP :
            kea := new_key_event_args(wp)
            if tb.key_up != nil {
                tb.key_up(tb, &kea)
            }
            SendMessage(hw, CM_TBTXTCHANGED, 0, 0)
            return 0

        case WM_CHAR :

            if tb.key_press != nil {
                kea := new_key_event_args(wp)
                tb.key_press(tb, &kea)
                return 0
            }

        case CM_TBTXTCHANGED :
             if tb.value_changed != nil {
                ea:= new_event_args()
                tb.value_changed(tb, &ea)
            }

        case WM_MOUSEMOVE :
            //print("mouse moved on buddy ")
             if tb._is_mouse_entered {
                if tb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    tb.mouse_move(tb, &mea)
                }
            }
            else {
                tb._is_mouse_entered = true
                if tb.mouse_enter != nil  {
                    ea := new_event_args()
                    tb.mouse_enter(tb, &ea)
                }
            }

        case WM_MOUSELEAVE :
            if tb.track_mouse_leave {
                if !is_mouse_on_me(tb) {
                    tb._is_mouse_entered = false
                    ea := new_event_args()
                    tb.mouse_leave(tb, &ea)
                }
            }

        case CM_BUDDY_RESIZE: resize_buddy(tb)


        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}

// Special subclassing for NumberPicker control. Remove_subclass is written in dtor
@private set_np_subclass :: proc(np : ^NumberPicker, np_func, buddy_func : SUBCLASSPROC ) {
	np_dwp := cast(DwordPtr)(cast(uintptr) np)
	SetWindowSubclass(np.handle, np_func, UintPtr(_global_subclass_id), np_dwp )
	_global_subclass_id += 1

	SetWindowSubclass(np._buddy_handle, buddy_func, UintPtr(_global_subclass_id), np_dwp )
	_global_subclass_id += 1
}

@private is_mouse_on_me :: proc(np : ^NumberPicker) -> bool {
    // If this returns False, mouse_leave event will triggered
    // Since, updown control is a combo of an edit and button controls...
    // we have no better options to control the mouse enter & leave mechanism.
    // Now, we create an imaginary rect over the bondaries of these two controls.
    // If mouse is inside that rect, there is no mouse leave. Perfect hack.
    // fmt.println(np.parent.handle)
    pt : Point
    GetCursorPos(&pt)
    ScreenToClient(np.parent.handle, &pt)
    return bool(PtInRect(&np._myrc, pt))
}



