/*
    Created on : 01-Feb-2022 08:38 AM
    Name : RadioButton type.
*/

/*===========================================RadioButton Docs=========================================================
    RadioButton struct
        Constructor: new_radiobutton() -> ^RadioButton
        Properties:
            All props from Control struct
            textAlignment   : enum {left, right}
            checked         : bool
            checkOnClick    : bool
            autoSize        : bool
        Functions:
			radiobutton_set_state
            radiobutton_set_autocheck

        Events:
			All events from Control struct
        
==============================================================================================================*/


package winforms
import "base:runtime"
import api "core:sys/windows"


rb_count : int
WcRadioBtnClassW := L("Button")

RadioButton :: struct
{
    using control : Control,
    textAlignment : enum {left, right},
    checked : bool,
    checkOnClick : bool,
    autoSize : bool,
    _hbrush : HBRUSH,
    _txtStyle : UINT,
    onStateChanged : EventHandler,
}

new_radiobutton :: proc{new_rb1, new_rb2, new_rb3, new_rb4}

radiobutton_set_state :: proc(rb : ^RadioButton, bstate: bool)
{
    state := 0x0001 if bstate else 0x0000
    SendMessage(rb.handle, BM_SETCHECK, WPARAM(state), 0)
}

// Change Radio Button's behaviour. Normally radio button will change it's checked state when it clicked.
// But you can change that behaviour by passing a false to this function.
radiobutton_set_autocheck :: proc(rb : ^RadioButton, auto_check : bool )
{
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

//===========================================Private Functions======================================
@private rb_ctor :: proc(f : ^Form, txt : string, x, y, w, h : int) -> ^RadioButton
{
    this := new(RadioButton)
    this.kind = .Radio_Button
    this._textable = true
    this.parent = f
    // this.font = f.font
    this.text = txt
    this.xpos = x
    this.ypos = y
    this.width = w
    this.height = h
    this.checkOnClick = true
    this.autoSize = true
    this.backColor = f.backColor
    this.foreColor = f.foreColor
    this._style = WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON | WS_CLIPCHILDREN
    this._txtStyle = DT_SINGLELINE | DT_VCENTER
    this._exStyle = 0
    this._SizeIncr.width = 20
    this._SizeIncr.height = 3
    this._clsName = WcRadioBtnClassW
    this._fp_beforeCreation = cast(CreateDelegate) rb_before_creation
	this._fp_afterCreation = cast(CreateDelegate) rb_after_creation
    this._inherit_color = true
    font_clone(&f.font, &this.font )
    append(&f._controls, this)
    return this
}

@private new_rb1 :: proc(parent : ^Form) -> ^RadioButton
{
    rb_count += 1
    rtxt := conc_num("Radio_Button_", rb_count)
    rb := rb_ctor(parent, rtxt, 10, 10, 100, 25 )
    if parent.createChilds do create_control(rb)
    return rb
}

@private new_rb2 :: proc(parent : ^Form, txt : string) -> ^RadioButton
{
    rb := rb_ctor(parent, txt, 10, 10, 100, 25 )
    if parent.createChilds do create_control(rb)
    return rb
}

@private new_rb3 :: proc(parent : ^Form, txt : string, x, y : int) -> ^RadioButton
{
    rb := rb_ctor(parent, txt, x, y, 100, 25 )
    if parent.createChilds do create_control(rb)
    return rb
}

@private new_rb4 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> ^RadioButton
{
    rb := rb_ctor(parent, txt, x, y, w, h )
    if parent.createChilds do create_control(rb)
    return rb
}

@private rb_adjust_styles :: proc(rb : ^RadioButton)
{
    if !rb.checkOnClick do rb._style ~= BS_AUTORADIOBUTTON
    //if rb.textAlignment = .right do rb.
}

@private rb_before_creation :: proc(rb : ^RadioButton)
{
    rb_adjust_styles(rb)
}

@private rb_after_creation :: proc(rb : ^RadioButton)
{
    set_subclass(rb, rb_wnd_proc)
    if rb.autoSize do calculate_ctl_size(rb)
    if rb.checked {
        SendMessage(rb.handle, BM_SETCHECK, WPARAM(0x0001), 0)
    }
}

@private radiobutton_property_setter :: proc(this: ^RadioButton, prop: RadioButtonProps, value: $T)
{
	switch prop {
        case. Text_Alignment: break
        case .Checked: when T == bool do radiobutton_set_state(this, value)
        case .Check_On_Click: break
        case .Auto_Size: break
	}
}

@private rb_finalize :: proc(this: ^RadioButton, hw: HWND, scid: UINT_PTR)
{
    delete_gdi_object(this._hbrush)
    if this.font.handle != nil do delete_gdi_object(this.font.handle)
    free(this, context.allocator)
    RemoveWindowSubclass(hw, rb_wnd_proc, scid)
}

@private rb_wnd_proc :: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                        sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context    
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : 
            rb := control_cast(RadioButton, ref_data)
            rb_finalize(rb, hw, sc_id)

        case WM_CONTEXTMENU:
            rb := control_cast(RadioButton, ref_data)
		    if rb.contextMenu != nil do contextmenu_show(rb.contextMenu, lp)

        case CM_CTLCOMMAND :
            rb := control_cast(RadioButton, ref_data)
            if HIWORD(wp) == 0 {
                rb.checked = bool(SendMessage(rb.handle, BM_GETCHECK, 0, 0))
                if rb.onStateChanged != nil {
                    ea := new_event_args()
                    rb.onStateChanged(rb, &ea)
                }
            }
         case WM_LBUTTONDOWN:
            rb := control_cast(RadioButton, ref_data)            
            if rb.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onMouseDown(rb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            rb := control_cast(RadioButton, ref_data)            
            if rb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onRightMouseDown(rb, &mea)
            }
        case WM_LBUTTONUP :
            rb := control_cast(RadioButton, ref_data)
            if rb.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onMouseUp(rb, &mea)
            }            
            if rb.onClick != nil {
                ea := new_event_args()
                rb.onClick(rb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            rb := control_cast(RadioButton, ref_data)            
            if rb.onDoubleClick != nil {
                ea := new_event_args()
                rb.onDoubleClick(rb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            rb := control_cast(RadioButton, ref_data)
            if rb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onRightMouseUp(rb, &mea)
            }            
            if rb.onRightClick != nil {
                ea := new_event_args()
                rb.onRightClick(rb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            rb := control_cast(RadioButton, ref_data)
            if rb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.onMouseScroll(rb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            rb := control_cast(RadioButton, ref_data)
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
            rb := control_cast(RadioButton, ref_data)
            rb._isMouseEntered = false
            if rb.onMouseLeave != nil {
                ea := new_event_args()
                rb.onMouseLeave(rb, &ea)
            }


        case CM_CTLLCOLOR :
            rb := control_cast(RadioButton, ref_data)
            hdc := dir_cast(wp, HDC)
            api.SetBkMode(hdc, api.BKMODE.TRANSPARENT)
            SetBackColor(hdc, get_color_ref(rb.backColor))
            rb._hbrush = CreateSolidBrush(get_color_ref(rb.backColor))
            // print("rb bkc ", rb.backColor)
            // return toLRES(rb._hbrush)
            return toLRES(rb._hbrush)

        case CM_NOTIFY :
            rb := control_cast(RadioButton, ref_data)
            nmcd := dir_cast(lp, ^NMCUSTOMDRAW)
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
                    // SetBackColor(nmcd.hdc, get_color_ref(rb.backColor))
                    DrawText(nmcd.hdc, to_wstring(rb.text), -1, &rct, rb._txtStyle)
                    // free_all(context.temp_allocator)
                    return CDRF_SKIPDEFAULT
            }



    }
    return DefSubclassProc(hw, msg, wp, lp)
}
