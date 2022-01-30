
package winforms

import "core:fmt"
import "core:runtime"
//import "core:reflect"

DropDownStyle :: enum {tb_combo, lb_combo,}

ComboBox :: struct {
    using control : Control,
    combo_style : DropDownStyle,
    items : [dynamic]string, // Don't forget to delete it when combo box deing destroyed.
    visible_item_count : int,
    selected_index : int,
    p_recreate_enabled : bool, // Used when we need to recreate existing combo

    _bk_brush : Hbrush,
    _old_hwnd : Hwnd,

    selection_changed,
    selection_committed,
    selection_cancelled,
    text_changed,
    text_updated,
    list_opened,
    list_closed,
    tb_click,
    tb_mouse_leave,
    tb_mouse_enter : EventHandler,
    



}

ComboInfo :: struct {
    lb_handle : Hwnd,
    tb_handle : Hwnd,
    combo_handle : Hwnd,
    no_tb_msg : b64,
}

@private get_combo_info :: proc(cmb : ^ComboBox)  {
    cmInfo : COMBOBOXINFO
    cmInfo.cbSize = size_of(cmInfo)    
    send_message(cmb.handle, CB_GETCOMBOBOXINFO, 0, direct_cast(&cmInfo, Lparam))
    bval : b64 = true if cmb.combo_style == .lb_combo else false
    ci := ComboInfo{cmInfo.hwndList, cmInfo.hwndItem, cmb.handle, bval}
    append(&cmb.parent._combo_list, ci)
    // print("combo edit hwnd - ", ci.tb_handle)
    // print("combo list hwnd - ", ci.lb_handle)
    // print("combo main hwnd - ", ci.combo_handle)
}

@private update_combo_info :: proc(cmb : ^ComboBox) {
    cbi : COMBOBOXINFO
    cbi.cbSize = size_of(cbi)    
    send_message(cmb.handle, CB_GETCOMBOBOXINFO, 0, direct_cast(&cbi, Lparam))
    for ci in &cmb.parent._combo_list {
        if ci.combo_handle == cmb._old_hwnd {
            ci.lb_handle = cbi.hwndList
            ci.tb_handle = cbi.hwndItem
            ci.combo_handle = cmb.handle
            cmb._old_hwnd = cmb.handle
            break
        }
    }
}


@private cmb_ctor :: proc(p : ^Form, w : int = 130, h : int = 30) -> ComboBox {
    cmb : ComboBox
    cmb.kind = .combo_box
    cmb.parent = p
    cmb.font = p.font    
    cmb.xpos = 50
    cmb.ypos = 50
    cmb.width = w
    cmb.height = h
    cmb.back_color = def_back_clr
    cmb.fore_color = def_fore_clr    
    cmb._ex_style = 0
    cmb.selected_index = -1
    cmb._style = WS_CHILD | WS_VISIBLE | CBS_DROPDOWN 
    cmb._ex_style =  WS_EX_LTRREADING | WS_EX_LEFT 
    //cmb._txt_style = DT_SINGLELINE | DT_VCENTER 
    return cmb
}

new_combobox :: proc{new_combo1, new_combo2}

@private new_combo1 :: proc(parent : ^Form) -> ComboBox {
    cmb := cmb_ctor(parent)

    return cmb
}
@private new_combo2 :: proc(parent : ^Form, w, h : int ) -> ComboBox {
    cmb := cmb_ctor(parent, w, h)

    return cmb
}

@private cmb_dtor :: proc(cmb : ^ComboBox) {    
    if !cmb.p_recreate_enabled {
        delete_gdi_object(cmb.font.handle)
        delete_gdi_object(cmb._bk_brush)
        delete(cmb.items)
    }     
}



combo_set_style :: proc(cmb : ^ComboBox, style : DropDownStyle) {
    // Since, there is no way to change the combo style at runtime,...
    // We are going to delete the current combo and create new one.
    // Then we set up the old font and old selection. 
    if cmb._is_created {
        if style == .tb_combo {
            if cmb.combo_style != .lb_combo do return
            cmb._style = WS_CHILD | WS_VISIBLE | CBS_DROPDOWN
        } else {
            if cmb.combo_style != .tb_combo do return
            cmb._style = WS_CHILD | WS_VISIBLE | CBS_DROPDOWNLIST
        }        
        cmb.combo_style = style   
        cmb.p_recreate_enabled = true  
        sel_indx := combo_get_selected_index(cmb)   
        destroy_window(cmb.handle)
        recreate_combo(cmb)
        if sel_indx != -1 do combo_set_selected_index(cmb, sel_indx)        
    } 
}

@private recreate_combo :: proc(cmb : ^ComboBox) {
    cmb.handle = create_window_ex(  cmb._ex_style, 
                                    to_wstring("ComboBox"), 
                                    to_wstring(cmb.text),
                                    cmb._style, 
                                    i32(cmb.xpos), 
                                    i32(cmb.ypos), 
                                    i32(cmb.width), 
                                    i32(cmb.height),
                                    cmb.parent.handle, 
                                    direct_cast(cmb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    if cmb.handle != nil {
        cmb._is_created = true        
        send_message(cmb.handle, WM_SETFONT, Wparam(cmb.font.handle), Lparam(1))
        set_subclass(cmb, cmb_wnd_proc) 
        additem_internal(cmb)
        update_combo_info(cmb)
        cmb.p_recreate_enabled = false // Once re-created, we need to turn it off.
    }
}

combo_add_item :: proc(cmb : ^ComboBox, item : $T ) {
    sitem : string
    when T == string {
        sitem = item       
    } else {
        sitem := fmt.tprint(an_item)        
    }    
    append(&cmb.items, sitem) 
    if cmb._is_created {
        send_message(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(sitem), Lparam))
    }
}

combo_open_list :: proc(cmb : ^ComboBox) { send_message(cmb.handle, CB_SHOWDROPDOWN, Wparam(1), 0) }
combo_close_list :: proc(cmb : ^ComboBox) { send_message(cmb.handle, CB_SHOWDROPDOWN, Wparam(0), 0) }


@private add_items2 :: proc(cmb : ^ComboBox, items : ..any ) {    
    for i in items { 
        if value, is_str := i.(string) ; is_str { // Magic -- type assert
            append(&cmb.items, value)
            if cmb._is_created {
                send_message(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(value), Lparam))
            }
        } else {
            a_string := fmt.tprint(i)
            append(&cmb.items, a_string)
            if cmb._is_created {
                send_message(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(a_string), Lparam))
            }
        }
    }          
}

combo_add_items :: proc{add_items2}

combo_add_array :: proc(cmb : ^ComboBox, items : []$T ) {  
    //print("called once")  
    when T == string {
        for i in items { 
            append(&cmb.items, i) 
        }
    } else {
        for i in items { 
            a_string := fmt.tprint(i)
            append(&cmb.items, a_string)  
        }  
    }         
}

@private additem_internal :: proc(cmb : ^ComboBox) {
    for i in cmb.items {
        send_message(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(i), Lparam))
    }
}

combo_get_selected_index :: proc(cmb : ^ComboBox) -> int {
    cmb.selected_index = int(send_message(cmb.handle, CB_GETCURSEL, 0, 0))
    return cmb.selected_index
}

combo_set_selected_index :: proc(cmb : ^ComboBox, indx : int)  {
    send_message(cmb.handle, CB_SETCURSEL, Wparam(i32(indx)), 0)
    cmb.selected_index = indx
}


combo_get_selected_item :: proc(cmb : ^ComboBox) -> any {
    indx := int(send_message(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        return cmb.items[indx]
    } else do return ""    
}

combo_delete_selected_item :: proc(cmb : ^ComboBox) {
    indx := i32(send_message(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        send_message(cmb.handle, CB_DELETESTRING, Wparam(indx), 0)
        ordered_remove(&cmb.items, int(indx))
    } 
}

combo_delete_item :: proc(cmb : ^ComboBox, indx : int) {
    send_message(cmb.handle, CB_DELETESTRING, direct_cast(i32(indx), Wparam), 0)
    ordered_remove(&cmb.items, indx)    
}

combo_clear_items :: proc(cmb : ^ComboBox) {
    send_message(cmb.handle, CB_DELETESTRING, 0, 0)
    // TODO - clear dynamic array of combo.
}

create_combo :: proc(cmb : ^ComboBox) {
    _global_ctl_id += 1
    cmb.control_id = _global_ctl_id      
    if cmb.combo_style == .lb_combo do cmb._style |= CBS_DROPDOWNLIST
    cmb.handle = create_window_ex(  cmb._ex_style, 
                                    to_wstring("ComboBox"), 
                                    to_wstring(cmb.text),
                                    cmb._style, 
                                    i32(cmb.xpos), 
                                    i32(cmb.ypos), 
                                    i32(cmb.width), 
                                    i32(cmb.height),
                                    cmb.parent.handle, 
                                    direct_cast(cmb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if cmb.handle != nil {         
        cmb._is_created = true 
        cmb._old_hwnd = cmb.handle       
        setfont_internal(cmb)
        set_subclass(cmb, cmb_wnd_proc) 
        if len(cmb.items) > 0 do additem_internal(cmb)
        get_combo_info(cmb)
        if cmb.selected_index > -1 { // User wants to set the selected index.
            combo_set_selected_index(cmb, cmb.selected_index)
        }       
    }

}


@private 
cmb_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    cmb := control_cast(ComboBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_PAINT :
            if cmb.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cmb.paint(cmb, &pea)
                end_paint(hw, &ps)
                return 0
            }
        case WM_DESTROY:

            cmb_dtor(cmb)
            remove_subclass(cmb)

        case CM_CTLCOMMAND :
            ncode := hiword_wparam(wp)
           // ptf("WM_COMMAND notification code - %d\n", ncode)
            switch ncode {
                case CBN_SELCHANGE :
                    if cmb.selection_changed != nil {
                        ea := new_event_args()
                        cmb.selection_changed(cmb, &ea)
                    }
                case CBN_DBLCLK :

                case CBN_SETFOCUS :
                    if cmb.got_focus != nil {
                        ea := new_event_args()
                        cmb.got_focus(cmb, &ea)
                    }
                case CBN_KILLFOCUS :
                    if cmb.lost_focus != nil {
                        ea := new_event_args()
                        cmb.lost_focus(cmb, &ea)
                    }
                case CBN_EDITCHANGE :                    
                    if cmb.text_changed != nil {
                        ea := new_event_args()
                        cmb.text_changed(cmb, &ea)
                    }
                case CBN_EDITUPDATE :
                     if cmb.text_updated != nil {
                        ea := new_event_args()
                        cmb.text_updated(cmb, &ea)
                    }
                case CBN_DROPDOWN :
                    if cmb.list_opened != nil {
                        ea := new_event_args()
                        cmb.list_opened(cmb, &ea)
                    }
                case CBN_CLOSEUP :
                    if cmb.list_closed != nil {
                        ea := new_event_args()
                        cmb.list_closed(cmb, &ea)
                    }
                case CBN_SELENDOK :
                    if cmb.selection_committed != nil {
                        ea := new_event_args()
                        cmb.selection_committed(cmb, &ea)
                    }
                case CBN_SELENDCANCEL :
                    if cmb.selection_cancelled != nil {
                        ea := new_event_args()
                        cmb.selection_cancelled(cmb, &ea)
                    }
                    
            }
        
        case CM_COMBOLBCOLOR :
            //print("color combo list box")
            if cmb.fore_color != def_fore_clr || cmb.back_color != def_back_clr {
                //print("combo color rcvd")                
                dc_handle := direct_cast(wp, Hdc)
                set_bk_mode(dc_handle, Transparent)
                if cmb.fore_color != def_fore_clr do set_text_color(dc_handle, get_color_ref(cmb.fore_color))                
                if cmb._bk_brush == nil do cmb._bk_brush = create_solid_brush(get_color_ref(cmb.back_color))                 
                return to_lresult(cmb._bk_brush)
            } else {                
                if cmb._bk_brush == nil do cmb._bk_brush = create_solid_brush(get_color_ref(cmb.back_color))                 
                return to_lresult(cmb._bk_brush)
            }
        

        case CM_COMBOTBCOLOR : // We will receive this message only if combo_style == tb_list
            if cmb.fore_color != def_fore_clr || cmb.back_color != def_back_clr {                              
                dc_handle := direct_cast(wp, Hdc)
                set_bk_mode(dc_handle, Transparent)
                if cmb.fore_color != def_fore_clr do set_text_color(dc_handle, get_color_ref(cmb.fore_color))                
                if cmb._bk_brush == nil do cmb._bk_brush = create_solid_brush(get_color_ref(cmb.back_color))                 
                return to_lresult(cmb._bk_brush)
            }   
            
        case WM_PARENTNOTIFY :           
            wp_lw := loword_wparam(wp)
            switch wp_lw {
                case 512 :  // WM_MOUSEFIRST              
                    if cmb.tb_mouse_enter != nil {
                        ea := new_event_args()
                        cmb.tb_mouse_enter(cmb, &ea)
                    }
                case 513 : // WM_LBUTTONDOWN
                    if cmb.tb_click != nil {
                        ea := new_event_args()
                        cmb.tb_click(cmb, &ea)
                    }
                case 675 : // WM_MOUSELEAVE
                    if cmb.tb_mouse_leave != nil {
                        ea := new_event_args()
                        cmb.tb_mouse_leave(cmb, &ea)
                    }
            }
            

        case WM_LBUTTONDOWN:  // Only work in lb_comb and the triange btn of tb_combo                                   
            cmb._mdown_happened = true
            if cmb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.left_mouse_down(cmb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN: // Only work in lb_comb and the triange btn of tb_combo            
            cmb._mrdown_happened = true
            if cmb.right_mouse_down != nil {
            mea := new_mouse_event_args(msg, wp, lp)
            cmb.right_mouse_down(cmb, &mea)
            }
        case WM_LBUTTONUP :  // Only work in lb_comb and the triange btn of tb_combo                                       
            if cmb.left_mouse_up != nil {
            mea := new_mouse_event_args(msg, wp, lp)
            cmb.left_mouse_up(cmb, &mea)
            }
            if cmb._mdown_happened do send_message(cmb.handle, CM_LMOUSECLICK, 0, 0)

        case CM_LMOUSECLICK :
            if cmb.mouse_click != nil {
            ea := new_event_args()
            cmb.mouse_click(cmb, &ea)
            return 0
            }   

        case WM_RBUTTONUP :
            if cmb.right_mouse_up != nil {
            mea := new_mouse_event_args(msg, wp, lp)
            cmb.right_mouse_up(cmb, &mea)
            }
            if cmb._mrdown_happened do send_message(cmb.handle, CM_RMOUSECLICK, 0, 0)

        case CM_RMOUSECLICK :
            cmb._mrdown_happened = false
            if cmb.right_click != nil {
            ea := new_event_args()
            cmb.right_click(cmb, &ea)
            return 0
            }        			

        case WM_MOUSEHWHEEL:
            if cmb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.mouse_scroll(cmb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
           //print("mouse entered")
            if cmb._is_mouse_entered {
                if cmb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    cmb.mouse_move(cmb, &mea)                    
                }
            } else {
                cmb._is_mouse_entered = true
                if cmb.mouse_enter != nil  {
                    ea := new_event_args()
                    cmb.mouse_enter(cmb, &ea)                    
                }
            }
            //end case--------------------

            case WM_MOUSELEAVE :
               // print("mouse leaved combo")
                cmb._is_mouse_entered = false
                if cmb.mouse_leave != nil {               
                    ea := new_event_args()
                    cmb.mouse_leave(cmb, &ea)                
                }
        
            case WM_KEYDOWN : // only works in lb_combo style
                if cmb.key_down != nil {               
                    kea := new_key_event_args(wp)
                    cmb.key_down(cmb, &kea)                
                }

            case WM_KEYUP : // only works in lb_combo style
                if cmb.key_up != nil {               
                    kea := new_key_event_args(wp)
                    cmb.key_up(cmb, &kea)                
                }
        
            case : return def_subclass_proc(hw, msg, wp, lp)
    }
    return def_subclass_proc(hw, msg, wp, lp)
}