
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
//TODO - Use double buffering bkg fill when user changes the size of groubox.

package winforms

// import "core:fmt"
import "base:runtime"
import api "core:sys/windows"


GroupBox :: struct
{
    using control : Control,
    _bkBrush : HBRUSH,
    _pen : HPEN,
    _memDC : HDC,
    _rct : RECT,
    _txtWidth : i32,
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
        _wtext = new_widestring(txt)        
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

    font_clone(&p.font, &gb.font )  
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

@private gb_before_creation :: proc(this : ^GroupBox)
{
    this._bkBrush = get_solid_brush(this.backColor)
    this._pen = CreatePen(PS_SOLID, 5, get_color_ref(this.backColor))
    this._rct = RECT{0, 0, i32(this.width), i32(this.height)}
    this._fcref = get_color_ref(this.foreColor)
}

@private gb_double_buffer_fill :: proc(this : ^GroupBox)
{
    dc : HDC = GetDC(this.handle)
    defer ReleaseDC(this.handle, dc)
    sz : SIZE    
    select_gdi_object(dc, this.font.handle)
    GetTextExtentPoint32(dc, this._wtext.ptr, this._wtext.strLen, &sz)
    this._memDC = CreateCompatibleDC(dc)
    hBitmap : HBITMAP = CreateCompatibleBitmap(dc, i32(this.width), i32(this.height))
    select_gdi_object(this._memDC, hBitmap)
    api.FillRect(this._memDC, &this._rct, this._bkBrush)    
    this._txtWidth = sz.width + 10
    
}

@private gb_after_creation :: proc(this : ^GroupBox)
{
	set_subclass(this, gb_wnd_proc)
    gb_double_buffer_fill(this)
    
}

@private gb_finalize :: proc(this: ^GroupBox, scid: UINT_PTR)
{
    delete_gdi_object(this._bkBrush)
    delete_gdi_object(this._pen)
    DeleteDC(this._memDC)
    widestring_destroy(this._wtext)
    font_destroy(&this.font)
    RemoveWindowSubclass(this.handle, gb_wnd_proc, scid)
    free(this)
}

@private gb_wnd_proc :: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                    sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    
    //display_msg(msg)
    switch msg {
        case WM_PAINT :
            this := control_cast(GroupBox, ref_data)
            ret := DefSubclassProc(hw, msg, wp, lp)
            gfx := new_graphics(hw)
            defer gfx_destroy(gfx)
            gfx_draw_hline(gfx, this._pen, 10, 12, this._txtWidth)
            gfx_draw_text(gfx, this, 12, 0)

            // if this.onPaint != nil {
            //     ps : PAINTSTRUCT
            //     hdc := BeginPaint(hw, &ps)
            //     pea := new_paint_event_args(&ps)
            //     this.onPaint(this, &pea)
            //     EndPaint(hw, &ps)
            //     return 0
            // }

        case WM_DESTROY : 
            this := control_cast(GroupBox, ref_data)
            gb_finalize(this, sc_id)

        case WM_CONTEXTMENU:
            this := control_cast(GroupBox, ref_data)
		    if this.contextMenu != nil do contextmenu_show(this.contextMenu, lp)

        // case CM_CTLLCOLOR :
        //     hdc := dir_cast(wp, HDC)
        //     api.SetBkMode(hdc, api.BKMODE.TRANSPARENT)
        //     this._bkBrush = CreateSolidBrush(get_color_ref(this.backColor))
        //     // if this.foreColor != 0x000000 do SetTextColor(hdc, get_color_ref(this.foreColor))
        //     return dir_cast(this._bkBrush, LRESULT)
        case WM_GETTEXTLENGTH:
            return 0

        case WM_ERASEBKGND:
            this := control_cast(GroupBox, ref_data)
            hdc := dir_cast(wp, HDC)
            BitBlt(hdc, 0, 0, i32(this.width), i32(this.height), this._memDC, 0, 0, SRCCOPY)
            return 1


         case WM_MOUSEHWHEEL:
            this := control_cast(GroupBox, ref_data)
            if this.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                this.onMouseScroll(this, &mea)
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            //print("grop mouse move")
            this := control_cast(GroupBox, ref_data)
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
           this := control_cast(GroupBox, ref_data)
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