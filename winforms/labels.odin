package winforms
import "core:runtime"
//import "core:time"

// this is for labels
@private _lb_count := 0
@private _lb_height_incr :: 3
@private _lb_width_incr :: 2


Label :: struct {
    using control : Control,
    auto_size : b64,
    border_style : LabelBorder,
    text_alignment : TextAlignment, 
    multi_line : b32,
    _hbrush : Hbrush,  
    _txt_align : Dword,
    
    
}

// Border style for Label.
// Possible values : no_border, single_line, sunken_border
LabelBorder :: enum {no_border, single_line, sunken_border, }

@private label_ctor :: proc(p : ^Form, txt : string = "") -> Label {
    _lb_count += 1
    lb : Label
    lb.auto_size = true
    lb.kind = .label
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

// Label control's constructor
new_label :: proc{new_label1, new_label2}



@private check_for_autosize :: proc(lb : ^Label) {
    if lb.multi_line do lb.auto_size = false
    if lb.width != 0 do lb.auto_size = false // User might change width explicitly
    if lb.height != 0 do lb.auto_size = false // User might change width explicitly
    // if lb.width == 0 || lb.height == 0 {
    //     // User did not made any changes yet. 
    // }
}

@private adjust_border :: proc(lb : ^Label) {   
    if lb.border_style == .sunken_border {
        lb._style |= SS_SUNKEN
    } else if lb.border_style == .single_line {
        lb._style |= WS_BORDER           
    }
}

@private adjust_alignment :: proc(lb : ^Label) {
    if lb.multi_line {
        switch lb.text_alignment {
            case .top_left : lb._txt_align = DT_TOP | DT_LEFT | DT_WORDBREAK
            case .top_center : lb._txt_align = DT_TOP | DT_CENTER | DT_WORDBREAK
            case .top_right : lb._txt_align = DT_TOP | DT_RIGHT | DT_WORDBREAK

            case .mid_left : lb._txt_align = DT_VCENTER | DT_LEFT | DT_WORDBREAK
            case .center : lb._txt_align = DT_VCENTER | DT_CENTER | DT_WORDBREAK 
            case .mid_right : lb._txt_align = DT_VCENTER | DT_RIGHT | DT_WORDBREAK

            case .bottom_left : lb._txt_align = DT_BOTTOM | DT_LEFT | DT_WORDBREAK
            case .bottom_center : lb._txt_align = DT_BOTTOM | DT_CENTER | DT_WORDBREAK
            case .bottom_right : lb._txt_align = DT_BOTTOM | DT_RIGHT   | DT_WORDBREAK         
        }
    
    } else {
        switch lb.text_alignment {
            case .top_left : lb._txt_align = DT_TOP | DT_LEFT  | DT_SINGLELINE 
            case .top_center : lb._txt_align = DT_TOP | DT_CENTER | DT_SINGLELINE
            case .top_right : lb._txt_align = DT_TOP | DT_RIGHT | DT_SINGLELINE

            case .mid_left : lb._txt_align = DT_VCENTER | DT_LEFT  | DT_SINGLELINE
            case .center : lb._txt_align =  DT_VCENTER | DT_CENTER | DT_SINGLELINE
            case .mid_right : lb._txt_align = DT_VCENTER | DT_RIGHT | DT_SINGLELINE

            case .bottom_left : lb._txt_align = DT_BOTTOM | DT_LEFT | DT_SINGLELINE
            case .bottom_center : lb._txt_align = DT_BOTTOM | DT_CENTER | DT_SINGLELINE
            case .bottom_right : lb._txt_align = DT_BOTTOM | DT_RIGHT | DT_SINGLELINE 
        }

    }

   

}

@private set_lbl_bk_clr :: proc(lb :^Label, clr : uint) {
    lb.back_color = clr
    if lb._is_created {
        lb._hbrush = nil
        invalidate_rect(lb.handle, nil, true)
    }
}

@private set_label_size :: proc(lb : ^Label) {
    hdc := get_dc(lb.handle)
    defer delete_dc(hdc)
    lsize : Size            
    select_gdi_object(hdc, lb.font.handle)
    get_text_extent_point(hdc, to_wstring(lb.text), i32(len(lb.text)), &lsize )
    lb.width = int(lsize.width) + _lb_width_incr
    lb.height = int(lsize.height) + _lb_height_incr       
    move_window(lb.handle, i32(lb.xpos), i32(lb.ypos), i32(lb.width), i32(lb.height), true )
}

// Create the handle of Label control.
create_label :: proc(lb : ^Label) {
    if lb.border_style != .no_border do adjust_border(lb)
    check_for_autosize(lb)
    adjust_alignment(lb)
    _global_ctl_id += 1  
    lb.control_id = _global_ctl_id  
    lb.handle = create_window_ex(   lb._ex_style, 
                                    to_wstring("Static"), 
                                    to_wstring(lb.text),
                                    lb._style, 
                                    i32(lb.xpos), 
                                    i32(lb.ypos), 
                                    i32(lb.width), 
                                    i32(lb.height),
                                    lb.parent.handle, 
                                    direct_cast(lb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if lb.handle != nil {  
        //print("Original label - ", lb.handle)
        lb._is_created = true              
        if lb.auto_size do set_label_size(lb)
        setfont_internal(lb)
        set_subclass(lb, label_wnd_proc) 
        
              
    }

}



@private label_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
                                                    sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    lb := control_cast(Label, ref_data)

    switch msg {   
        
        case WM_PAINT :
            if lb.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                lb.paint(lb, &pea)
                end_paint(hw, &ps)
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
            if lb._mdown_happened do send_message(lb.handle, CM_LMOUSECLICK, 0, 0) 

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
            if lb._mrdown_happened do send_message(lb.handle, CM_RMOUSECLICK, 0, 0)

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
            set_text_color(hdc, get_color_ref(lb.fore_color))
            set_bk_color(hdc, get_color_ref(lb.back_color))
            lb._hbrush = create_solid_brush(get_color_ref(lb.back_color))
            return to_lresult(lb._hbrush)
            
        case WM_DESTROY:
            label_dtor(lb)
            remove_subclass(lb)
   
        case : return def_subclass_proc(hw, msg, wp, lp)
        

    }
    return def_subclass_proc(hw, msg, wp, lp)
}


