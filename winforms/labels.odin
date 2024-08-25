package winforms
import "base:runtime"
//import "core:time"

WcLabelW : wstring = L("Static")

// this is for labels
@private _lb_count := 0
@private _lb_height_incr :: 3
@private _lb_width_incr :: 2


Label :: struct {
    using control : Control,
    autoSize : bool,
    borderStyle : LabelBorder,
    textAlignment : TextAlignment,
    multiLine : bool,
    _hbrush : HBRUSH,
    _txtAlign : DWORD,
}

// Border style for Label.
// Possible values : no_border, single_line, sunken_border
LabelBorder :: enum {No_Border, Single_Line, Sunken_Border, }

@private label_ctor :: proc(p : ^Form, txt : string, x, y: int, w: int = 0, h : int = 0) -> ^Label {
    // if WcLabelW == nil do WcLabelW = to_wstring("Static")
    _lb_count += 1
    this := new(Label)
    this.autoSize = true
    this._textable = true
    this.kind = .Label
    this.text = txt
    this.width = w // reset later
    this.height = h // reset later
    this.xpos = x
    this.ypos = y
    this.parent = p
    this.font = p.font
    this.backColor = p.backColor
    this.foreColor = app.clrBlack
    this._exStyle = 0 // WS_EX_LEFT | WS_EX_LTRREADING | WS_EX_RIGHTSCROLLBAR
    this._style = WS_VISIBLE | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | SS_NOTIFY   //SS_LEFT |  WS_OVERLAPPED
    this._SizeIncr.width = 2
    this._SizeIncr.height = 3
    this._clsName = WcLabelW
    this.autoSize = (w != 0 || h != 0) ? false : true
    this._fp_beforeCreation = cast(CreateDelegate) lbl_before_creation
    this._fp_afterCreation = cast(CreateDelegate) lbl_after_creation
    this._inherit_color = true
    append(&p._controls, this)
    return this
}


@private new_label1 :: proc(parent : ^Form) -> ^Label {
    txt := conc_num("Label_", _lb_count)
    lb := label_ctor(parent, txt, 10, 10)
    if parent.createChilds do create_control(lb)
    return lb
}

@private new_label2 :: proc(parent : ^Form, txt : string, x, y : int) -> ^Label {
    lb := label_ctor(parent, txt, x, y)
    if parent.createChilds do create_control(lb)
    return lb
}

@private new_label3 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> ^Label {
    lb := label_ctor(parent, txt, x, y, w, h)
    if parent.createChilds do create_control(lb)
    return lb
}



// Label control's constructor
new_label :: proc{new_label1, new_label2, new_label3}



@private check_for_autosize :: proc(lb : ^Label) {
    if lb.multiLine do lb.autoSize = false
    if lb.width != 0 do lb.autoSize = false // User might change width explicitly
    if lb.height != 0 do lb.autoSize = false // User might change width explicitly
    // if lb.width == 0 || lb.height == 0 {
    //     // User did not made any changes yet.
    // }
}

@private adjust_border :: proc(lb : ^Label) {
    if lb.borderStyle == .Sunken_Border {
        lb._style |= SS_SUNKEN
    } else if lb.borderStyle == .Single_Line {
        lb._style |= WS_BORDER
    }
}

@private adjust_alignment :: proc(lb : ^Label) {
    switch lb.textAlignment {
        case .Top_Left : lb._txtAlign = DT_TOP | DT_LEFT
        case .Top_Center : lb._txtAlign = DT_TOP | DT_CENTER
        case .Top_Right : lb._txtAlign = DT_TOP | DT_RIGHT

        case .Mid_Left : lb._txtAlign = DT_VCENTER | DT_LEFT
        case .Center : lb._txtAlign = DT_VCENTER | DT_CENTER
        case .Mid_Right : lb._txtAlign = DT_VCENTER | DT_RIGHT

        case .Bottom_Left : lb._txtAlign = DT_BOTTOM | DT_LEFT
        case .Bottom_Center : lb._txtAlign = DT_BOTTOM | DT_CENTER
        case .Bottom_Right : lb._txtAlign = DT_BOTTOM | DT_RIGHT
    }

    if lb.multiLine {
        lb._txtAlign |= DT_WORDBREAK
    } else {
       lb._txtAlign |= DT_SINGLELINE
    }
}

@private set_lbl_bk_clr :: proc(lb :^Label, clr : uint) {
    lb.backColor = clr
    if lb._isCreated {
        lb._hbrush = nil
        InvalidateRect(lb.handle, nil, false)
    }
}

@private
calculate_label_size :: proc(lb : ^Label) {
    // Labels are creating with zero width & height.
    // We need to find appropriate size if it is an auto sized label.
    hdc := GetDC(lb.handle)
    ctl_size : SIZE
    select_gdi_object(hdc, lb.font.handle)
    GetTextExtentPoint32(hdc, to_wstring(lb.text), i32(len(lb.text)), &ctl_size )
    ReleaseDC(lb.handle, hdc)
    lb.width = int(ctl_size.width) //+ lb._SizeIncr.width
    lb.height = int(ctl_size.height) //+ lb._SizeIncr.height
    SetWindowPos(lb.handle, nil, i32(lb.xpos), i32(lb.ypos), i32(lb.width), i32(lb.height), SWP_NOMOVE )
    // free_all(context.temp_allocator)
}

@private lbl_before_creation :: proc(lb : ^Label) {
    if lb.borderStyle != .No_Border do adjust_border(lb)
    check_for_autosize(lb)
    //adjust_alignment(lb)
}

@private lbl_after_creation :: proc(lb : ^Label) {
    if lb.autoSize do calculate_label_size(lb)
    set_subclass(lb, label_wnd_proc)
}


@private label_property_setter :: proc(this: ^Label, prop: LabelProps, value: $T)
{
	switch prop {
		case .Auto_Size: break
		case .Border_Style: break
		case .Text_Alignment: break
		case .Multi_Line: break
    }
}


@private lbl_finalize :: proc(lbl: ^Label, scid: UINT_PTR)
{
    delete_gdi_object(lbl._hbrush)
    RemoveWindowSubclass(lbl.handle, label_wnd_proc, scid)
    free(lbl)
}

@private label_wnd_proc :: proc "fast" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
                                                    sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT
{
    context = global_context
    lb := control_cast(Label, ref_data)

    switch msg {

        case WM_PAINT :
            if lb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                lb.paint(lb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
		    if lb.contextMenu != nil do contextmenu_show(lb.contextMenu, lp)

        case WM_LBUTTONDOWN:
           // print("label lbutton down")
            lb._mDownHappened = true
            if lb.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onMouseDown(lb, &mea)
                return 0
            }
        case WM_RBUTTONDOWN:
            lb._mDownHappened = true
            if lb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onRightMouseDown(lb, &mea)
            }
        case WM_LBUTTONUP :
           // print("label lbutton up")
            if lb.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onMouseUp(lb, &mea)
            }
            if lb._mDownHappened {
                lb._mDownHappened = false
                SendMessage(lb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            lb._mDownHappened = false
            if lb.onMouseClick != nil {
                ea := new_event_args()
                lb.onMouseClick(lb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            if lb.onDoubleClick != nil {
                ea := new_event_args()
                lb.onDoubleClick(lb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if lb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onRightMouseUp(lb, &mea)
            }
            if lb._mRDownHappened {
                lb._mDownHappened = false
                SendMessage(lb.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            lb._mRDownHappened = false
            if lb.onRightClick != nil {
                ea := new_event_args()
                lb.onRightClick(lb, &ea)
                return 0
            }
        case WM_MOUSEHWHEEL:
            if lb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onMouseScroll(lb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            //print("label mouse move")
            if !lb._isMouseTracking {
                lb._isMouseTracking = true
                track_mouse_move(hw)
                if !lb._isMouseEntered {
                    if lb.onMouseEnter != nil {
                        lb._isMouseEntered = true
                        ea := new_event_args()
                        lb.onMouseEnter(lb, &ea)
                    }
                }
            }
            //---------------------------------------
            if lb.onMouseMove != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onMouseMove(lb, &mea)
            }
        case WM_MOUSEHOVER :
            if lb._isMouseTracking do lb._isMouseTracking = false
            if lb.onMouseHover != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.onMouseHover(lb, &mea)
            }
        case WM_MOUSELEAVE :
            if lb._isMouseTracking
            {
                lb._isMouseTracking = false
                lb._isMouseEntered = false
            }
            if lb.onMouseLeave != nil
            {
                ea := new_event_args()
                lb.onMouseLeave(lb, &ea)
            }

        case CM_CTLLCOLOR :
            hdc := dir_cast(wp, HDC)
            SetTextColor(hdc, get_color_ref(lb.foreColor))
            SetBackColor(hdc, get_color_ref(lb.backColor))
            lb._hbrush = CreateSolidBrush(get_color_ref(lb.backColor))
            return toLRES(lb._hbrush)

        case WM_DESTROY: lbl_finalize(lb, sc_id)

        case : return DefSubclassProc(hw, msg, wp, lp)


    }
    return DefSubclassProc(hw, msg, wp, lp)
}


