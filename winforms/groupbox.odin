package winforms

// import "core:fmt"
import "core:runtime"
import api "core:sys/windows"

WcGroupBoxW : wstring = L("Button")

GroupBox :: struct
{
    using control : Control,
    _bkBrush : HBRUSH,
    _paintBkg : b64,
}

@private gb_count : int = 1

@private gb_ctor :: proc(p : ^Form, txt : string, x, y, w, h : int) -> ^GroupBox
{
    // if WcGroupBoxW == nil do WcGroupBoxW = to_wstring()
    gb := new(GroupBox)
    using gb
        kind = .Group_Box
        _textable = true
        parent = p
        font = p.font
        xpos = x
        ypos = y
        text = txt
        width = w
        height = h
        backColor = p.backColor
        foreColor = p.foreColor
        _clsName = WcGroupBoxW
	    _fp_beforeCreation = cast(CreateDelegate) gb_before_creation
	    _fp_afterCreation = cast(CreateDelegate) gb_after_creation

        _style = WS_CHILD | WS_VISIBLE | BS_GROUPBOX | BS_NOTIFY | BS_TEXT | BS_TOP | WS_OVERLAPPED| WS_CLIPCHILDREN| WS_CLIPSIBLINGS
        _exStyle = WS_EX_TRANSPARENT | WS_EX_CONTROLPARENT | WS_EX_RIGHTSCROLLBAR

    append(&p._controls, gb)
    return gb
}

@private gb_ctor1 :: proc(parent : ^Form, autoc: b8 = false) -> ^GroupBox
{
    gb_txt : string = concat_number("GroupBox_", gb_count)
    gb := gb_ctor(parent, gb_txt, 10, 10, 250, 250)
    gb_count += 1
    if autoc do create_control(gb)
    return gb
}

@private gb_ctor2 :: proc(parent : ^Form,
                            txt : string,
                            x, y : int,
                            w: int = 200, h: int = 200,
                            autoc: b8 = false) -> ^GroupBox
{
    gb := gb_ctor(parent, txt, x, y, w, h)
    gb_count += 1
    if autoc do create_control(gb)
    return gb
}

// Groupbox control's constructor
new_groupbox :: proc{gb_ctor1, gb_ctor2}

@private gb_before_creation :: proc(gb : ^GroupBox)
{
    if gb.backColor != gb.parent.backColor do gb._paintBkg = true
}

@private gb_after_creation :: proc(gb : ^GroupBox)
{
	set_subclass(gb, gb_wnd_proc)
    SetWindowTheme(gb.handle, to_wstring(" "), to_wstring(" "))
}

gbx :: #force_inline proc(gb: ^GroupBox, offset: int) -> int
{
    return gb.xpos + offset
}

gby :: #force_inline proc(gb: ^GroupBox, offset: int) -> int
{
    return gb.ypos + offset
}

@private gb_finalize :: proc(gb: ^GroupBox, scid: UINT_PTR)
{
    delete_gdi_object(gb._bkBrush)
    RemoveWindowSubclass(gb.handle, gb_wnd_proc, scid)
    free(gb)
}

@private gb_wnd_proc :: proc "std" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                    sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    gb := control_cast(GroupBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_PAINT :
            if gb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                gb.paint(gb, &pea)
                EndPaint(hw, &ps)
                return 0
            }
        case WM_DESTROY : gb_finalize(gb, sc_id)

        case CM_CTLLCOLOR :
            hdc := direct_cast(wp, HDC)
            SetBkMode(hdc, Transparent)
            gb._bkBrush = CreateSolidBrush(get_color_ref(gb.backColor))
            // if gb.foreColor != 0x000000 do SetTextColor(hdc, get_color_ref(gb.foreColor))
            return direct_cast(gb._bkBrush, LRESULT)

        case WM_ERASEBKGND :
            if gb._paintBkg {
                hdc := direct_cast(wp, HDC)
                rc : RECT
                GetClientRect(gb.handle, &rc)
                rc.bottom -= 2
                // rc.left += 1
                api.FillRect(hdc, &rc, CreateSolidBrush(get_color_ref(gb.backColor)))
                return 1
            }


         case WM_MOUSEHWHEEL:
            if gb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                gb.onMouseScroll(gb, &mea)
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            //print("grop mouse move")
            if gb._isMouseEntered {
                if gb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    gb.onMouseMove(gb, &mea)
                }
            }
            else {
                gb._isMouseEntered = true
                if gb.onMouseEnter != nil  {
                    ea := new_event_args()
                    gb.onMouseEnter(gb, &ea)
                }
            }
        // case WM_NCHITTEST : // This will cause a mouse move message
        //     return 1


        case WM_MOUSELEAVE :
           // print("m leaved")
            gb._isMouseEntered = false
            if gb.onMouseLeave != nil {
                ea := new_event_args()
                gb.onMouseLeave(gb, &ea)
            }

        case :
            return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}