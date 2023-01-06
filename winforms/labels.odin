package winforms
import "core:runtime"
//import "core:time"

WcLabelW : wstring

// this is for labels
@private _lb_count := 0
@private _lb_height_incr :: 3
@private _lb_width_incr :: 2


Label :: struct {
    using control : Control,
    auto_size : bool,
    border_style : LabelBorder,
    text_alignment : TextAlignment, 
    multi_line : bool,
    _hbrush : Hbrush,  
    _txt_align : Dword,
    
    
}

// Border style for Label.
// Possible values : no_border, single_line, sunken_border
LabelBorder :: enum {No_Border, Single_Line, Sunken_Border, }

@private label_ctor :: proc(p : ^Form, txt : string = "") -> Label {
    if WcLabelW == nil do WcLabelW = to_wstring("Static")
    _lb_count += 1
    lb : Label
    lb.auto_size = true
    lb.kind = .Label
    lb.text = txt == "" ? concat_number("Label_", _lb_count) : txt
    lb.width = 0 // reset later
    lb.height = 0 // reset later
    lb.xpos = 50
    lb.ypos = 50
    lb.parent = p
    lb.font = p.font
    lb.back_color = def_window_color
    lb.fore_color = 0x000000
    lb._ex_style = 0 // WS_EX_LEFT | WS_EX_LTRREADING | WS_EX_RIGHTSCROLLBAR
    lb._style = WS_VISIBLE | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | SS_NOTIFY   //SS_LEFT |  WS_OVERLAPPED
    lb._size_incr.width = 2
    lb._size_incr.height = 3 
    lb._cls_name = WcLabelW
    lb._before_creation = cast(CreateDelegate) lbl_before_creation
    lb._after_creation = cast(CreateDelegate) lbl_after_creation
    return lb
}

@private label_dtor :: proc(lb : ^Label) {
    delete_gdi_object(lb._hbrush)
}

@private new_label1 :: proc(parent : ^Form) -> Label {
    lb := label_ctor(parent)
    return lb
}

@private new_label2 :: proc(parent : ^Form, txt : string, w : int = 0, h : int = 0) -> Label {
    lb := label_ctor(parent, txt)
    if w != 0 || h != 0 do lb.auto_size = false
    lb.width = w
    lb.height = h
    return lb
}

@private new_label3 :: proc(parent : ^Form, x, y : int, txt : string) -> Label {
    lb := label_ctor(parent, txt)    
    lb.xpos = x
    lb.ypos = y
    return lb
}

// Label control's constructor
new_label :: proc{new_label1, new_label2, new_label3}



@private check_for_autosize :: proc(lb : ^Label) {
    if lb.multi_line do lb.auto_size = false
    if lb.width != 0 do lb.auto_size = false // User might change width explicitly
    if lb.height != 0 do lb.auto_size = false // User might change width explicitly
    // if lb.width == 0 || lb.height == 0 {
    //     // User did not made any changes yet. 
    // }
}

@private adjust_border :: proc(lb : ^Label) {   
    if lb.border_style == .Sunken_Border {
        lb._style |= SS_SUNKEN
    } else if lb.border_style == .Single_Line {
        lb._style |= WS_BORDER           
    }
}

@private adjust_alignment :: proc(lb : ^Label) {
    switch lb.text_alignment {
        case .Top_Left : lb._txt_align = DT_TOP | DT_LEFT 
        case .Top_Center : lb._txt_align = DT_TOP | DT_CENTER 
        case .Top_Right : lb._txt_align = DT_TOP | DT_RIGHT 

        case .Mid_Left : lb._txt_align = DT_VCENTER | DT_LEFT 
        case .Center : lb._txt_align = DT_VCENTER | DT_CENTER  
        case .Mid_Right : lb._txt_align = DT_VCENTER | DT_RIGHT 

        case .Bottom_Left : lb._txt_align = DT_BOTTOM | DT_LEFT 
        case .Bottom_Center : lb._txt_align = DT_BOTTOM | DT_CENTER 
        case .Bottom_Right : lb._txt_align = DT_BOTTOM | DT_RIGHT            
    }

    if lb.multi_line {
        lb._txt_align |= DT_WORDBREAK    
    } else {
       lb._txt_align |= DT_SINGLELINE
    }
}

@private set_lbl_bk_clr :: proc(lb :^Label, clr : uint) {
    lb.back_color = clr
    if lb._is_created {
        lb._hbrush = nil
        InvalidateRect(lb.handle, nil, true)
    }
}

@private 
calculate_label_size :: proc(lb : ^Label) { 
    // Labels are creating with zero width & height. 
    // We need to find appropriate size if it is an auto sized label.
    hdc := GetDC(lb.handle)
    defer DeleteDC(hdc)
    ctl_size : Size            
    select_gdi_object(hdc, lb.font.handle)
    GetTextExtentPoint32(hdc, to_wstring(lb.text), i32(len(lb.text)), &ctl_size )
    lb.width = int(ctl_size.width) //+ lb._size_incr.width
    lb.height = int(ctl_size.height) //+ lb._size_incr.height       
    MoveWindow(lb.handle, i32(lb.xpos), i32(lb.ypos), i32(lb.width), i32(lb.height), true )
}

@private lbl_before_creation :: proc(lb : ^Label) {
    if lb.border_style != .No_Border do adjust_border(lb)
    check_for_autosize(lb)
    //adjust_alignment(lb)
}

@private lbl_after_creation :: proc(lb : ^Label) {
    if lb.auto_size do calculate_label_size(lb) 
    set_subclass(lb, label_wnd_proc) 
}





@private label_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
                                                    sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
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
            
        case WM_LBUTTONDOWN:    
           // print("label lbutton down")        
            lb._mdown_happened = true
            if lb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.left_mouse_down(lb, &mea)
                return 0
            }
        case WM_RBUTTONDOWN:
            lb._mdown_happened = true
            if lb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.right_mouse_down(lb, &mea)
            }
        case WM_LBUTTONUP :
           // print("label lbutton up")                             
            if lb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.left_mouse_up(lb, &mea)
            }
            if lb._mdown_happened {
                lb._mdown_happened = false
                SendMessage(lb.handle, CM_LMOUSECLICK, 0, 0)
            } 

        case CM_LMOUSECLICK :
            lb._mdown_happened = false
            if lb.mouse_click != nil {
                ea := new_event_args()
                lb.mouse_click(lb, &ea)
                return 0
            }
            
        case WM_LBUTTONDBLCLK :
            if lb.double_click != nil {
                ea := new_event_args()
                lb.double_click(lb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if lb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.right_mouse_up(lb, &mea)
            }
            if lb._mrdown_happened {
                lb._mdown_happened = false
                SendMessage(lb.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            lb._mrdown_happened = false
            if lb.right_click != nil {
                ea := new_event_args()
                lb.right_click(lb, &ea)
                return 0
            }
        case WM_MOUSEHWHEEL:
            if lb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.mouse_scroll(lb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            //print("label mouse move")
            if !lb._is_mouse_tracking {
                lb._is_mouse_tracking = true
                track_mouse_move(hw)
                if !lb._is_mouse_entered {
                    if lb.mouse_enter != nil {
                        lb._is_mouse_entered = true
                        ea := new_event_args()
                        lb.mouse_enter(lb, &ea)
                    }
                }
            }
            //---------------------------------------
            if lb.mouse_move != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.mouse_move(lb, &mea)
            }
        case WM_MOUSEHOVER :
            if lb._is_mouse_tracking do lb._is_mouse_tracking = false
            if lb.mouse_hover != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lb.mouse_hover(lb, &mea)
            }
        case WM_MOUSELEAVE :
           
            if lb._is_mouse_tracking {
                lb._is_mouse_tracking = false
                lb._is_mouse_entered = false
            }
            if lb.mouse_leave != nil {
                ea := new_event_args()
                lb.mouse_leave(lb, &ea)
            }           
       

        case CM_CTLLCOLOR :
            hdc := direct_cast(wp, Hdc)
            SetTextColor(hdc, get_color_ref(lb.fore_color))
            SetBackColor(hdc, get_color_ref(lb.back_color))
            lb._hbrush = CreateSolidBrush(get_color_ref(lb.back_color))
            return to_lresult(lb._hbrush)
            
        case WM_DESTROY:
            label_dtor(lb)
            remove_subclass(lb)
   
        case : return DefSubclassProc(hw, msg, wp, lp)
        

    }
    return DefSubclassProc(hw, msg, wp, lp)
}


