/*
    Created on: 01-Feb-2022 08:38 AM
    Name: RadioButton type.
*/

/*===========================================RadioButton Docs=========================================================
    RadioButton struct
        Constructor: new_radiobutton() -> ^RadioButton
        Properties:
            All props from Control struct
            textAlign  : enum {left, right}
            checked        : bool
            checkOnClick   : bool
            autoSize       : bool
        Functions:
			radiobutton_set_state
            radiobutton_set_autocheck

        Events:
			All events from Control struct
        
==============================================================================================================*/


package winforms
import "base:runtime"
import api "core:sys/windows"


rb_count: int

RadioButton:: struct
{
    using control: Control,
    textAlign: Alignment,
    checked: bool,
    checkOnClick: bool,
    autoSize: bool,
    _hbrush: HBRUSH,
    _txtStyle: UINT,
    onStateChanged: EventHandler,
}

new_radiobutton:: proc{new_rb1, new_rb2, new_rb3, new_rb4}

radiobutton_set_state:: proc(rb: ^RadioButton, bstate: bool)
{
    state:= 0x0001 if bstate else 0x0000
    SendMessage(rb.handle, BM_SETCHECK, WPARAM(state), 0)
}

// Change Radio Button's behaviour. Normally radio button will change it's checked state when it clicked.
// But you can change that behaviour by passing a false to this function.
radiobutton_set_autocheck:: proc(rb: ^RadioButton, auto_check: bool )
{
    ready_to_change: bool
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
@private rb_ctor:: proc(f: ^Form, txt: string, x, y, w, h: int) -> ^RadioButton
{
    this:= new(RadioButton)
    init_control(this, f, x, y, w, h, .Radio_Button, 
                    COMM_CTRL_STYLES | BS_AUTORADIOBUTTON | WS_CLIPCHILDREN, 0, 
                    wcnButton, TXTABLE, FONTABLE)
    this.text = txt
    this._wtext = new_widestring(txt)
    this.checkOnClick = true
    this.autoSize = true
    this.backColor = f.backColor
    this.foreColor = f.foreColor
    this._txtStyle = DT_SINGLELINE | DT_VCENTER
    this._SizeIncr.width = 20
    this._SizeIncr.height = 3
    this._fp_beforeCreation = cast(CreateDelegate) rb_before_creation
	this._fp_afterCreation = cast(CreateDelegate) rb_after_creation
    this._inherit_color = true
    return this
}

@private new_rb1:: proc(parent: ^Form) -> ^RadioButton
{
    rb_count += 1
    rtxt:= conc_num("Radio_Button_", rb_count)
    rb:= rb_ctor(parent, rtxt, 10, 10, 100, 25 )
    if parent.createChilds do create_control(rb)
    return rb
}

@private new_rb2:: proc(parent: ^Form, txt: string) -> ^RadioButton
{
    rb:= rb_ctor(parent, txt, 10, 10, 100, 25 )
    if parent.createChilds do create_control(rb)
    return rb
}

@private new_rb3:: proc(parent: ^Form, txt: string, x, y: int) -> ^RadioButton
{
    rb:= rb_ctor(parent, txt, x, y, 100, 25 )
    if parent.createChilds do create_control(rb)
    return rb
}

@private new_rb4:: proc(parent: ^Form, txt: string, x, y, w, h: int) -> ^RadioButton
{
    rb:= rb_ctor(parent, txt, x, y, w, h )
    if parent.createChilds do create_control(rb)
    return rb
}

@private rb_adjust_styles:: proc(rb: ^RadioButton)
{
    if !rb.checkOnClick do rb._style ~= BS_AUTORADIOBUTTON
    //if rb.textAlign = .right do rb.
}

@private rb_before_creation:: proc(rb: ^RadioButton)
{
    rb_adjust_styles(rb)
}

@private rb_after_creation:: proc(rb: ^RadioButton)
{
    set_subclass(rb, rb_wnd_proc)
    if rb.autoSize do calculate_ctl_size(rb)
    if rb.checked {
        SendMessage(rb.handle, BM_SETCHECK, WPARAM(0x0001), 0)
    }
}

@private radiobutton_property_setter:: proc(this: ^RadioButton, prop: RadioButtonProps, value: $T)
{
	switch prop {
        case. Text_Alignment: break
        case .Checked: when T == bool do radiobutton_set_state(this, value)
        case .Check_On_Click: break
        case .Auto_Size: break
	}
}

@private rb_finalize:: proc(this: ^RadioButton, hw: HWND, scid: UINT_PTR)
{
    delete_gdi_object(this._hbrush)
    font_destroy(&this.font)
    widestring_destroy(this._wtext)
    free(this, context.allocator)
    RemoveWindowSubclass(hw, rb_wnd_proc, scid)
}

@private rb_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                        sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context  
    // context = runtime.default_context()  
    //display_msg(msg)
    rb:= control_cast(RadioButton, ref_data)
    res := ctrl_common_msg_handler(rb, hw, msg, wp, lp) 
    #partial switch res {
        case .Call_Def_Proc: return DefSubclassProc(hw, msg, wp, lp)
        case .Immediate_Return: return 1
    }
    switch msg {
    case WM_DESTROY: 
        rb_finalize(rb, hw, sc_id)

    case CM_CTLCOMMAND:
        if HIWORD(wp) == 0 {
            rb.checked = bool(SendMessage(rb.handle, BM_GETCHECK, 0, 0))
            if rb.onStateChanged != nil {
                ea:= new_event_args()
                rb.onStateChanged(rb, &ea)
            }
        }

    case CM_STATIC_COLOR:
        hdc:= dir_cast(wp, HDC)
        api.SetBkMode(hdc, api.BKMODE.TRANSPARENT)
        SetBkColor(hdc, get_color_ref(rb.backColor))
        rb._hbrush = CreateSolidBrush(get_color_ref(rb.backColor))
        // print("rb bkc ", rb.backColor)
        // return toLRES(rb._hbrush)
        return toLRES(rb._hbrush)

    case CM_NOTIFY:
        nmcd:= dir_cast(lp, ^NMCUSTOMDRAW)
        switch nmcd.dwDrawStage {
        case CDDS_PREERASE:
            return CDRF_NOTIFYPOSTERASE
        case CDDS_PREPAINT:
            cref:= get_color_ref(rb.foreColor)
            rct: RECT = nmcd.rc
            if rb.textAlign == .Left{
                rct.left += 18
            } else do rct.right -= 18
            SetTextColor(nmcd.hdc, cref)
            // SetBackColor(nmcd.hdc, get_color_ref(rb.backColor))
            DrawText(nmcd.hdc, rb._wtext.ptr, -1, &rct, rb._txtStyle)
            // free_all(context.temp_allocator)
            return CDRF_SKIPDEFAULT
        }

    }
    return DefSubclassProc(hw, msg, wp, lp)
}
