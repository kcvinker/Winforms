
/*===========================GroupBox Docs==============================
    GroupBox struct
        Constructor: new_groupbox() -> ^GroupBox
        Properties:
            All props from Control struct
        Functions:
            gbx
            gby
        Events:
            All events from Control struct
        
===============================================================================*/


package winforms

// import "core:fmt"
import "base:runtime"
import api "core:sys/windows"


GroupBox :: struct
{
    using control : Control,
    _bkBrush : HBRUSH,
    _paintBkg : b64,
}

// Groupbox control's constructor
new_groupbox :: proc{gb_ctor1, gb_ctor2}

gbx :: #force_inline proc(this: ^GroupBox, offset: int) -> int
{
    return this.xpos + offset
}

gby :: #force_inline proc(this: ^GroupBox, offset: int) -> int
{
    return this.ypos + offset
}

//==============================Private Functions==================================
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
        _clsName = &btnclass[0]
	    _fp_beforeCreation = cast(CreateDelegate) gb_before_creation
	    _fp_afterCreation = cast(CreateDelegate) gb_after_creation
        _style = gbstyle 
        _exStyle = gbexstyle // WS_EX_TRANSPARENT | WS_EX_RIGHTSCROLLBAR

    append(&p._controls, gb)
    return gb
}

@private gb_ctor1 :: proc(parent : ^Form) -> ^GroupBox
{
    gb_txt : string = conc_num("GroupBox_", gb_count)
    gb := gb_ctor(parent, gb_txt, 10, 10, 250, 250)
    gb_count += 1
    if parent.createChilds do create_control(gb)
    return gb
}

@private gb_ctor2 :: proc(parent : ^Form,
                            txt : string,
                            x, y : int,
                            w: int = 200, h: int = 200) -> ^GroupBox
{
    gb := gb_ctor(parent, txt, x, y, w, h)
    gb_count += 1
    if parent.createChilds do create_control(gb)
    return gb
}

@private gb_before_creation :: proc(gb : ^GroupBox)
{
    if gb.backColor != gb.parent.backColor do gb._paintBkg = true
}

@private gb_after_creation :: proc(this : ^GroupBox)
{
	set_subclass(this, gb_wnd_proc)
    // SetWindowTheme(gb.handle, to_wstring(" "), to_wstring(" "))
    
}

@private gb_finalize :: proc(this: ^GroupBox, scid: UINT_PTR)
{
    delete_gdi_object(this._bkBrush)
    RemoveWindowSubclass(this.handle, gb_wnd_proc, scid)
    free(this)
}

@private gb_wnd_proc :: proc "fast" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                    sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    this := control_cast(GroupBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_PAINT :
            if this.onPaint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                this.onPaint(this, &pea)
                EndPaint(hw, &ps)
                return 0
            }
        case WM_DESTROY : gb_finalize(this, sc_id)

        case WM_CONTEXTMENU:
		    if this.contextMenu != nil do contextmenu_show(this.contextMenu, lp)

        case CM_CTLLCOLOR :
            hdc := dir_cast(wp, HDC)
            api.SetBkMode(hdc, api.BKMODE.TRANSPARENT)
            this._bkBrush = CreateSolidBrush(get_color_ref(this.backColor))
            // if this.foreColor != 0x000000 do SetTextColor(hdc, get_color_ref(this.foreColor))
            return dir_cast(this._bkBrush, LRESULT)

        case WM_ERASEBKGND :
            if this._paintBkg {
                hdc := dir_cast(wp, HDC)
                rc : RECT
                GetClientRect(this.handle, &rc)
                rc.bottom -= 2
                // rc.left += 1
                api.FillRect(hdc, &rc, CreateSolidBrush(get_color_ref(this.backColor)))
                return 1
            }


         case WM_MOUSEHWHEEL:
            if this.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                this.onMouseScroll(this, &mea)
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            //print("grop mouse move")
            if this._isMouseEntered {
                if this.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    this.onMouseMove(this, &mea)
                }
            }
            else {
                this._isMouseEntered = true
                if this.onMouseEnter != nil  {
                    ea := new_event_args()
                    this.onMouseEnter(this, &ea)
                }
            }
        // case WM_NCHITTEST : // This will cause a mouse move message
        //     return 1


        case WM_MOUSELEAVE :
           // print("m leaved")
            this._isMouseEntered = false
            if this.onMouseLeave != nil {
                ea := new_event_args()
                this.onMouseLeave(this, &ea)
            }

        case :
            return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}