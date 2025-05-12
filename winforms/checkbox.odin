
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
    textAlignment: enum {Left, Right},
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
    this.kind = .Check_Box
    this._textable = true
    this.parent = p
    this._wtext = new_widestring(txt)
    this.text = txt
    this.xpos = x
    this.ypos = y
    this.width = w
    this.height = h
    this.backColor = p.backColor
    this.foreColor = app.clrBlack
    this._exStyle = 0
    this._style = WS_CHILD | WS_VISIBLE | BS_AUTOCHECKBOX
    this._exStyle =  WS_EX_LTRREADING | WS_EX_LEFT
    this._txtStyle = DT_SINGLELINE | DT_VCENTER
    this.autoSize = true
    this._SizeIncr.width = 20
    this._SizeIncr.height = 3
    this._clsName = &btnclass[0]
    this._fp_beforeCreation = cast(CreateDelegate) cb_before_creation
	this._fp_afterCreation = cast(CreateDelegate) cb_after_creation
    font_clone(&p.font, &this.font )
    append(&p._controls, this)
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
    if cb.textAlignment == .Right {
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
    
    switch msg {
        case WM_PAINT:
            cb:= control_cast(CheckBox, ref_data)
            if cb.onPaint != nil {
                ps: PAINTSTRUCT
                hdc:= BeginPaint(hw, &ps)
                pea:= new_paint_event_args(&ps)
                cb.onPaint(cb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
            cb:= control_cast(CheckBox, ref_data)
		    if cb.contextMenu != nil do contextmenu_show(cb.contextMenu, lp)

        case CM_CTLCOMMAND:
            cb:= control_cast(CheckBox, ref_data)
            cb.checked = cast(bool) SendMessage(hw, BM_GETCHECK, 0, 0)
            if cb.onCheckChanged != nil {
                ea:= new_event_args()
                cb.onCheckChanged(cb, &ea)
            }

        case CM_CTLLCOLOR:
            cb:= control_cast(CheckBox, ref_data)
            hd:= dir_cast(wp, HDC)
            bkref:= get_color_ref(cb.backColor)
            api.SetBkMode(hd, api.BKMODE.TRANSPARENT)
            if cb._bkBrush == nil do cb._bkBrush = CreateSolidBrush(bkref)
            return toLRES(cb._bkBrush)

        case CM_NOTIFY:
            cb:= control_cast(CheckBox, ref_data)
            nmcd:= dir_cast(lp, ^NMCUSTOMDRAW)
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE:
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT:
                    cref:= get_color_ref(cb.foreColor)
                    rct: RECT = nmcd.rc
                    if cb.textAlignment == .Left{
                        rct.left += 18
                    } else do rct.right -= 18
                    SetTextColor(nmcd.hdc, cref)
                    DrawText(nmcd.hdc, to_wstring(cb.text), -1, &rct, cb._txtStyle)
                    // // free_all(context.temp_allocator)
                    return CDRF_SKIPDEFAULT
            }

        case WM_LBUTTONDOWN: 
            cb:= control_cast(CheckBox, ref_data)           
            if cb.onMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                cb.onMouseDown(cb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN: 
            cb:= control_cast(CheckBox, ref_data)           
            if cb.onRightMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                cb.onRightMouseDown(cb, &mea)
            }

        case WM_LBUTTONUP:
            cb:= control_cast(CheckBox, ref_data)
            if cb.onMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                cb.onMouseUp(cb, &mea)
            }
            if cb.onClick != nil {
                ea:= new_event_args()
                cb.onClick(cb, &ea)
                return 0
            }           

        case WM_LBUTTONDBLCLK: 
            cb:= control_cast(CheckBox, ref_data)           
            if cb.onDoubleClick != nil {
                ea:= new_event_args()
                cb.onDoubleClick(cb, &ea)
                return 0
            }

        case WM_RBUTTONUP:
            cb:= control_cast(CheckBox, ref_data)
            if cb.onRightMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                cb.onRightMouseUp(cb, &mea)
            }
           if cb.onRightClick != nil {
                ea:= new_event_args()
                cb.onRightClick(cb, &ea)
                return 0
            }       

        case WM_MOUSEHWHEEL:
            cb:= control_cast(CheckBox, ref_data)
            if cb.onMouseScroll != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                cb.onMouseScroll(cb, &mea)
            }

        case WM_MOUSEMOVE: // Mouse Enter & Mouse Move is happening here.
            cb:= control_cast(CheckBox, ref_data)
            if cb._isMouseEntered {
                if cb.onMouseMove != nil {
                    mea:= new_mouse_event_args(msg, wp, lp)
                    cb.onMouseMove(cb, &mea)
                }
            }
            else {
                cb._isMouseEntered = true
                if cb.onMouseEnter != nil  {
                    ea:= new_event_args()
                    cb.onMouseEnter(cb, &ea)
                }
            }

        case WM_MOUSELEAVE:
            cb:= control_cast(CheckBox, ref_data)
            cb._isMouseEntered = false
            if cb.onMouseLeave != nil {
                ea:= new_event_args()
                cb.onMouseLeave(cb, &ea)
            }

        case WM_DESTROY: 
            cb:= control_cast(CheckBox, ref_data)
            cb_finalize(cb, sc_id)

        case: return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}