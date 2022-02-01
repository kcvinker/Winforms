/*
    Created on : 01-Feb-2022 08:38 AM
    Name : RadioButton type.
    IDE : VSCode
*/

package winforms
import "core:runtime"

rb_count : int
WcRadioBtnClassW := to_wstring("Button")
RadioButton :: struct {
    using control : Control,
    text_alignment : enum {left, right},

    _hbrush : Hbrush,
    _txt_style : Uint,

}

@private rb_ctor :: proc(f : ^Form, txt : string, x, y, w, h : int) -> RadioButton {
    rb : RadioButton
    rb.kind = .radio_button
    rb.parent = f
    rb.font = f.font
    rb.text = txt
    rb.xpos = x
    rb.ypos = y
    rb.width = w
    rb.height = h
    rb.back_color = f.back_color
    rb.fore_color = def_fore_clr
    rb._style = WS_VISIBLE | WS_CHILD | BS_AUTORADIOBUTTON 
    rb._txt_style = DT_SINGLELINE | DT_VCENTER 
    rb._ex_style = 0

    return rb
} 

@private rb_dtor :: proc(rb : ^RadioButton) {
    delete_gdi_object(rb._hbrush)
}

new_radiobutton :: proc{new_rb1, new_rb2, new_rb3}

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



// Create the handle of a progress bar
create_radiobutton :: proc(rb : ^RadioButton) {
    _global_ctl_id += 1
    rb.control_id = _global_ctl_id 
    //rb_adjust_styles(rb)
    rb.handle = create_window_ex(   rb._ex_style, 
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
        //rb_set_range_internal(rb)
        
 
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

        case CM_CTLLCOLOR :
            hdc := direct_cast(wp, Hdc)
            set_bk_mode(hdc, Transparent)           
            //set_bk_color(hdc, get_color_ref(rb.back_color))            
            rb._hbrush = create_solid_brush(get_color_ref(rb.back_color))
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
                    set_text_color(nmcd.hdc, cref) 
                    draw_text(nmcd.hdc, to_wstring(rb.text), -1, &rct, rb._txt_style)    
                    
                    return CDRF_SKIPDEFAULT                
            }

        

    }
    return def_subclass_proc(hw, msg, wp, lp)
}
