
/*===========================================CheckBox Docs=========================================================
    CheckBox struct
        Constructor: new_checkBox() -> ^CheckBox
        Properties:
            All props from Control struct
            checked        : bool
            textAlignment  : enum {Left, Right}
            autoSize       : bool
        Functions:
        Events:
            EventHandler type -proc(^Control, ^EventArgs) [See events.odin]
                onCheckChanged
        
==============================================================================================================*/




package winforms

import "base:runtime"
import api "core:sys/windows"

@private _cbcount: int

CheckBox:: struct
{
    using control: Control,
    checked: bool,
    textAlign: Alignment,
    autoSize: bool,
    _bkBrush: HBRUSH,
    _txtStyle: UINT,
    // Events
    onCheckChanged: EventHandler,
}

// Constructor for Checkbox type.
new_checkbox:: proc{new_checkbox1, new_checkbox2}


//===================================================Private functions=============================================
@private cb_ctor:: proc(p: ^Form, txt: string, x, y, w, h: int) -> ^CheckBox
{
    this:= new(CheckBox)
    _cbcount += 1
    init_control(this, p, x, y, w, h, .Check_Box, COMM_CTRL_STYLES | BS_AUTOCHECKBOX, 
                    WS_EX_LTRREADING | WS_EX_LEFT, wcnButton, TXTABLE, FONTABLE)
    this._wtext = new_widestring(txt)
    this.text = txt
    this.backColor = p.backColor
    this.foreColor = app.clrBlack
    this._txtStyle = DT_SINGLELINE | DT_VCENTER
    this.autoSize = true
    this._SizeIncr.width = 20
    this._SizeIncr.height = 3
    this._fp_beforeCreation = cast(CreateDelegate) cb_before_creation
	this._fp_afterCreation = cast(CreateDelegate) cb_after_creation
    return this
}

@private new_checkbox1:: proc(parent: ^Form, txt: string = "") -> ^CheckBox
{
    cbtxt:= len(txt) == 0 ? conc_num("CheckBox_", _cbcount ): txt
    cb:= cb_ctor(parent, cbtxt, 10, 10, 0, 0 )
    if parent.createChilds do create_control(cb)
    return cb
}

@private new_checkbox2:: proc(parent: ^Form, txt: string, x, y: int) -> ^CheckBox
{
    cb:= cb_ctor(parent, txt, x, y, 0, 0)
    if parent.createChilds do create_control(cb)
    return cb
}

@private new_checkbox3:: proc(parent: ^Form, txt: string, x, y, w, h: int) -> ^CheckBox
{
    cb:= cb_ctor(parent, txt, x, y, w, h)
    if parent.createChilds do create_control(cb)
    return cb
}

@private cb_before_creation:: proc(cb: ^CheckBox) {adjust_style(cb)}

@private cb_after_creation:: proc(cb: ^CheckBox)
{
	set_subclass(cb, cb_wnd_proc)
    append(&cb.parent._cDrawChilds, cb.handle)
    if cb.autoSize do calculate_ctl_size(cb)
}

@private adjust_style:: proc(cb: ^CheckBox)
{
    if cb.textAlign == .Right {
        cb._style |= BS_RIGHTBUTTON
       cb._txtStyle |= DT_RIGHT
    }
}

@private checkbox_property_setter:: proc(this: ^CheckBox, prop: CheckBoxProps, value: $T)
{
	switch prop {
		case .Checked:
            when T == bool {
                this.checked = value
                if this._isCreated do SendMessage(this.handle, BM_SETCHECK, auto_cast(value), 0)
            }
		case .Text_Alignment: break

		case .Auto_Size:
            when T == bool {
                this.autoSize = value
                if this._isCreated do InvalidateRect(this.handle, nil, false)
            }
	}
}

@private cb_finalize:: proc(this: ^CheckBox, scid: UINT_PTR)
{
    delete_gdi_object(this._bkBrush)
    widestring_destroy(this._wtext)
    font_destroy(&this.font)
    RemoveWindowSubclass(this.handle, cb_wnd_proc, scid)
    free(this)
}

@private cb_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                                        sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context
    // context = runtime.default_context()
     cb:= control_cast(CheckBox, ref_data)
    res := ctrl_common_msg_handler(cb, hw, msg, wp, lp) 
    #partial switch res {
        case .Call_Def_Proc: return DefSubclassProc(hw, msg, wp, lp)
        case .Immediate_Return: return 1
    }
    switch msg {
        case WM_PAINT:           
            if cb.onPaint != nil {
                ps: PAINTSTRUCT
                hdc:= BeginPaint(hw, &ps)
                pea:= new_paint_event_args(&ps)
                cb.onPaint(cb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case CM_CTLCOMMAND:
            cb.checked = cast(bool) SendMessage(hw, BM_GETCHECK, 0, 0)
            if cb.onCheckChanged != nil {
                ea:= new_event_args()
                cb.onCheckChanged(cb, &ea)
            }

        case CM_STATIC_COLOR:
            hd:= dir_cast(wp, HDC)
            bkref:= get_color_ref(cb.backColor)
            api.SetBkMode(hd, api.BKMODE.TRANSPARENT)
            if cb._bkBrush == nil do cb._bkBrush = CreateSolidBrush(bkref)
            return toLRES(cb._bkBrush)

        case CM_NOTIFY:
            nmcd:= dir_cast(lp, ^NMCUSTOMDRAW)
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE:
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT:
                    cref:= get_color_ref(cb.foreColor)
                    rct: RECT = nmcd.rc
                    if cb.textAlign == .Left{
                        rct.left += 18
                    } else do rct.right -= 18
                    SetTextColor(nmcd.hdc, cref)
                    DrawText(nmcd.hdc, to_wstring(cb.text), -1, &rct, cb._txtStyle)
                    // // free_all(context.temp_allocator)
                    return CDRF_SKIPDEFAULT
            }

        case WM_DESTROY: 
            cb:= control_cast(CheckBox, ref_data)
            cb_finalize(cb, sc_id)

        case: return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}