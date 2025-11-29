
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

PENWIDTH :i32: 4


GroupBox :: struct
{
    using control : Control,
    _gbStyle: GroupBoxStyle,
    _bkBrush : HBRUSH,
    _hbmp: HBITMAP,
    _pen : HPEN,
    _memDC : HDC,
    _rct : RECT,
    _txtWidth : i32,
    _paintBkg : b64,
    _dbFill: b64,
    _getWidth: b64,
    _themeOff: b64,
    _controls : [dynamic]^Control,
    
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

@private gb_ctor :: proc(p : ^Form, txt : string, x, y, w, h : int, gStyle: GroupBoxStyle) -> ^GroupBox
{
    // if WcGroupBoxW == nil do WcGroupBoxW = to_wstring()
    gb := new(GroupBox)
    using gb
        kind = .Group_Box
        _textable = true
        _dbFill = true
        _getWidth = true
        _gbStyle = gStyle
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
        _style = gbstyleFlag 
        _exStyle = gbexstyle // WS_EX_TRANSPARENT | WS_EX_RIGHTSCROLLBAR

    font_clone(&p.font, &gb.font )  
    append(&p._controls, gb)
    return gb
}

@private gb_ctor1 :: proc(parent : ^Form) -> ^GroupBox
{
    gb_txt : string = conc_num("GroupBox_", gb_count)
    gb := gb_ctor(parent, gb_txt, 10, 10, 250, 250, .System)
    gb_count += 1
    if parent.createChilds do create_control(gb)
    return gb
}

@private gb_ctor2 :: proc(parent : ^Form,
                            txt : string,
                            x, y : int, w: int = 200, h: int = 200, 
                            style: GroupBoxStyle = .System) -> ^GroupBox
{
    gb := gb_ctor(parent, txt, x, y, w, h, style)
    gb_count += 1
    if parent.createChilds do create_control(gb)
    return gb
}

@private gb_before_creation :: proc(this : ^GroupBox)
{
    this._bkBrush = get_solid_brush(this.backColor)
    if this._gbStyle == .Overriden {
        this._pen = CreatePen(PS_SOLID, PENWIDTH, get_color_ref(this.backColor))
    }
    this._rct = RECT{0, 0, i32(this.width), i32(this.height)}
    this._fcref = get_color_ref(this.foreColor)
}

@private gb_after_creation :: proc(this : ^GroupBox)
{
    if this._gbStyle == .Classic {
        SetWindowTheme(this.handle, EWCAPTR, EWCAPTR)
        this._themeOff = true
    }
	set_subclass(this, gb_wnd_proc)  
    // ptf("gb style %s", this._gbStyle)  
}

gbx_add_controls :: proc(this: ^GroupBox, items: ..^Control) {
    if this._isCreated {
        for item in items {
           append(&this._controls, item)
           if item.kind == .Label do item.backColor = this.backColor
        }
    }
}

gbx_set_backcolor :: proc(this: ^GroupBox, clr: uint)
{
    this.backColor = clr
    resetGdiObjects(this, true)
    check_redraw(this)
}

gbx_set_height :: proc(this: ^GroupBox, value: int)
{
    this.height = value
    resetGdiObjects(this, false)
    if this._isCreated do control_setpos(this, SWP_NOZORDER)
}

gbx_set_width :: proc(this: ^GroupBox, value: int)
{
    this.width = value
    resetGdiObjects(this, false)
    if this._isCreated do control_setpos(this, SWP_NOZORDER)
}

gbx_set_text :: proc(this: ^GroupBox, value: string)
{
    this.text = value
    widestring_update(&this._wtext, value)
    this._getWidth = true
    if this._isCreated do SetWindowText(this.handle, this._wtext.ptr)
    check_redraw(this)
}

gbx_set_font :: proc(this: ^GroupBox, fname: string, fsize: int, fweight: FontWeight = .Normal)
{
    font_change_font(&this.font, fname, fsize, fweight)
    this._getWidth = true
    ctl_send_msg(this.handle, WM_SETFONT, this.font.handle, 1)
    check_redraw(this)
}

gbx_set_font1 :: proc(this: ^GroupBox, value: ^Font) {
    font_clone(&this.font, value)
    this._getWidth = true
    ctl_send_msg(this.handle, WM_SETFONT, this.font.handle, 1)
    check_redraw(this)
}

gbx_set_style :: proc(this: ^GroupBox, value: GroupBoxStyle) {
    this._gbStyle = value
    if value == .Classic {
        if !this._themeOff {
            SetWindowTheme(this.handle, EWCAPTR, EWCAPTR)
            this._themeOff = true
        }
    } else if value == .Overriden {
        this._getWidth = true
        this._pen = CreatePen(PS_SOLID, PENWIDTH, get_color_ref(this.backColor))
    }
    check_redraw(this)
}


@private resetGdiObjects :: proc(this: ^GroupBox, brpn: b64) 
{
    if brpn {
        if this._bkBrush != nil do delete_gdi_object(this._bkBrush)
        this._bkBrush = get_solid_brush(this.backColor)
        if this._gbStyle == .Overriden {
            if this._pen != nil do delete_gdi_object(this._pen)        
            this._pen = CreatePen(PS_SOLID, PENWIDTH, get_color_ref(this.backColor))
        }
    }
    if this._memDC != nil do DeleteDC(this._memDC)
    if this._hbmp != nil do delete_gdi_object(this._hbmp)    
    this._dbFill = true
}

@private gbx_property_setter:: proc(this: ^GroupBox, prop: GroupBoxProps, value: $T)
{
	switch prop {
		case .Back_Color:
            when T == uint do gbx_set_backcolor(this, value)
        case .Font:
            when T == Font do gbx_set_font1(this, value)
		case .Height:
            when T == int do gbx_set_height(this, value)            
		case .Text:
            when T == string do gbx_set_text(this, value)
		case .Width:
            when T == int do gbx_set_width(this, value)
	}
}

@private gb_finalize :: proc(this: ^GroupBox)
{
    delete_gdi_object(this._bkBrush)
    delete_gdi_object(this._pen)
    delete_gdi_object(this._hbmp)
    DeleteDC(this._memDC)
    widestring_destroy(this._wtext)
    font_destroy(&this.font)  
    delete(this._controls)  
    free(this)
}

@private gb_wnd_proc :: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                    sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    
    //display_msg(msg)
    switch msg {
         case WM_DESTROY : 
            RemoveWindowSubclass(hw, gb_wnd_proc, sc_id)
            this := control_cast(GroupBox, ref_data)
            gb_finalize(this)

        case WM_PAINT :            
            this := control_cast(GroupBox, ref_data)
            if this._gbStyle == .Overriden {
                ret := DefSubclassProc(hw, msg, wp, lp)
                gfx := new_graphics(hw)
                defer gfx_destroy(gfx)
                gfx_draw_hline(gfx, this._pen, 10, 12, this._txtWidth)
                gfx_draw_text(gfx, this, 12, 0)
            }


        case WM_CONTEXTMENU:
            this := control_cast(GroupBox, ref_data)
		    if this.contextMenu != nil do contextmenu_show(this.contextMenu, lp)

        case CM_STATIC_COLOR:
            this := control_cast(GroupBox, ref_data)
            if this._gbStyle == .Classic {
                hdc := dir_cast(wp, HDC)
                api.SetBkMode(hdc, api.BKMODE.TRANSPARENT)                
                SetTextColor(hdc, get_color_ref(this.foreColor))
            }
            return dir_cast(this._bkBrush, LRESULT)

        case WM_GETTEXTLENGTH:
            this := control_cast(GroupBox, ref_data)
            if this._gbStyle == .Overriden do return 0

        case WM_ERASEBKGND:
            this := control_cast(GroupBox, ref_data)
            hdc := dir_cast(wp, HDC)
            if this._getWidth {
                sz : SIZE    
                select_gdi_object(hdc, this.font.handle)
                GetTextExtentPoint32(hdc, this._wtext.ptr, this._wtext.strLen, &sz)                
                this._txtWidth = sz.cx + 10
                this._getWidth = false
            }
            if this._dbFill {
                this._memDC = CreateCompatibleDC(hdc)
                this._hbmp = CreateCompatibleBitmap(hdc, i32(this.width), i32(this.height))
                select_gdi_object(this._memDC, this._hbmp)
                api.FillRect(this._memDC, &this._rct, this._bkBrush)  
                this._dbFill = false
            }
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