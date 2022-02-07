/*
    Created on : 01-Feb-2022 08:38 AM
    Name : RadioButton type.
    IDE : VSCode
*/

package winforms
import "core:runtime"
//import "core:fmt"

rb_count : int
WcRadioBtnClassW := to_wstring("Button")
RadioButton :: struct {
    using control : Control,
    text_alignment : enum {left, right},
    checked : bool,
    check_on_click : bool,
    auto_size : bool,

    _hbrush : Hbrush,
    _txt_style : Uint,

    state_changed : EventHandler,
    

}

@private rb_ctor :: proc(f : ^Form, txt : string, x, y, w, h : int) -> RadioButton {
    rb : RadioButton
    rb.kind = .Radio_Button
    rb.parent = f
    rb.font = f.font
    rb.text = txt
    rb.xpos = x
    rb.ypos = y
    rb.width = w
    rb.height = h
    rb.check_on_click = true
    rb.auto_size = true
    rb.back_color = f.back_color
    rb.fore_color = def_fore_clr
    rb._style = WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON 
    rb._txt_style = DT_SINGLELINE | DT_VCENTER 
    rb._ex_style = 0
    rb._size_incr.width = 20
    rb._size_incr.height = 3
    return rb
} 

@private rb_dtor :: proc(rb : ^RadioButton) {
    delete_gdi_object(rb._hbrush)
}

new_radiobutton :: proc{new_rb1, new_rb2, new_rb3, new_rb4}

@private new_rb1 :: proc(parent : ^Form) -> RadioButton {
    rb_count += 1
    rtxt := concat_number("Radio_Button_", rb_count)
    rb := rb_ctor(parent, rtxt, 10, 10, 100, 25 )
    return rb
}

@private new_rb2 :: proc(parent : ^Form, txt : string) -> RadioButton {    
    rb := rb_ctor(parent, txt, 10, 10, 100, 25 )
    return rb    
}

@private new_rb3 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> RadioButton {     
    rb := rb_ctor(parent, txt, x, y, w, h )
    return rb
}

@private new_rb4 :: proc(parent : ^Form, txt : string, x, y : int) -> RadioButton {    
    rb := rb_ctor(parent, txt, x, y, 100, 25 )
    return rb    
}

@private rb_adjust_styles :: proc(rb : ^RadioButton) {
    if !rb.check_on_click do rb._style ~= BS_AUTORADIOBUTTON
    //if rb.text_alignment = .right do rb. 
}

radiobutton_set_state :: proc(rb : ^RadioButton, bstate: bool) {
    state := 0x0001 if bstate else 0x0000
    SendMessage(rb.handle, BM_SETCHECK, Wparam(state), 0)
}

// Change Radio Button's behaviour. Normally radio button will change it's checked state when it clicked.
// But you can change that behaviour by passing a false to this function.
radiobutton_set_autocheck :: proc(rb : ^RadioButton, auto_check : bool ) {
    ready_to_change : bool
    if auto_check {        
         if !rb.check_on_click {
            rb._style =  WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON          
            rb.check_on_click = true
            ready_to_change = true
        }
    } else {
       if rb.check_on_click {
            rb._style = WS_VISIBLE | WS_CHILD  | BS_RADIOBUTTON            
            rb.check_on_click = false
            ready_to_change = true
        }
    }
    if ready_to_change {
        SetWindowLongPtr(rb.handle, GWL_STYLE, LongPtr(rb._style))
        InvalidateRect(rb.handle, nil, true)
    }
}




// Create the handle of a progress bar
create_radiobutton :: proc(rb : ^RadioButton) {
    _global_ctl_id += 1
    rb.control_id = _global_ctl_id 
    rb_adjust_styles(rb)
    rb.handle = CreateWindowEx(   rb._ex_style, 
                                    WcRadioBtnClassW, 
                                    to_wstring(rb.text),
                                    rb._style, 
                                    i32(rb.xpos), 
                                    i32(rb.ypos), 
                                    i32(rb.width), 
                                    i32(rb.height),
                                    rb.parent.handle, 
                                    direct_cast(rb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if rb.handle != nil {
        rb._is_created = true
        set_subclass(rb, rb_wnd_proc) 
        setfont_internal(rb)
        if rb.auto_size do calculate_ctl_size(rb)
        if rb.checked {
            SendMessage(rb.handle, BM_SETCHECK, Wparam(0x0001), 0)
        }
        
 
    }
}

@private rb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {    
    
    context = runtime.default_context()   
    rb := control_cast(RadioButton, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY :
            rb_dtor(rb)
            remove_subclass(rb)

        case CM_CTLCOMMAND :
            if hiword_wparam(wp) == 0 {
                rb.checked = bool(SendMessage(rb.handle, BM_GETCHECK, 0, 0))
                if rb.state_changed != nil {
                    ea := new_event_args()
                    rb.state_changed(rb, &ea)                    
                }
            }
         case WM_LBUTTONDOWN:                      
            rb._mdown_happened = true
            if rb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.left_mouse_down(rb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            rb._mrdown_happened = true
            if rb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.right_mouse_down(rb, &mea)
            }
        case WM_LBUTTONUP :                           
            if rb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.left_mouse_up(rb, &mea)
            }
            if rb._mdown_happened do SendMessage(rb.handle, CM_LMOUSECLICK, 0, 0)

        case CM_LMOUSECLICK :
            if rb.mouse_click != nil {
                ea := new_event_args()
                rb.mouse_click(rb, &ea)
                return 0
            }        

        case WM_LBUTTONDBLCLK :
            rb._mdown_happened = false
            if rb.double_click != nil {
                ea := new_event_args()
                rb.double_click(rb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if rb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.right_mouse_up(rb, &mea)
            }
            if rb._mrdown_happened do SendMessage(rb.handle, CM_RMOUSECLICK, 0, 0)
        
        case CM_RMOUSECLICK :
            rb._mrdown_happened = false
            if rb.right_click != nil {
                ea := new_event_args()
                rb.right_click(rb, &ea)
                return 0
            }        			

        case WM_MOUSEHWHEEL:
            if rb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                rb.mouse_scroll(rb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if rb._is_mouse_entered {
                if rb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    rb.mouse_move(rb, &mea)                    
                }
            }
            else {
                rb._is_mouse_entered = true
                if rb.mouse_enter != nil  {
                    ea := new_event_args()
                    rb.mouse_enter(rb, &ea)                    
                }
            }
        //end case--------------------

        case WM_MOUSELEAVE :
            rb._is_mouse_entered = false
            if rb.mouse_leave != nil {               
                ea := new_event_args()
                rb.mouse_leave(rb, &ea)                
            }
        
        


        case CM_CTLLCOLOR :
            hdc := direct_cast(wp, Hdc)
            SetBkMode(hdc, Transparent)           
            //SetBackColor(hdc, get_color_ref(rb.back_color))            
            rb._hbrush = CreateSolidBrush(get_color_ref(rb.back_color))
            return to_lresult(rb._hbrush)

        case CM_NOTIFY :
            nmcd := direct_cast(lp, ^NMCUSTOMDRAW)	
            switch nmcd.dwDrawStage {
                case CDDS_PREERASE :
                    return CDRF_NOTIFYPOSTERASE
                case CDDS_PREPAINT :
                    cref := get_color_ref(rb.fore_color)                       
                    rct : Rect = nmcd.rc
                    if rb.text_alignment == .left{
                        rct.left += 18 
                    } else do rct.right -= 18   
                    SetTextColor(nmcd.hdc, cref) 
                    DrawText(nmcd.hdc, to_wstring(rb.text), -1, &rct, rb._txt_style)    
                    
                    return CDRF_SKIPDEFAULT                
            }

        

    }
    return DefSubclassProc(hw, msg, wp, lp)
}
