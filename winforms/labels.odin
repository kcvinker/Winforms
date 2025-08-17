
/*===========================Label Docs==============================
    Label struct
        Constructor: new_label() -> ^Label
        Properties:
            All props from Control struct
            autoSize       : bool
            borderStyle    : LabelBorder
            textAlignment  : TextAlignment
            multiLine      : bool
        Functions:
        Events:
            All events from Control struct
        
===============================================================================*/

package winforms
import "base:runtime"
//import "core:time"

WcLabelW: []WCHAR = {'S', 't', 'a', 't', 'i', 'c', 0}

// this is for labels
@private _lb_count:= 0
@private _lb_height_incr:: 3
@private _lb_width_incr:: 2
@private _padding :: 4


Label:: struct {
    using control: Control,
    autoSize: bool,
    borderStyle: LabelBorder,
    textAlignment: TextAlignment,
    multiLine: bool, 
    _hbrush: HBRUSH,
    _txtAlign: DWORD,
}

// Label control's constructor
new_label:: proc{new_label1, new_label2, new_label3}





//==================================Private Functions==================================
@private label_ctor:: proc(p: ^Form, txt: string, x, y: int, w: int = 0, h: int = 0) -> ^Label 
{
    _lb_count += 1
    this:= new(Label)
    this.autoSize = true
    this._textable = true
    this.kind = .Label
    this.text = txt
    this.width = w // reset later
    this.height = h // reset later
    this.xpos = x
    this.ypos = y
    this.parent = p
    this._wtext = new_widestring(txt)
    this.backColor = p.backColor
    this.foreColor = app.clrBlack
    this._exStyle = 0 // WS_EX_LEFT | WS_EX_LTRREADING | WS_EX_RIGHTSCROLLBAR
    this._style = WS_VISIBLE | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | SS_NOTIFY   
    this._SizeIncr.width = 2
    this._SizeIncr.height = 3
    this._clsName = &WcLabelW[0]
    this.autoSize = (w != 0 || h != 0) ? false: true
    this._fp_beforeCreation = cast(CreateDelegate) lbl_before_creation
    this._fp_afterCreation = cast(CreateDelegate) lbl_after_creation
    this._inherit_color = true
    font_clone(&p.font, &this.font )
    append(&p._controls, this)
    // ptf("lb az %s", this.autoSize)
    return this
}

@private new_label1:: proc(parent: ^Form) -> ^Label 
{
    txt:= conc_num("Label_", _lb_count)
    lb:= label_ctor(parent, txt, 10, 10)
    if parent.createChilds do create_control(lb)
    return lb
}

@private new_label2:: proc(parent: ^Form, txt: string, x, y: int) -> ^Label 
{
    lb:= label_ctor(parent, txt, x, y)
    if parent.createChilds do create_control(lb)
    return lb
}

@private new_label3:: proc(parent: ^Form, txt: string, x, y, w, h: int) -> ^Label 
{
    lb:= label_ctor(parent, txt, x, y, w, h)
    if parent.createChilds do create_control(lb)
    return lb
}

@private check_for_autosize:: proc(lb: ^Label) 
{
    if lb.multiLine do lb.autoSize = false
    if lb.width != 0 do lb.autoSize = false // User might change width explicitly
    if lb.height != 0 do lb.autoSize = false // User might change width explicitly
    // if lb.width == 0 || lb.height == 0 {
    //     // User did not made any changes yet.
    // }
}

@private adjust_border:: proc(lb: ^Label) 
{
    if lb.borderStyle == .Sunken_Border {
        lb._style |= SS_SUNKEN
    } else if lb.borderStyle == .Single_Line {
        lb._style |= WS_BORDER
    }
}

@private adjust_alignment:: proc(lb: ^Label) 
{
    switch lb.textAlignment {
        case .Top_Left: lb._txtAlign = DT_TOP | DT_LEFT
        case .Top_Center: lb._txtAlign = DT_TOP | DT_CENTER
        case .Top_Right: lb._txtAlign = DT_TOP | DT_RIGHT

        case .Mid_Left: lb._txtAlign = DT_VCENTER | DT_LEFT
        case .Center: lb._txtAlign = DT_VCENTER | DT_CENTER
        case .Mid_Right: lb._txtAlign = DT_VCENTER | DT_RIGHT

        case .Bottom_Left: lb._txtAlign = DT_BOTTOM | DT_LEFT
        case .Bottom_Center: lb._txtAlign = DT_BOTTOM | DT_CENTER
        case .Bottom_Right: lb._txtAlign = DT_BOTTOM | DT_RIGHT
    }

    if lb.multiLine {
        lb._txtAlign |= DT_WORDBREAK
    } else {
       lb._txtAlign |= DT_SINGLELINE
    }
}

@private set_lbl_bk_clr:: proc(lb:^Label, clr: uint) 
{
    lb.backColor = clr
    if lb._isCreated {
        lb._hbrush = nil
        InvalidateRect(lb.handle, nil, false)
    }
}

@private calculate_label_size:: proc(this: ^Label) 
{
    // Labels are creating with zero width & height.
    // We need to find appropriate size if it is an auto sized label.
    hdc:= GetDC(this.handle)
    defer ReleaseDC(this.handle, hdc)
    ss: SIZE
    select_gdi_object(hdc, this.font.handle)
    GetTextExtentPoint32(hdc, this._wtext.ptr, this._wtext.strLen, &ss )    
    this.width = int(ss.cx + _padding)
    this.height = int(ss.cy + _padding)
    lflag :UINT =  SWP_NOZORDER | SWP_NOACTIVATE // SWP_NOMOVE |
    control_setpos2(this.handle, this.xpos, this.ypos, this.width, this.height, SWP_NOMOVE)
    check_redraw(this, false)
}

@private lbl_before_creation:: proc(this: ^Label) 
{
    if this.borderStyle != .No_Border do adjust_border(this)
    this._hbrush = CreateSolidBrush(get_color_ref(this.backColor))
    check_for_autosize(this)
    //adjust_alignment(this)
}

@private lbl_after_creation:: proc(this: ^Label) 
{    
    set_subclass(this, label_wnd_proc)
    ctl_send_msg(this.handle, WM_SETFONT, this.font.handle, 1)
    if this.autoSize do calculate_label_size(this)
    // ptf("this hwnd %d, %d, %d, %d", this.handle, this.width, this.height, this.autoSize)
}

@private label_property_setter:: proc(this: ^Label, prop: LabelProps, value: $T)
{
	switch prop {
		case .Auto_Size: break
		case .Border_Style: break
		case .Text_Alignment: break
		case .Multi_Line: break
    }
}

@private lbl_finalize:: proc(this: ^Label, scid: UINT_PTR)
{
    delete_gdi_object(this._hbrush)    
    RemoveWindowSubclass(this.handle, label_wnd_proc, scid)
    widestring_destroy(this._wtext)
    font_destroy(&this.font)
    free(this)
}

@private label_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                                    sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context
    switch msg {
        case WM_PAINT:
            this:= control_cast(Label, ref_data)
            if this.onPaint != nil {
                ps: PAINTSTRUCT
                hdc:= BeginPaint(hw, &ps)
                pea:= new_paint_event_args(&ps)
                this.onPaint(this, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
            lb:= control_cast(Label, ref_data)
		    if lb.contextMenu != nil do contextmenu_show(lb.contextMenu, lp)

        case WM_LBUTTONDOWN:
            lb:= control_cast(Label, ref_data)
            
            if lb.onMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onMouseDown(lb, &mea)
                return 0
            }
        case WM_RBUTTONDOWN:
            lb:= control_cast(Label, ref_data)
            if lb.onRightMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onRightMouseDown(lb, &mea)
            }
        case WM_LBUTTONUP:
            lb:= control_cast(Label, ref_data)
           // print("label lbutton up")
            if lb.onMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onMouseUp(lb, &mea)
            }            
            if lb.onClick != nil {
                ea:= new_event_args()
                lb.onClick(lb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK:
            lb:= control_cast(Label, ref_data)
            if lb.onDoubleClick != nil {
                ea:= new_event_args()
                lb.onDoubleClick(lb, &ea)
                return 0
            }

        case WM_RBUTTONUP:
            lb:= control_cast(Label, ref_data)
            if lb.onRightMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onRightMouseUp(lb, &mea)
            }            
            if lb.onRightClick != nil {
                ea:= new_event_args()
                lb.onRightClick(lb, &ea)
                return 0
            }
        case WM_MOUSEHWHEEL:
            lb:= control_cast(Label, ref_data)
            if lb.onMouseScroll != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onMouseScroll(lb, &mea)
            }
        case WM_MOUSEMOVE: // Mouse Enter & Mouse Move is happening here.
            lb:= control_cast(Label, ref_data)
            //print("label mouse move")
            if !lb._isMouseTracking {
                lb._isMouseTracking = true
                track_mouse_move(hw)
                if !lb._isMouseEntered {
                    if lb.onMouseEnter != nil {
                        lb._isMouseEntered = true
                        ea:= new_event_args()
                        lb.onMouseEnter(lb, &ea)
                    }
                }
            }
            //---------------------------------------
            if lb.onMouseMove != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onMouseMove(lb, &mea)
            }
        case WM_MOUSEHOVER:
            lb:= control_cast(Label, ref_data)
            if lb._isMouseTracking do lb._isMouseTracking = false
            if lb.onMouseHover != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                lb.onMouseHover(lb, &mea)
            }
        case WM_MOUSELEAVE:
            lb:= control_cast(Label, ref_data)
            if lb._isMouseTracking
            {
                lb._isMouseTracking = false
                lb._isMouseEntered = false
            }
            if lb.onMouseLeave != nil
            {
                ea:= new_event_args()
                lb.onMouseLeave(lb, &ea)
            }

        case CM_STATIC_COLOR:
            this:= control_cast(Label, ref_data)
            hdc:= dir_cast(wp, HDC)
            if (this._drawFlag & 1) != 1 do SetTextColor(hdc, get_color_ref(this.foreColor))
            SetBkColor(hdc, get_color_ref(this.backColor))
            return toLRES(this._hbrush)

        case WM_DESTROY: 
            lb:= control_cast(Label, ref_data)
            lbl_finalize(lb, sc_id)

        case: return DefSubclassProc(hw, msg, wp, lp)

    }
    return DefSubclassProc(hw, msg, wp, lp)
}


