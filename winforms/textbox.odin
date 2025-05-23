
/*===========================================TextBox Docs=========================================================
    TextBox struct
        Constructor: new_textbox() -> ^TextBox
        Properties:
            All props from Control struct
            textAlignment  : TbTextAlign - An enum in this file
            multiLine      : bool
            textType       : TextType - An enum in this file
            textCase       : TextCase - An enum in this file
            hideSelection  : bool
            readOnly       : bool
            cueBanner      : string
            focusRectColor : uint
        Functions:
			textbox_set_selection
            textbox_set_readonly
            textbox_clear_all

        Events:
			All events from Control struct
            onTextChanged - EventHandler type [proc(^Control, ^EventARgs)]
==============================================================================================================*/


package winforms
import "base:runtime"
import "core:fmt"
import api "core:sys/windows"


WcEditClassW: wstring = L("Edit")



TextBox:: struct
{
    using control: Control,
    textAlignment: TbTextAlign,
    multiLine: bool,
    textType: TextType,
    textCase: TextCase,
    hideSelection: bool,
    readOnly: bool,
    cueBanner: string,
    focusRectColor: uint,

    onTextChanged: EventHandler,
    _bkBrush: HBRUSH,
    _drawFocusRect: bool,
    _frcRef: COLORREF,
}

// TextBox control constructor.
new_textbox:: proc{new_tb1, new_tb2, new_tb3, new_tb4, new_tb5}

// Select or de-select all the text in TextBox control.
textbox_set_selection:: proc(tb: ^TextBox, value: bool)
{
    wpm, lpm: i32
    if value {
        wpm = 0
        lpm = -1
    } else {
        wpm = -1
        lpm = 0
    }
    SendMessage(tb.handle, EM_SETSEL, WPARAM(wpm), LPARAM(lpm))
}

// Set a TextBox's read only state.
textbox_set_readonly:: proc(tb: ^TextBox, bstate: bool)
{
    SendMessage(tb.handle, EM_SETREADONLY, WPARAM(bstate), 0)
    tb.readOnly = bstate
}

textbox_clear_all:: proc(tb: ^TextBox)
{
    if tb._isCreated {
        SetWindowText(tb.handle, to_wstring(""))
        // free_all(context.temp_allocator)
    }
}

//==========================================Private Functions==================================
@private tb_ctor:: proc(p: ^Form, x, y, w, h: int) -> ^TextBox
{
    this:= new(TextBox)
    this.kind = .Text_Box
    this._textable = true
    this.width = w
    this.height = h
    this.parent = p
    this.xpos = x
    this.ypos = y
    this.hideSelection = true
    this.backColor = app.clrWhite
    this.foreColor = app.clrBlack
    this.focusRectColor = 0x007FFF
    this._frcRef = get_color_ref(this.focusRectColor)
    this._style = TBSTYLE  // | WS_CLIPCHILDREN
    this._exStyle = TBEXSTYLE  
    this._clsName = WcEditClassW
    this._fp_beforeCreation = cast(CreateDelegate) tb_before_creation
    this._fp_afterCreation = cast(CreateDelegate) tb_after_creation
    font_clone(&p.font, &this.font )
    append(&p._controls, this)
    return this
}

@private new_tb1:: proc(parent: ^Form) -> ^TextBox
{
    tb:= tb_ctor(parent, 10, 10, 180, 27)
    if parent.createChilds do create_control(tb)
    return tb
}

@private new_tb2:: proc(parent: ^Form, x, y: int) -> ^TextBox
{
    tb:= tb_ctor(parent, x, y, 180, 27)
    if parent.createChilds do create_control(tb)
    return tb
}

@private new_tb3:: proc(parent: ^Form, x, y, w, h: int) -> ^TextBox
{
    tb:= tb_ctor(parent, x, y, w, h)
    if parent.createChilds do create_control(tb)
    return tb
}

@private new_tb4:: proc(parent: ^Form, txt: string, x, y: int) -> ^TextBox
{
    tb:= tb_ctor(parent, x, y, 180, 27)
    tb.text = txt
    tb._wtext = new_widestring(txt)
    if parent.createChilds do create_control(tb)
    return tb
}

@private new_tb5:: proc(parent: ^Form, txt: string, x, y, w, h: int) -> ^TextBox
{
    tb:= tb_ctor(parent, x, y, w, h)
    tb.text = txt
    if parent.createChilds do create_control(tb)
    return tb
}

@private adjust_styles:: proc(tb: ^TextBox)
{
    if tb.multiLine do tb._style |= ES_MULTILINE | ES_WANTRETURN
    if !tb.hideSelection do tb._style |= ES_NOHIDESEL
    if tb.readOnly do tb._style |= ES_READONLY

    if tb.textCase == .Lower_Case { tb._style |= ES_LOWERCASE }
    else if tb.textCase == .Upper_Case { tb._style |= ES_UPPERCASE }

    if tb.textType == .Number_Only { tb._style |= ES_NUMBER }
    else if tb.textType == .Password_Char { tb._style |= ES_PASSWORD }

    if tb.textAlignment == .Center { tb._style |= ES_CENTER }
    else if tb.textAlignment == .Right { tb._style |= ES_RIGHT }
    tb._bkBrush = get_solid_brush(tb.backColor)
}

@private set_tb_bk_clr:: proc(tb: ^TextBox, clr: uint)
{
    tb.backColor = clr
    if tb._isCreated do InvalidateRect(tb.handle, nil, false)
}

@private tb_before_creation:: proc(tb: ^TextBox) {adjust_styles(tb)}

@private tb_after_creation:: proc(tb: ^TextBox)
{
    set_subclass(tb, tb_wnd_proc)
    if len(tb.cueBanner) > 0 {
        up:= cast(UINT_PTR) to_wstring(tb.cueBanner)
        SendMessage(tb.handle, EM_SETCUEBANNER, 1, LPARAM(up) )
        // free_all(context.temp_allocator)
    }
    api.EnableWindow(tb.handle, true)
}

@private textbox_property_setter:: proc(this: ^TextBox, prop: TextBoxProps, value: $T)
{
	switch prop {
        case .Text_Alignment: break
        case .Multi_Line: break
        case .Text_Type: break
        case .Text_Case: break
        case .Hide_Selection: break
        case .Read_Only: break
        case .Cue_Banner:
            when T == string {
                this.cueBanner = value
                if this._isCreated {
                    SendMessage(this.handle, EM_SETCUEBANNER, 1, dir_cast(to_wstring(value), LPARAM))
                    // free_all(context.temp_allocator)
                }
            }
	}
}

@private tb_finalize:: proc(this: ^TextBox, scid: UINT_PTR)
{
    delete_gdi_object(this._bkBrush)
    font_destroy(&this.font)
    if this._wtext != nil do widestring_destroy(this._wtext)
    RemoveWindowSubclass(this.handle, tb_wnd_proc, scid)
    free(this)
}

@private tb_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM, sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT {

    context = global_context //runtime.default_context()

    switch msg {
        case WM_PAINT:
            tb:= control_cast(TextBox, ref_data)
            if tb.onPaint != nil {
                ps: PAINTSTRUCT
                hdc:= BeginPaint(hw, &ps)
                pea:= new_paint_event_args(&ps)
                tb.onPaint(tb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
            tb:= control_cast(TextBox, ref_data)
		    if tb.contextMenu != nil do contextmenu_show(tb.contextMenu, lp)

        case CM_CTLLCOLOR:
            tb:= control_cast(TextBox, ref_data)
            // print("ctl clr rcvd")
            if tb.foreColor != def_fore_clr || tb.backColor != def_back_clr {
                dc_handle:= dir_cast(wp, HDC)
                // SetBkMode(dc_handle, Transparent)
                if tb.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(tb.foreColor))
                SetBackColor(dc_handle, get_color_ref(tb.backColor))
                // tb._bkBrush = CreateSolidBrush(get_color_ref(tb.backColor))

            } //else do return 0

            return toLRES(tb._bkBrush)



        // case CM_CTLCOMMAND:
        //     ncode:= HIWORD(wp)
        //     if ncode == EN_SETFOCUS {
        //     //    tb._drawFocusRect = true
        //        //SetWindowPos(tb.handle, nil, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_DRAWFRAME)

        //        if tb.onGotFocus != nil {
        //             ea:= new_event_args()
        //             tb.onGotFocus(tb, &ea)
        //             return 0
        //         }
        //     }

        case WM_LBUTTONDOWN:
            tb:= control_cast(TextBox, ref_data)
           // tb._drawFocusRect = true            
            if tb.onMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tb.onMouseDown(tb, &mea)
                //return 0
            }            

        case WM_RBUTTONDOWN:   
            tb:= control_cast(TextBox, ref_data)         
            if tb.onRightMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tb.onRightMouseDown(tb, &mea)
            }

        case WM_LBUTTONUP:
            tb:= control_cast(TextBox, ref_data)
            if tb.onMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tb.onMouseUp(tb, &mea)
            }            
            if tb.onClick != nil {
                ea:= new_event_args()
                tb.onClick(tb, &ea)
                //return 0
            }

        case WM_LBUTTONDBLCLK:
            tb:= control_cast(TextBox, ref_data)
            if tb.onDoubleClick != nil {
                ea:= new_event_args()
                tb.onDoubleClick(tb, &ea)
                return 0
            }

        case WM_RBUTTONUP:
            tb:= control_cast(TextBox, ref_data)
            if tb.onRightMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tb.onRightMouseUp(tb, &mea)
            }            
            if tb.onRightClick != nil {
                ea:= new_event_args()
                tb.onRightClick(tb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            tb:= control_cast(TextBox, ref_data)
            if tb.onMouseScroll != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tb.onMouseScroll(tb, &mea)
            }
        case WM_MOUSEMOVE: // Mouse Enter & Mouse Move is happening here.
            tb:= control_cast(TextBox, ref_data)
            if tb._isMouseEntered {
                if tb.onMouseMove != nil {
                    mea:= new_mouse_event_args(msg, wp, lp)
                    tb.onMouseMove(tb, &mea)
                }
            }
            else {
                tb._isMouseEntered = true
                if tb.onMouseEnter != nil  {
                    ea:= new_event_args()
                    tb.onMouseEnter(tb, &ea)
                }
            }

        case WM_MOUSELEAVE:
            tb:= control_cast(TextBox, ref_data)
            tb._isMouseEntered = false
            if tb.onMouseLeave != nil {
                ea:= new_event_args()
                tb.onMouseLeave(tb, &ea)
            }

        case WM_SETFOCUS:
            tb:= control_cast(TextBox, ref_data)
            if tb.onGotFocus != nil {
                ea:= new_event_args()
                tb.onGotFocus(tb, &ea)
            }

        case WM_KILLFOCUS:
            tb:= control_cast(TextBox, ref_data)
        //    tb._drawFocusRect = false
            if tb.onLostFocus != nil {
                ea:= new_event_args()
                tb.onLostFocus(tb, &ea)
            }

        case WM_KEYDOWN:
            tb:= control_cast(TextBox, ref_data)
           // tb._drawFocusRect = true
            if tb.onKeyDown != nil {
                kea:= new_key_event_args(wp)
                tb.onKeyDown(tb, &kea)
                return 0
            }

        case WM_KEYUP:
            tb:= control_cast(TextBox, ref_data)
            if tb.onKeyUp != nil {
                kea:= new_key_event_args(wp)
                tb.onKeyUp(tb, &kea)
                return 0
            }

        case WM_CHAR:
            tb:= control_cast(TextBox, ref_data)
            if tb.onKeyPress != nil {
                kea:= new_key_event_args(wp)
                tb.onKeyPress(tb, &kea)
            }
           SendMessage(tb.handle, CM_TBTXTCHANGED, 0, 0)

        case CM_TBTXTCHANGED:
            tb:= control_cast(TextBox, ref_data)
            if tb.onTextChanged != nil {
                ea:= new_event_args()
                tb.onTextChanged(tb, &ea)
            }

        case WM_DESTROY: 
            tb:= control_cast(TextBox, ref_data)
            tb_finalize(tb, sc_id)

        // case: return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}
