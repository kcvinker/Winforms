package winforms

import "core:runtime"



CheckBox :: struct {
    using control : Control,
    checked : bool,
    text_alignment : enum {left, right},
    check_changed : EventHandler,

    _bk_brush : Hbrush,
    _txt_style : Uint,

}

@private cb_count : int

@private cb_ctor :: proc(p : ^Form, txt : string = "") -> CheckBox {
    cb_count += 1
    cb : CheckBox
    cb.kind = .check_box
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

@private new_checkbox2 :: proc(parent : ^Form, txt : string, w, h : int, x : int = 50, y : int = 50) -> CheckBox {
    cb := cb_ctor(parent, txt)
    cb.width = w
    cb.height = h
    cb.xpos = x
    cb.ypos = y
    return cb
}

// Create handle of a checkbox control.
create_checkbox :: proc(cb : ^CheckBox) {
    _global_ctl_id += 1
    cb.control_id = _global_ctl_id    
    adjust_style(cb)
    cb.handle = create_window_ex(   cb._ex_style, 
                                    to_wstring("Button"),
                                    to_wstring(cb.text),
                                    cb._style, 
                                    i32(cb.xpos), 
                                    i32(cb.ypos), 
                                    i32(cb.width), 
                                    i32(cb.height),
                                    cb.parent.handle, 
                                    direct_cast(cb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if cb.handle != nil {  
        append(&cb.parent._cdraw_childs, cb.handle)      
        cb._is_created = true        
        setfont_internal(cb)
        set_subclass(cb, cb_wnd_proc) 
        //ptf("global ctl id of label - %d\n", _global_ctl_id)       
    }
}

@private adjust_style :: proc(cb : ^CheckBox) {
    if cb.text_alignment == .right {
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
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cb.paint(cb, &pea)
                end_paint(hw, &ps)
                return 0
            }

        case CM_CTLCOMMAND :
            cb.checked = cast(bool) send_message(hw, BM_GETCHECK, 0, 0)              
            if cb.check_changed != nil {
                ea := new_event_args()
                cb.check_changed(cb, &ea)
            }
        case CM_CTLLCOLOR :           
            hd := direct_cast(wp, Hdc)
            bkref := get_color_ref(cb.back_color)             
            set_bk_mode(hd, transparent)
            if cb._bk_brush == nil do cb._bk_brush = create_solid_brush(bkref)
            return to_lresult(cb._bk_brush)

        case CM_NOTIFY :
            nmcd := direct_cast(lp, ^NMCUSTOMDRAW)	
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE :
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT :
                    cref := get_color_ref(cb.fore_color)                       
                    rct : Rect = nmcd.rc
                    if cb.text_alignment == .left{
                        rct.left += 18 
                    } else do rct.right -= 18   
                    set_text_color(nmcd.hdc, cref) 
                    draw_text(nmcd.hdc, to_wstring(cb.text), -1, &rct, cb._txt_style)    
                    
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
            if cb._mdown_happened do send_message(cb.handle, CM_LMOUSECLICK, 0, 0)

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
            if cb._mrdown_happened do send_message(cb.handle, CM_RMOUSECLICK, 0, 0)
        
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

        case : return def_subclass_proc(hw, msg, wp, lp)
    }
    return def_subclass_proc(hw, msg, wp, lp)
}