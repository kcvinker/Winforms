package winforms

import "core:runtime"

WcCheckBoxW : wstring = L("Button")

CheckBox :: struct
{
    using control : Control,
    checked : bool,
    textAlignment : enum {Left, Right},
    autoSize : bool,
    _bkBrush : HBRUSH,
    _txtStyle : UINT,
    // Events
    onCheckChanged : EventHandler,
}

@private _cbcount : int

@private cb_ctor :: proc(p : ^Form, txt : string, x, y, w, h: int) -> ^CheckBox
{
    this := new(CheckBox)
    _cbcount += 1
    this.kind = .Check_Box
    this._textable = true
    this.parent = p
    this.font = p.font
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
    this._clsName = WcCheckBoxW
    this._fp_beforeCreation = cast(CreateDelegate) cb_before_creation
	this._fp_afterCreation = cast(CreateDelegate) cb_after_creation
    append(&p._controls, this)
    return this
}

// Constructor for Checkbox type.
new_checkbox :: proc{new_checkbox1, new_checkbox2}

@private new_checkbox1 :: proc(parent : ^Form, txt : string = "", autoc: b8 = false) -> ^CheckBox
{
    cbtxt := len(txt) == 0 ? concat_number("CheckBox_", _cbcount ) : txt
    cb := cb_ctor(parent, cbtxt, 10, 10, 0, 0 )
    if autoc do create_control(cb)
    return cb
}

@private new_checkbox2 :: proc(parent : ^Form, txt : string, x, y : int, autoc: b8 = false) -> ^CheckBox
{
    cb := cb_ctor(parent, txt, x, y, 0, 0)
    if autoc do create_control(cb)
    return cb
}

@private new_checkbox3 :: proc(parent : ^Form, txt : string, x, y, w, h : int, autoc: b8 = false) -> ^CheckBox
{
    cb := cb_ctor(parent, txt, x, y, w, h)
    if autoc do create_control(cb)
    return cb
}

@private cb_before_creation :: proc(cb : ^CheckBox) {adjust_style(cb)}

@private cb_after_creation :: proc(cb : ^CheckBox)
{
	set_subclass(cb, cb_wnd_proc)
    append(&cb.parent._cDrawChilds, cb.handle)
    if cb.autoSize do calculate_ctl_size(cb)
}

@private adjust_style :: proc(cb : ^CheckBox)
{
    if cb.textAlignment == .Right {
        cb._style |= BS_RIGHTBUTTON
       cb._txtStyle |= DT_RIGHT
    }
}

@private checkbox_property_setter :: proc(this: ^CheckBox, prop: CheckBoxProps, value: $T)
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



@private cb_finalize :: proc(cb: ^CheckBox, scid: UINT_PTR)
{
    delete_gdi_object(cb._bkBrush)
    RemoveWindowSubclass(cb.handle, cb_wnd_proc, scid)
    free(cb)
}

@private cb_wnd_proc :: proc "std" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
                                                        sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    cb := control_cast(CheckBox, ref_data)

    switch msg
    {
        case WM_PAINT :
            if cb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cb.paint(cb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
		    if cb.contextMenu != nil do contextmenu_show(cb.contextMenu, lp)

        case CM_CTLCOMMAND :
            cb.checked = cast(bool) SendMessage(hw, BM_GETCHECK, 0, 0)
            if cb.onCheckChanged != nil {
                ea := new_event_args()
                cb.onCheckChanged(cb, &ea)
            }
        case CM_CTLLCOLOR :
            hd := direct_cast(wp, HDC)
            bkref := get_color_ref(cb.backColor)
            SetBkMode(hd, transparent)
            if cb._bkBrush == nil do cb._bkBrush = CreateSolidBrush(bkref)
            return to_lresult(cb._bkBrush)

        case CM_NOTIFY :
            nmcd := direct_cast(lp, ^NMCUSTOMDRAW)
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE :
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT :
                    cref := get_color_ref(cb.foreColor)
                    rct : RECT = nmcd.rc
                    if cb.textAlignment == .Left{
                        rct.left += 18
                    } else do rct.right -= 18
                    SetTextColor(nmcd.hdc, cref)
                    DrawText(nmcd.hdc, to_wstring(cb.text), -1, &rct, cb._txtStyle)

                    return CDRF_SKIPDEFAULT
            }

        case WM_LBUTTONDOWN:
            cb._mDownHappened = true
            if cb.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.onMouseDown(cb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            cb._mRDownHappened = true
            if cb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.onRightMouseDown(cb, &mea)
            }
        case WM_LBUTTONUP :
            if cb.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.onMouseUp(cb, &mea)
            }
            if cb._mDownHappened {
                cb._mDownHappened = false
                SendMessage(cb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if cb.onMouseClick != nil {
                ea := new_event_args()
                cb.onMouseClick(cb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            cb._mDownHappened = false
            if cb.onDoubleClick != nil {
                ea := new_event_args()
                cb.onDoubleClick(cb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if cb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.onRightMouseUp(cb, &mea)
            }
            if cb._mRDownHappened {
                cb._mRDownHappened = false
                SendMessage(cb.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            cb._mRDownHappened = false
            if cb.onRightClick != nil {
                ea := new_event_args()
                cb.onRightClick(cb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if cb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.onMouseScroll(cb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if cb._isMouseEntered {
                if cb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    cb.onMouseMove(cb, &mea)
                }
            }
            else {
                cb._isMouseEntered = true
                if cb.onMouseEnter != nil  {
                    ea := new_event_args()
                    cb.onMouseEnter(cb, &ea)
                }
            }
        //end case--------------------

        case WM_MOUSELEAVE :
            cb._isMouseEntered = false
            if cb.onMouseLeave != nil {
                ea := new_event_args()
                cb.onMouseLeave(cb, &ea)
            }


        case WM_DESTROY : cb_finalize(cb, sc_id)


        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}