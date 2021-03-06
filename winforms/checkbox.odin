package winforms

import "core:runtime"

WcCheckBoxW : wstring 

CheckBox :: struct {
    using control : Control,
    checked : bool,
    text_alignment : enum {Left, Right},
    check_changed : EventHandler,
    auto_size : bool,
    _bk_brush : Hbrush,
    _txt_style : Uint,

}

@private cb_count : int

@private cb_ctor :: proc(p : ^Form, txt : string = "") -> CheckBox {
    if WcCheckBoxW == nil do WcCheckBoxW = to_wstring("Button")	
    cb_count += 1
    cb : CheckBox
    cb.kind = .Check_Box
    cb.parent = p
    cb.font = p.font
    cb.text = concat_number("CheckBox_", cb_count) if txt == "" else txt
    cb.xpos = 50
    cb.ypos = 50
    cb.width = 30
    cb.height = 20
    cb.back_color = def_window_color
    cb.fore_color = 0x000000
    cb._ex_style = 0
    cb._style = WS_CHILD | WS_VISIBLE | BS_AUTOCHECKBOX 
    cb._ex_style =  WS_EX_LTRREADING | WS_EX_LEFT 
    cb._txt_style = DT_SINGLELINE | DT_VCENTER 
    cb.auto_size = true
    cb._size_incr.width = 20
    cb._size_incr.height = 3
    cb._cls_name = WcCheckBoxW
    cb._before_creation = cast(CreateDelegate) cb_before_creation
	cb._after_creation = cast(CreateDelegate) cb_after_creation
    return cb
}

@private cb_dtor :: proc(cb : ^CheckBox) {
    delete_gdi_object(cb._bk_brush)
}

// Constructor for Checkbox type.
new_checkbox :: proc{new_checkbox1, new_checkbox2}

@private new_checkbox1 :: proc(parent : ^Form, txt : string = "") -> CheckBox {
    cb := cb_ctor(parent, txt)
    return cb
}

@private new_checkbox2 :: proc(parent : ^Form, txt : string, x, y : int) -> CheckBox {
    cb := cb_ctor(parent, txt)    
    cb.xpos = x
    cb.ypos = y
    return cb
}

@private new_checkbox3 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> CheckBox {
    cb := cb_ctor(parent, txt)
    cb.width = w
    cb.height = h
    cb.xpos = x
    cb.ypos = y
    return cb
}

@private cb_before_creation :: proc(cb : ^CheckBox) {adjust_style(cb)}

@private cb_after_creation :: proc(cb : ^CheckBox) {	
	set_subclass(cb, cb_wnd_proc) 
    append(&cb.parent._cdraw_childs, cb.handle)
    if cb.auto_size do calculate_ctl_size(cb)

}

// Create handle of a checkbox control.
// create_checkbox :: proc(cb : ^CheckBox) {
//     _global_ctl_id += 1
//     cb.control_id = _global_ctl_id    
//     adjust_style(cb)
//     cb.handle = CreateWindowEx(   cb._ex_style, 
//                                     to_wstring("Button"),
//                                     to_wstring(cb.text),
//                                     cb._style, 
//                                     i32(cb.xpos), 
//                                     i32(cb.ypos), 
//                                     i32(cb.width), 
//                                     i32(cb.height),
//                                     cb.parent.handle, 
//                                     direct_cast(cb.control_id, Hmenu), 
//                                     app.h_instance, 
//                                     nil )
    
//     if cb.handle != nil {  
//         append(&cb.parent._cdraw_childs, cb.handle)      
//         cb._is_created = true        
//         setfont_internal(cb)
//         set_subclass(cb, cb_wnd_proc) 
//         if cb.auto_size do calculate_ctl_size(cb)
//         //ptf("global ctl id of label - %d\n", _global_ctl_id)       
//     }
// }

@private adjust_style :: proc(cb : ^CheckBox) {
    if cb.text_alignment == .Right {
        cb._style |= BS_RIGHTBUTTON
       cb._txt_style |= DT_RIGHT
    } 
}



@private cb_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
                                                        sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    cb := control_cast(CheckBox, ref_data)
    
    switch msg {
        case WM_PAINT :
            if cb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cb.paint(cb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case CM_CTLCOMMAND :
            cb.checked = cast(bool) SendMessage(hw, BM_GETCHECK, 0, 0)              
            if cb.check_changed != nil {
                ea := new_event_args()
                cb.check_changed(cb, &ea)
            }
        case CM_CTLLCOLOR :           
            hd := direct_cast(wp, Hdc)
            bkref := get_color_ref(cb.back_color)             
            SetBkMode(hd, transparent)
            if cb._bk_brush == nil do cb._bk_brush = CreateSolidBrush(bkref)
            return to_lresult(cb._bk_brush)

        case CM_NOTIFY :
            nmcd := direct_cast(lp, ^NMCUSTOMDRAW)	
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE :
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT :
                    cref := get_color_ref(cb.fore_color)                       
                    rct : Rect = nmcd.rc
                    if cb.text_alignment == .Left{
                        rct.left += 18 
                    } else do rct.right -= 18   
                    SetTextColor(nmcd.hdc, cref) 
                    DrawText(nmcd.hdc, to_wstring(cb.text), -1, &rct, cb._txt_style)    
                    
                    return CDRF_SKIPDEFAULT                
            }
        
        case WM_LBUTTONDOWN:                      
            cb._mdown_happened = true
            if cb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.left_mouse_down(cb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            cb._mrdown_happened = true
            if cb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.right_mouse_down(cb, &mea)
            }
        case WM_LBUTTONUP :                           
            if cb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.left_mouse_up(cb, &mea)
            }
            if cb._mdown_happened {
                cb._mdown_happened = false
                SendMessage(cb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if cb.mouse_click != nil {
                ea := new_event_args()
                cb.mouse_click(cb, &ea)
                return 0
            }        

        case WM_LBUTTONDBLCLK :
            cb._mdown_happened = false
            if cb.double_click != nil {
                ea := new_event_args()
                cb.double_click(cb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if cb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.right_mouse_up(cb, &mea)
            }
            if cb._mrdown_happened {
                cb._mrdown_happened = false
                SendMessage(cb.handle, CM_RMOUSECLICK, 0, 0)
            }
        
        case CM_RMOUSECLICK :
            cb._mrdown_happened = false
            if cb.right_click != nil {
                ea := new_event_args()
                cb.right_click(cb, &ea)
                return 0
            }        			

        case WM_MOUSEHWHEEL:
            if cb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cb.mouse_scroll(cb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if cb._is_mouse_entered {
                if cb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    cb.mouse_move(cb, &mea)                    
                }
            }
            else {
                cb._is_mouse_entered = true
                if cb.mouse_enter != nil  {
                    ea := new_event_args()
                    cb.mouse_enter(cb, &ea)                    
                }
            }
        //end case--------------------

        case WM_MOUSELEAVE :
            cb._is_mouse_entered = false
            if cb.mouse_leave != nil {               
                ea := new_event_args()
                cb.mouse_leave(cb, &ea)                
            }
        
        
        case WM_DESTROY :
            cb_dtor(cb)
            remove_subclass(cb)

        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}