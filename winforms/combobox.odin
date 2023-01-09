
package winforms

import "core:fmt"
import "core:runtime"
import "core:strings"
//import "core:reflect"

WcComboW : wstring

DropDownStyle :: enum {Tb_Combo, Lb_Combo,}

ComboBox :: struct {
    using control : Control,
    combo_style : DropDownStyle,
    items : [dynamic]string, // Don't forget to delete it when combo box deing destroyed.
    visible_item_count : int,
    selected_index : int,
    _recreate_enabled : bool, // Used when we need to recreate existing combo

    _bk_brush : Hbrush,
    // _old_hwnd : Hwnd,
    _old_ctl_id : Uint,
    _edit_subclass_id : UintPtr,
    _myrc : Rect,

    // set_prop: PropSetter,
    props: ComboBoxProps,

    // Events
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


ComboData :: struct {
    list_box_hwnd : Hwnd,
    combo_hwnd : Hwnd,
    edit_hwnd : Hwnd,
    combo_id : u32,
}

ComboBoxProps :: enum {style, selected_index, selected_item, back_color, }
// ComboPropSetter :: proc(ctl: ^ComboBox, prop: ComboBoxProps, value: $T)

new_combo_data :: proc(cbi : COMBOBOXINFO, id : u32) -> ComboData {
    cd : ComboData
    cd.combo_hwnd = cbi.hwndCombo
    cd.combo_id = id
    cd.edit_hwnd = cbi.hwndItem
    cd.list_box_hwnd = cbi.hwndList
    return cd
}

@private get_combo_info :: proc(cmb : ^ComboBox) -> ComboData  {
    // Collect the data from Combobox control.
    cmInfo : COMBOBOXINFO
    cmInfo.cbSize = size_of(cmInfo)
    SendMessage(cmb.handle, CB_GETCOMBOBOXINFO, 0, direct_cast(&cmInfo, Lparam))
    cd := new_combo_data(cmInfo, cmb.control_id)
    return cd
}

@private cmb_ctor :: proc(p : ^Form, w : int = 130, h : int = 30, x: int = 10, y: int = 10) -> ComboBox {
    if WcComboW == nil do WcComboW = to_wstring("ComboBox")
    cmb : ComboBox
    cmb.kind = .Combo_Box
    cmb.parent = p
    cmb.font = p.font
    cmb.xpos = x
    cmb.ypos = y
    cmb.width = w
    cmb.height = h
    cmb.back_color = def_back_clr
    cmb.fore_color = def_fore_clr
    cmb._ex_style = 0
    cmb.selected_index = -1
    cmb._style = WS_CHILD | WS_VISIBLE | CBS_DROPDOWN
    cmb._ex_style = WS_EX_CLIENTEDGE    // WS_EX_WINDOWEDGE WS_EX_STATICEDGE
    //cmb._txt_style = DT_SINGLELINE | DT_VCENTER
    cmb._cls_name = WcComboW
    cmb._before_creation = cast(CreateDelegate) cmb_before_creation
	cmb._after_creation = cast(CreateDelegate) cmb_after_creation
    // cmb.set_prop = combo_set_prop
    return cmb
}

new_combobox :: proc{new_combo1, new_combo2}

@private new_combo1 :: proc(parent : ^Form) -> ComboBox {
    cmb := cmb_ctor(parent)

    return cmb
}

@private new_combo2 :: proc(parent : ^Form, w, h, x, y : int ) -> ComboBox {
    cmb := cmb_ctor(parent, w, h, x, y)
    return cmb
}

@private cmb_dtor :: proc(cmb : ^ComboBox) {
    if !cmb._recreate_enabled {
        delete_gdi_object(cmb.font.handle)
        delete_gdi_object(cmb._bk_brush)
        delete(cmb.items)
    }
}

combo_set_style :: proc(cmb : ^ComboBox, style : DropDownStyle) {
    /* There is no other way to change the dropdown style of an existing combo box.
     * We need to destroy the old combo and create a new one with same size and pos.
     * Then make fill it with old combo items. */
    if cmb._is_created {
        if cmb.combo_style == style do return
        cmb.combo_style = style
        cmb._recreate_enabled = true
        DestroyWindow(cmb.handle)
        create_control(cmb)
    } else {
        // Not now baby
        cmb.combo_style = style
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
        SendMessage(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(sitem), Lparam))
    }
}

combo_open_list :: proc(cmb : ^ComboBox) { SendMessage(cmb.handle, CB_SHOWDROPDOWN, Wparam(1), 0) }
combo_close_list :: proc(cmb : ^ComboBox) { SendMessage(cmb.handle, CB_SHOWDROPDOWN, Wparam(0), 0) }


@private add_items2 :: proc(cmb : ^ComboBox, items : ..any ) {
    for i in items {
        if value, is_str := i.(string) ; is_str { // Magic -- type assert
            append(&cmb.items, value)
            if cmb._is_created {
                SendMessage(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(value), Lparam))
            }
        } else {
            a_string := fmt.tprint(i)
            append(&cmb.items, a_string)
            if cmb._is_created {
                SendMessage(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(a_string), Lparam))
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
    // IMPORTANT - add code for update combo items
}

@private additem_internal :: proc(cmb : ^ComboBox) {
    for i in cmb.items {
        SendMessage(cmb.handle, CB_ADDSTRING, 0, direct_cast(to_wstring(i), Lparam))
    }
}

combo_get_selected_index :: proc(cmb : ^ComboBox) -> int {
    cmb.selected_index = int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    return cmb.selected_index
}

combo_set_selected_index :: proc(cmb : ^ComboBox, indx : int)  {
    SendMessage(cmb.handle, CB_SETCURSEL, Wparam(i32(indx)), 0)
    cmb.selected_index = indx
}

combo_set_selected_item :: proc(cmb : ^ComboBox, item : $T) {
    value := fmt.tprint(item)
    wp : i32 = -1
    indx := SendMessage(cmb.handle, CB_FINDSTRINGEXACT, Wparam(wp), direct_cast(&value, Lparam))
    if indx == LB_ERR do return
    SendMessage(cmb.handle, CB_SETCURSEL, Wparam(i32(indx)), 0)
    cmb.selected_index = int(indx)
}


combo_get_selected_item :: proc(cmb : ^ComboBox) -> any {
    indx := int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        return cmb.items[indx]
    } else do return ""
}

combo_delete_selected_item :: proc(cmb : ^ComboBox) {
    indx := i32(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        SendMessage(cmb.handle, CB_DELETESTRING, Wparam(indx), 0)
        ordered_remove(&cmb.items, int(indx))
    }
}

combo_delete_item :: proc(cmb : ^ComboBox, indx : int) {
    SendMessage(cmb.handle, CB_DELETESTRING, direct_cast(i32(indx), Wparam), 0)
    ordered_remove(&cmb.items, indx)
}

combo_clear_items :: proc(cmb : ^ComboBox) {
    SendMessage(cmb.handle, CB_DELETESTRING, 0, 0)
    // TODO - clear dynamic array of combo.
}

@private combo_set_colors :: proc(cmb: ^ComboBox, bg: bool, value: uint) {
    if bg {
        cmb.back_color = value
        cmb._bk_brush = get_solid_brush(cmb.back_color)
    } else {
        cmb.fore_color = value
    }

    redraw_ctl1(cmb)
}



@private check_mouse_leave :: proc(cmb: ^ComboBox) -> bool {
    /* Since combo box is a combination of button, edit and list box...
     * we need to take extra care for handling mouse enter & leave messages.
     * So we are checking whether the current mouse pos is in our...
     * control rect or not. To do that check, we need to convert the mouse...
     * points into our window's client coordinate level. */
    pt : Point
    GetCursorPos(&pt)
    ScreenToClient(cmb.parent.handle, &pt)
    res := cast(bool) PtInRect(&cmb._myrc, pt)

    /* Inverting the result because, PtInRect will return true if mouse is inside rect.
     * We just want the opposite of that. */
    return !res
}

@private cmb_before_creation :: proc(cmb : ^ComboBox) {
    if cmb.combo_style == .Lb_Combo {
        cmb._style |= CBS_DROPDOWNLIST
    } else {
        cmb._style |= CBS_DROPDOWN
    }

    /* We need to take special care about contril ID.
     * If this is the first time a combo is created, we can use...
     * global control ID. But if a combo is recreating, then...
     * we must use the old comb's control ID. */
    if cmb._recreate_enabled {
        cmb.control_id = cmb._old_ctl_id

        // Collect the selected index if any
        cmb.selected_index = int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    } else {
        _global_ctl_id += 1
    	cmb.control_id = _global_ctl_id
    }

    // Set back color brush
    cmb._bk_brush = get_solid_brush(cmb.back_color)
}

@private cmb_after_creation :: proc(cmb : ^ComboBox) {
	set_subclass(cmb, cmb_wnd_proc)
    // cmb._old_hwnd = cmb.handle
    cmb._old_ctl_id = cmb.control_id
    cd : ComboData = get_combo_info(cmb)
    // fmt.println("item handle ", cd.edit_hwnd)

    // Collecting child controls info
    if cmb._recreate_enabled {
        cmb._recreate_enabled = false
        update_combo_data(cmb.parent, cd)

        // If selected index was a valid number, set the selection again.
        if cmb.selected_index != -1 {
            SendMessage(cmb.handle, CB_SETCURSEL, Wparam(i32(cmb.selected_index)), 0)
        }
    } else {
        collect_combo_data(cmb.parent, cd)
    }

    // Now, subclass the edit control.
    SetWindowSubclass(cd.edit_hwnd, edit_wnd_proc, cmb._edit_subclass_id, to_dwptr(cmb))
    cmb._edit_subclass_id += 1 // We don't want to use the same id again and again.

    if len(cmb.items) > 0 do additem_internal(cmb)

    if cmb.selected_index > -1 { // User wants to set the selected index.
        combo_set_selected_index(cmb, cmb.selected_index)
    }

    // Lastly, we need to collect the control rect for managing mouse enter & leave events
    set_rect(&cmb._myrc, i32(cmb.xpos), i32(cmb.ypos), i32(cmb.width + cmb.xpos), i32(cmb.height + cmb.ypos))
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
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cmb.paint(cmb, &pea)
                EndPaint(hw, &ps)
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
                SetBkMode(dc_handle, Transparent)
                if cmb.fore_color != def_fore_clr do SetTextColor(dc_handle, get_color_ref(cmb.fore_color))
                if cmb._bk_brush == nil do cmb._bk_brush = CreateSolidBrush(get_color_ref(cmb.back_color))
                return to_lresult(cmb._bk_brush)
            } else {
                if cmb._bk_brush == nil do cmb._bk_brush = CreateSolidBrush(get_color_ref(cmb.back_color))
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


        case WM_LBUTTONUP :  // Only work in lb_comb and the triange btn of tb_combo
            if cmb.left_mouse_up != nil {
            mea := new_mouse_event_args(msg, wp, lp)
            cmb.left_mouse_up(cmb, &mea)
            }
            if cmb._mdown_happened {
                cmb._mdown_happened = false
                SendMessage(cmb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if cmb.mouse_click != nil {
            ea := new_event_args()
            cmb.mouse_click(cmb, &ea)
            return 0
            }

         case WM_RBUTTONDOWN: // Only work in lb_comb and the triange btn of tb_combo
            cmb._mrdown_happened = true
            if cmb.right_mouse_down != nil {
            mea := new_mouse_event_args(msg, wp, lp)
            cmb.right_mouse_down(cmb, &mea)
            }

        case WM_RBUTTONUP :
            if cmb.right_mouse_up != nil {
            mea := new_mouse_event_args(msg, wp, lp)
            cmb.right_mouse_up(cmb, &mea)
            }
            if cmb._mrdown_happened {
                cmb._mrdown_happened = false
                SendMessage(cmb.handle, CM_RMOUSECLICK, 0, 0)
            }

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

        case WM_MOUSELEAVE : // Main Proc
            if cmb.mouse_leave != nil || cmb.mouse_enter != nil || cmb.mouse_move != nil {
                if check_mouse_leave(cmb) {
                    cmb._is_mouse_entered = false
                    if cmb.mouse_leave != nil {
                        ea := new_event_args()
                        cmb.mouse_leave(cmb, &ea)
                    }
                }
            }

    }
    return DefSubclassProc(hw, msg, wp, lp)
}


@private
edit_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    cmb := control_cast(ComboBox, ref_data)
    switch msg {
        case WM_DESTROY:
            RemoveWindowSubclass(hw, edit_wnd_proc, sc_id)

        case CM_CTLLCOLOR :
            if cmb.fore_color != def_fore_clr || cmb.back_color != def_back_clr {
                dc_handle := direct_cast(wp, Hdc)
                // fmt.println("label color ", hw)
                if cmb.fore_color != def_fore_clr do SetTextColor(dc_handle, get_color_ref(cmb.fore_color))
                if cmb.back_color != def_back_clr do SetBackColor(dc_handle, get_color_ref(cmb.back_color))
                return to_lresult(cmb._bk_brush)
            }


        // case WM_SETTEXT:
        //     fmt.println("label set text ", lp)


        case WM_KEYDOWN : // only works in Tb_combo style
            if cmb.key_down != nil {
                kea := new_key_event_args(wp)
                cmb.key_down(cmb, &kea)
            }

        case WM_KEYUP : // only works in Tb_combo style
            if cmb.key_up != nil {
                kea := new_key_event_args(wp)
                cmb.key_up(cmb, &kea)
            }

        case WM_LBUTTONDOWN:  // Only work in lb_comb and the triange btn of tb_combo
            cmb._mdown_happened = true
            if cmb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.left_mouse_down(cmb, &mea)
                return 0
            }


        case WM_LBUTTONUP :  // Only work in lb_comb and the triange btn of tb_combo
            if cmb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.left_mouse_up(cmb, &mea)
            }
            if cmb._mdown_happened {
                cmb._mdown_happened = false
                SendMessage(cmb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            if cmb.mouse_click != nil {
                ea := new_event_args()
                cmb.mouse_click(cmb, &ea)
                return 0
            }

        case WM_RBUTTONDOWN: // Only work in lb_comb and the triange btn of tb_combo
            cmb._mrdown_happened = true
            if cmb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.right_mouse_down(cmb, &mea)
            }


        case WM_RBUTTONUP :
            if cmb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.right_mouse_up(cmb, &mea)
            }
            if cmb._mrdown_happened {
                cmb._mrdown_happened = false
                SendMessage(cmb.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            cmb._mrdown_happened = false
            if cmb.right_click != nil {
                ea := new_event_args()
                cmb.right_click(cmb, &ea)
                return 0
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
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

        case WM_MOUSELEAVE : // Edit Proc
            if cmb.combo_style == .Tb_Combo && (cmb.mouse_leave != nil || cmb.mouse_enter != nil || cmb.mouse_move != nil) {
                if check_mouse_leave(cmb) {
                    cmb._is_mouse_entered = false
                    if cmb.mouse_leave != nil {
                        ea := new_event_args()
                        cmb.mouse_leave(cmb, &ea)
                    }
                }
            }



    }

    return DefSubclassProc(hw, msg, wp, lp)
}

testproc :: proc(cmb: ^ComboBox, p: $T) {
    id := typeid_of(type_of(p))
	info: ^runtime.Type_Info
	info = type_info_of(id)
    // print(typeid_of(type_of(info)))
    print(info.id)
}