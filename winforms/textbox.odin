package winforms
import "core:runtime"
import "core:fmt"

EN_SETFOCUS :: 256
UIS_CLEAR :: 2
UISF_HIDEFOCUS :: 0x1
WcEditClassW : wstring = L("Edit")
TBSTYLE :: WS_CHILD | WS_VISIBLE | ES_LEFT | WS_TABSTOP | ES_AUTOHSCROLL | WS_OVERLAPPED | WS_CLIPCHILDREN|WS_CLIPSIBLINGS
TBEXSTYLE :: WS_EX_LEFT | WS_EX_LTRREADING  | WS_EX_CLIENTEDGE 

// Text case for Textbox control.
// Possible values : default, lower_case, upper_case
TextCase :: enum {Default, Lower_Case, Upper_Case}

// Text case for Textbox control.
// Possible values : default, number_only, password_char
TextType :: enum {Default, Number_Only, Password_Char}

// Text alignment for Textbox control.
// Possible values : left, center, right
TbTextAlign :: enum {Left, Center, Right}

TextBox :: struct 
{
    using control : Control,
    textAlignment : TbTextAlign,
    multiLine : bool,
    textType : TextType,
    textCase : TextCase,
    hideSelection : bool,
    readOnly : bool,
    cueBanner : string,
    focusRectColor : uint,
    onTextChanged : EventHandler,
    _bkBrush : HBRUSH,
    _drawFocusRect : bool,
    _frcRef : COLORREF,
}

@private tb_ctor :: proc(p : ^Form, x, y, w, h: int) -> ^TextBox 
{
    tb := new(TextBox)
    tb.kind = .Text_Box
    tb.width = w
    tb.height = h
    tb.parent = p
    tb.xpos = x
    tb.ypos = y
    tb.font = p.font
    tb.hideSelection = true
    tb.backColor = app.clrWhite
    tb.foreColor = app.clrBlack
    tb.focusRectColor = 0x007FFF
    //tb._drawFocusRect = true
    tb._frcRef = get_color_ref(tb.focusRectColor)
    tb._style = TBSTYLE  // | WS_CLIPCHILDREN
    tb._exStyle = TBEXSTYLE  // WS_EX_STATICEDGE // WS_EX_WINDOWEDGE WS_EX_CLIENTEDGE WS_EX_STATICEDGE WS_EX_WINDOWEDGE //|
    tb._clsName = WcEditClassW
    tb._fp_beforeCreation = cast(CreateDelegate) tb_before_creation
    tb._fp_afterCreation = cast(CreateDelegate) tb_after_creation
    // fmt.println("class ", tb._clsName)
    return tb
}

// TextBox control constructor.
new_textbox :: proc{new_tb1, new_tb2, new_tb3, new_tb4, new_tb5}

@private new_tb1 :: proc(parent : ^Form, rapid: b8 = false) -> ^TextBox 
{
    tb := tb_ctor(parent, 10, 10, 180, 27)
    if rapid do create_control(tb)
    return tb
}

@private new_tb2 :: proc(parent : ^Form, x, y: int, rapid: b8 = false) -> ^TextBox 
{
    tb := tb_ctor(parent, x, y, 180, 27)
    if rapid do create_control(tb)
    return tb
}

@private new_tb3 :: proc(parent : ^Form, x, y, w, h: int, rapid: b8 = false) -> ^TextBox 
{
    tb := tb_ctor(parent, x, y, w, h)
    if rapid do create_control(tb)
    return tb
}

@private new_tb4 :: proc(parent : ^Form, txt: string, x, y: int, rapid: b8 = false) -> ^TextBox 
{
    tb := tb_ctor(parent, x, y, 180, 27)
    tb.text = txt
    if rapid do create_control(tb)
    return tb
}

@private new_tb5 :: proc(parent : ^Form, txt: string, x, y, w, h: int, rapid: b8 = false) -> ^TextBox 
{
    tb := tb_ctor(parent, x, y, w, h)
    tb.text = txt
    if rapid do create_control(tb)
    return tb
}

@private adjust_styles :: proc(tb : ^TextBox) 
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

@private set_tb_bk_clr :: proc(tb : ^TextBox, clr : uint) 
{
    tb.backColor = clr
    if tb._isCreated do InvalidateRect(tb.handle, nil, false)
}

// Select or de-select all the text in TextBox control.
textbox_set_selection :: proc(tb : ^TextBox, value : bool) 
{
    wpm, lpm : i32
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
textbox_set_readonly :: proc(tb : ^TextBox, bstate : bool) 
{
    SendMessage(tb.handle, EM_SETREADONLY, WPARAM(bstate), 0)
    tb.readOnly = bstate
}

textbox_clear_all :: proc(tb : ^TextBox) 
{
    if tb._isCreated do SetWindowText(tb.handle, to_wstring(""))
}

@private tb_before_creation :: proc(tb : ^TextBox) {adjust_styles(tb)}

@private tb_after_creation :: proc(tb : ^TextBox) 
{
    set_subclass(tb, tb_wnd_proc)
    if len(tb.cueBanner) > 0 {
        up := cast(UINT_PTR) to_wstring(tb.cueBanner)
        SendMessage(tb.handle, EM_SETCUEBANNER, 1, LPARAM(up) )
    }
    EnableWindow(tb.handle, true)
}

@private tb_finalize :: proc(tb: ^TextBox, scid: UINT_PTR) 
{
    delete_gdi_object(tb._bkBrush)
    RemoveWindowSubclass(tb.handle, tb_wnd_proc, scid)
    free(tb)
}



@private tb_wnd_proc :: proc "std" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM, sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT {

    context = global_context //runtime.default_context()
    tb := control_cast(TextBox, ref_data)

    switch msg {
        case WM_PAINT :

            if tb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                tb.paint(tb, &pea)
                EndPaint(hw, &ps)
                return 0
            }



        case CM_CTLLCOLOR :
            // print("ctl clr rcvd")
            if tb.foreColor != def_fore_clr || tb.backColor != def_back_clr {
                dc_handle := direct_cast(wp, HDC)
                // SetBkMode(dc_handle, Transparent)
                if tb.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(tb.foreColor))
                SetBackColor(dc_handle, get_color_ref(tb.backColor))
                // tb._bkBrush = CreateSolidBrush(get_color_ref(tb.backColor))

            } //else do return 0

            return to_lresult(tb._bkBrush)



        // case CM_CTLCOMMAND :
        //     ncode := hiword_wparam(wp)
        //     if ncode == EN_SETFOCUS {
        //     //    tb._drawFocusRect = true
        //        //SetWindowPos(tb.handle, nil, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_DRAWFRAME)

        //        if tb.onGotFocus != nil {
        //             ea := new_event_args()
        //             tb.onGotFocus(tb, &ea)
        //             return 0
        //         }
        //     }

        case WM_LBUTTONDOWN:
           // tb._drawFocusRect = true
            tb._mDownHappened = true
            if tb.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.onMouseDown(tb, &mea)
                //return 0
            }
            //return 0

        case WM_RBUTTONDOWN :
            tb._mRDownHappened = true
            if tb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.onRightMouseDown(tb, &mea)
            }

        case WM_LBUTTONUP :
            if tb.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.onMouseUp(tb, &mea)
            }
            if tb._mDownHappened {
                tb._mDownHappened = false
                SendMessage(tb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            tb._mDownHappened = false
            if tb.onMouseClick != nil {
                ea := new_event_args()
                tb.onMouseClick(tb, &ea)
                //return 0
            }

        case WM_LBUTTONDBLCLK :
            if tb.onDoubleClick != nil {
                ea := new_event_args()
                tb.onDoubleClick(tb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if tb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.onRightMouseUp(tb, &mea)
            }
            if tb._mRDownHappened {
                tb._mRDownHappened = false
                SendMessage(tb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            tb._mRDownHappened = false
            if tb.onRightClick != nil {
                ea := new_event_args()
                tb.onRightClick(tb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if tb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.onMouseScroll(tb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if tb._isMouseEntered {
                if tb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    tb.onMouseMove(tb, &mea)
                }
            }
            else {
                tb._isMouseEntered = true
                if tb.onMouseEnter != nil  {
                    ea := new_event_args()
                    tb.onMouseEnter(tb, &ea)
                }
            }

        case WM_MOUSELEAVE :
            tb._isMouseEntered = false
            if tb.onMouseLeave != nil {
                ea := new_event_args()
                tb.onMouseLeave(tb, &ea)
            }

        case WM_SETFOCUS :
        if tb.onGotFocus != nil {
            ea := new_event_args()
            tb.onGotFocus(tb, &ea)
        }


        case WM_KILLFOCUS:

        //    tb._drawFocusRect = false
            if tb.onLostFocus != nil {
                ea := new_event_args()
                tb.onLostFocus(tb, &ea)
            }


        case WM_KEYDOWN :
           // tb._drawFocusRect = true
            if tb.onKeyDown != nil {
                kea := new_key_event_args(wp)
                tb.onKeyDown(tb, &kea)
                return 0
            }

        case WM_KEYUP :
            if tb.onKeyUp != nil {
                kea := new_key_event_args(wp)
                tb.onKeyUp(tb, &kea)
                return 0
            }

        case WM_CHAR :
            if tb.onKeyPress != nil {
                kea := new_key_event_args(wp)
                tb.onKeyPress(tb, &kea)
            }
           SendMessage(tb.handle, CM_TBTXTCHANGED, 0, 0)

        case CM_TBTXTCHANGED :
            if tb.onTextChanged != nil {
                ea:= new_event_args()
                tb.onTextChanged(tb, &ea)
            }


        case WM_DESTROY: tb_finalize(tb, sc_id)

        // case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}
