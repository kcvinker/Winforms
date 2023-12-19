/*
    Created on : 01-Feb-2022 08:38 AM
    Name : RadioButton type.
    IDE : VSCode
*/

package winforms
import "core:runtime"
//import "core:fmt"

rb_count : int
WcRadioBtnClassW := to_wstring("Button")
RadioButton :: struct {
    using control : Control,
    textAlignment : enum {left, right},
    checked : bool,
    checkOnClick : bool,
    autoSize : bool,

    _hbrush : HBRUSH,
    _txtStyle : UINT,

    onStateChanged : EventHandler,
}

@private rb_ctor :: proc(f : ^Form, txt : string, x, y, w, h : int) -> RadioButton {
    rb : RadioButton
    rb.kind = .Radio_Button
    rb.parent = f
    rb.font = f.font
    rb.text = txt
    rb.xpos = x
    rb.ypos = y
    rb.width = w
    rb.height = h
    rb.checkOnClick = true
    rb.autoSize = true
    rb.backColor = f.backColor
    rb.foreColor = f.foreColor
    rb._style = WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON
    rb._txtStyle = DT_SINGLELINE | DT_VCENTER
    rb._exStyle = 0
    rb._SizeIncr.width = 20
    rb._SizeIncr.height = 3
    rb._clsName = WcRadioBtnClassW
    rb._beforeCreation = cast(CreateDelegate) rb_before_creation
	rb._afterCreation = cast(CreateDelegate) rb_after_creation
    return rb
}



newRadioButton :: proc{new_rb1, new_rb2, new_rb3, new_rb4}

@private new_rb1 :: proc(parent : ^Form) -> RadioButton {
    rb_count += 1
    rtxt := concat_number("Radio_Button_", rb_count)
    rb := rb_ctor(parent, rtxt, 10, 10, 100, 25 )
    return rb
}

@private new_rb2 :: proc(parent : ^Form, txt : string) -> RadioButton {
    rb := rb_ctor(parent, txt, 10, 10, 100, 25 )
    return rb
}

@private new_rb3 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> RadioButton {
    rb := rb_ctor(parent, txt, x, y, w, h )
    return rb
}

@private new_rb4 :: proc(parent : ^Form, txt : string, x, y : int) -> RadioButton {
    rb := rb_ctor(parent, txt, x, y, 100, 25 )
    return rb
}

@private rb_adjust_styles :: proc(rb : ^RadioButton) {
    if !rb.checkOnClick do rb._style ~= BS_AUTORADIOBUTTON
    //if rb.textAlignment = .right do rb.
}

radiobutton_set_state :: proc(rb : ^RadioButton, bstate: bool) {
    state := 0x0001 if bstate else 0x0000
    SendMessage(rb.handle, BM_SETCHECK, WPARAM(state), 0)
}

// Change Radio Button's behaviour. Normally radio button will change it's checked state when it clicked.
// But you can change that behaviour by passing a false to this function.
radiobutton_set_autocheck :: proc(rb : ^RadioButton, auto_check : bool ) {
    ready_to_change : bool
    if auto_check {
         if !rb.checkOnClick {
            rb._style =  WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON
            rb.checkOnClick = true
            ready_to_change = true
        }
    } else {
       if rb.checkOnClick {
            rb._style = WS_VISIBLE | WS_CHILD  | BS_RADIOBUTTON
            rb.checkOnClick = false
            ready_to_change = true
        }
    }
    if ready_to_change {
        SetWindowLongPtr(rb.handle, GWL_STYLE, LONG_PTR(rb._style))
        InvalidateRect(rb.handle, nil, true)
    }
}

@private rb_before_creation :: proc(rb : ^RadioButton) {
    rb_adjust_styles(rb)
}

@private rb_after_creation :: proc(rb : ^RadioButton) {
    set_subclass(rb, rb_wnd_proc)
    if rb.autoSize do calculate_ctl_size(rb)
    if rb.checked {
        SendMessage(rb.handle, BM_SETCHECK, WPARAM(0x0001), 0)
    }
}

@private rb_finalize :: proc(rb: ^RadioButton, scid: UINT_PTR) {
    delete_gdi_object(rb._hbrush)
    RemoveWindowSubclass(rb.handle, rb_wnd_proc, scid)
}


@private rb_wnd_proc :: proc "std" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM, sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT {

    context = runtime.default_context()
    rb := control_cast(RadioButton, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : rb_finalize(rb, sc_id)

        case CM_CTLCOMMAND :
            if hiword_wparam(wp) == 0 {
                rb.checked = bool(SendMessage(rb.handle, BM_GETCHECK, 0, 0))
                if rb.onStateChanged != nil {
                    ea := new_event_args()
                    rb.onStateChanged(rb, &ea)
                }
            }
         case WM_LBUTTONDOWN:
            rb._mDownHappened = true
            if rb.onLeftMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onLeftMouseDown(rb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            rb._mRDownHappened = true
            if rb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onRightMouseDown(rb, &mea)
            }
        case WM_LBUTTONUP :
            if rb.onLeftMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onLeftMouseUp(rb, &mea)
            }
            if rb._mDownHappened {
                rb._mDownHappened = false
                SendMessage(rb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if rb.onMouseClick != nil {
                ea := new_event_args()
                rb.onMouseClick(rb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            rb._mDownHappened = false
            if rb.onDoubleClick != nil {
                ea := new_event_args()
                rb.onDoubleClick(rb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if rb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onRightMouseUp(rb, &mea)
            }
            if rb._mRDownHappened {
                rb._mRDownHappened = false
                SendMessage(rb.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            rb._mRDownHappened = false
            if rb.onRightClick != nil {
                ea := new_event_args()
                rb.onRightClick(rb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if rb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onMouseScroll(rb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if rb._isMouseEntered {
                if rb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    rb.onMouseMove(rb, &mea)
                }
            }
            else {
                rb._isMouseEntered = true
                if rb.onMouseEnter != nil  {
                    ea := new_event_args()
                    rb.onMouseEnter(rb, &ea)
                }
            }
        //end case--------------------

        case WM_MOUSELEAVE :
            rb._isMouseEntered = false
            if rb.onMouseLeave != nil {
                ea := new_event_args()
                rb.onMouseLeave(rb, &ea)
            }


        case CM_CTLLCOLOR :
            hdc := direct_cast(wp, HDC)
            SetBkMode(hdc, Transparent)
            //SetBackColor(hdc, get_color_ref(rb.backColor))
            rb._hbrush = CreateSolidBrush(get_color_ref(rb.backColor))
            return to_lresult(rb._hbrush)

        case CM_NOTIFY :
            nmcd := direct_cast(lp, ^NMCUSTOMDRAW)
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE :
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT :
                    cref := get_color_ref(rb.foreColor)
                    rct : RECT = nmcd.rc
                    if rb.textAlignment == .left{
                        rct.left += 18
                    } else do rct.right -= 18
                    SetTextColor(nmcd.hdc, cref)
                    DrawText(nmcd.hdc, to_wstring(rb.text), -1, &rct, rb._txtStyle)

                    return CDRF_SKIPDEFAULT
            }



    }
    return DefSubclassProc(hw, msg, wp, lp)
}
