package winforms
import "core:runtime"
import "core:fmt"
//import "core:slice"

WcListBoxW : wstring

ListBox :: struct {
    using control : Control,
    items : [dynamic]string,
    has_sort : b64,
    no_selection : b64,
    multi_selection : b64,
    multi_column : b64,
    key_preview : b64,

    _private_sel_indices : [dynamic]i32,
    _dummyIndex : int,
    _bk_brush : Hbrush,

    selection_changed : EventHandler,

}

@private lbox_ctor :: proc(p : ^Form, x, y, w, h : int) -> ListBox {
    if WcListBoxW == nil do WcListBoxW = to_wstring("ListBox")
    lbx : ListBox
    lbx.kind = .List_Box
    lbx.parent = p
    lbx.font = p.font
    lbx.width = w
    lbx.height = h
    lbx.xpos = x
    lbx.ypos = y
    lbx.back_color = app.clr_white
    lbx.fore_color = app.clr_black
    lbx._style = WS_VISIBLE | WS_CHILD | LBS_HASSTRINGS  | WS_VSCROLL | WS_BORDER | LBS_NOTIFY //LBS_SORT
    lbx._ex_style = 0
    lbx._cls_name = WcListBoxW
	lbx._before_creation = cast(CreateDelegate) lbx_before_creation
	lbx._after_creation = cast(CreateDelegate) lbx_after_creation
    lbx._dummyIndex = -1
    return lbx
}

// Create new listbox type.
new_listbox :: proc{lbox_ctor1, lbox_ctor2, lbox_ctor3}

@private lbox_ctor1 :: proc(parent : ^Form) -> ListBox {
    lb := lbox_ctor(parent, 10, 10, 180, 200)
    return lb
}
@private lbox_ctor2 :: proc(parent : ^Form, x, y : int) -> ListBox {
    lb := lbox_ctor(parent, x, y, 180, 200)
    return lb
}

@private lbox_ctor3 :: proc(parent : ^Form, x, y, w, h : int) -> ListBox {
    lb := lbox_ctor(parent, x, y, w, h)
    return lb
}
//----------------------------------------------------------------------




// ListBox Constants
    LBS_DISABLENOSCROLL :: 4096
    LBS_EXTENDEDSEL :: 0x800
    LBS_HASSTRINGS :: 64
    LBS_MULTICOLUMN :: 512
    LBS_MULTIPLESEL :: 8
    LBS_NODATA :: 0x2000
    LBS_NOINTEGRALHEIGHT :: 256
    LBS_NOREDRAW :: 4
    LBS_NOSEL :: 0x4000
    LBS_NOTIFY :: 1
    LBS_OWNERDRAWFIXED :: 16
    LBS_OWNERDRAWVARIABLE :: 32
    LBS_SORT :: 2
    LBS_STANDARD :: 0xa00003
    LBS_USETABSTOPS :: 128
    LBS_WANTKEYBOARDINPUT :: 0x400

    LB_ADDFILE :: 406
    LB_ADDSTRING :: 384
    LB_DELETESTRING :: 386
    LB_DIR :: 397
    LB_ERR :: -1
    LB_FINDSTRING :: 399
    LB_FINDSTRINGEXACT :: 418
    LB_GETANCHORINDEX :: 413
    LB_GETCARETINDEX :: 415
    LB_GETCOUNT :: 395
    LB_GETCURSEL :: 392
    LB_GETHORIZONTALEXTENT :: 403
    LB_GETITEMDATA :: 409
    LB_GETITEMHEIGHT :: 417
    LB_GETITEMRECT :: 408
    LB_GETLOCALE :: 422
    LB_GETSEL :: 391
    LB_GETSELCOUNT :: 400
    LB_GETSELITEMS :: 401
    LB_GETTEXT :: 393
    LB_GETTEXTLEN :: 394
    LB_GETTOPINDEX :: 398
    LB_INITSTORAGE :: 424
    LB_INSERTSTRING :: 385
    LB_ITEMFROMPOINT :: 425
    LB_RESETCONTENT :: 388
    LB_SELECTSTRING :: 396
    LB_SELITEMRANGE :: 411
    LB_SELITEMRANGEEX :: 387
    LB_SETANCHORINDEX :: 412
    LB_SETCARETINDEX :: 414
    LB_SETCOLUMNWIDTH :: 405
    LB_SETCOUNT :: 423
    LB_SETCURSEL :: 390
    LB_SETHORIZONTALEXTENT :: 404
    LB_SETITEMDATA :: 410
    LB_SETITEMHEIGHT :: 416
    LB_SETLOCALE :: 421
    LB_SETSEL :: 389
    LB_SETTABSTOPS :: 402
    LB_SETTOPINDEX :: 407
    LB_GETLISTBOXINFO :: 434


    LBN_DBLCLK :: 2
    LBN_ERRSPACE :: -2
    LBN_KILLFOCUS :: 5
    LBN_SELCANCEL :: 3
    LBN_SELCHANGE :: 1
    LBN_SETFOCUS :: 4
// Constants

@private set_lbox_style_internal :: proc(lbox : ^ListBox) {
    if lbox.has_sort do lbox._style |= LBS_SORT
    if lbox.multi_selection do lbox._style |= LBS_EXTENDEDSEL | LBS_MULTIPLESEL
    if lbox.multi_column do lbox._style |= LBS_MULTICOLUMN
    if lbox.no_selection do lbox._style |= LBS_NOSEL
    if lbox.key_preview do lbox._style |= LBS_WANTKEYBOARDINPUT
}

// Add an item to listbox.
listbox_add_item :: proc(lbx : ^ListBox, item : $T) {
    sitem : string
    when T == string {
       sitem = item
    } else {
        sitem := fmt.tprint(item)
    }
    append(&lbx.items, sitem)
    if lbx._is_created {
        SendMessage(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(sitem), Lparam))
    }
}

// Add multiple items to listbox.
listbox_add_items :: proc(lbx : ^ListBox, items : ..any) {
    tempItems : [dynamic] string
    defer delete(tempItems)
    for i in items {
        if value, is_str := i.(string) ; is_str { // Magic -- type assert
            append(&lbx.items, value)
            append(&tempItems, value)
        }
        else {
            a_string := fmt.tprint(i)
            append(&lbx.items, a_string)
            append(&tempItems, a_string)
        }
    }
    if lbx._is_created {
        for item in tempItems {
            SendMessage(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(item), Lparam))
        }
    }
}

@private
lbx_additem_internal :: proc(lbx : ^ListBox) {
    if len(lbx.items) > 0 {
        for item in lbx.items {
            SendMessage(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(item), Lparam))
        }
    }
}

// Get the selected index from a single selection listbox
listbox_get_selected_index :: proc(lbx : ^ListBox) -> int {
    if !lbx.multi_selection {
        return int(SendMessage(lbx.handle, LB_GETCURSEL, 0, 0))
    }
    return -1
}

// Get the selected indices from a multi selection listbox.
listbox_get_selected_indices :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]i32 {
    if lbx.multi_selection {
        num := SendMessage(lbx.handle, LB_GETSELCOUNT, 0, 0)
        if num > 0 {
            buffer := make([dynamic]i32, num, alloc)
            //defer delete(buffer)
            SendMessage(lbx.handle, LB_GETSELITEMS, direct_cast(num, Wparam), direct_cast(&buffer[0], Lparam))
            return buffer
        } else do return nil  //err_val
    } else do return nil //err_val
    return nil //err_val
}

@private
lb_get_item :: proc(lbx : ^ListBox, #any_int index : int, alloc := context.allocator) -> string {
    if len(lbx.items) > 0 { // Check for items
        indx := i32(index)
        tlen := int(SendMessage(lbx.handle, LB_GETTEXTLEN, Wparam(indx), 0))
        if tlen != LB_ERR { // Check for invalid index
            memory := make([]Wchar, tlen, alloc)
            //defer delete(memory)
            str_buffer : wstring = &memory[0]
            SendMessage(lbx.handle, LB_GETTEXT, Wparam(indx), convert_to(Lparam, str_buffer))
            return wstring_to_utf8(str_buffer, -1)
        }
    }
    return ""
}

// @private lb_get_item2 :: proc(lbx : ^ListBox, indx : int) -> string {
//     return lb_get_item(lbx, i32(indx))
// }

// Get the item from listbox with given index.
// In case of invalid index, or there is no items in listbox, return an empty string.
listbox_get_item :: proc{lb_get_item} //,
                         //lb_get_item2}

// Get the current selected item from a single selection listbox.
listbox_get_selected_item :: proc(lbx : ^ListBox) -> string {
    if len(lbx.items) > 0 { // Check for items
        if !lbx.multi_selection { // Only allow single selection list box's
            curr_sel_indx := (SendMessage(lbx.handle, LB_GETCURSEL, 0, 0))
            if curr_sel_indx != LB_ERR { // Checking for a selection
                return listbox_get_item(lbx, int(curr_sel_indx))
            }
        }
    }
    return ""
}

// Get selected items from a multi selection listbox.
listbox_get_selected_items :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]string {
    if lbx.multi_selection  { // Only allow multi selection list boxes
        sel_indices := listbox_get_selected_indices(lbx)
        if len(sel_indices) > 0 { // If there are selections
            result := make([dynamic]string, len(sel_indices), alloc)
            for i := 0 ; i < len(sel_indices) ; i += 1 {
                item := listbox_get_item(lbx, sel_indices[i])
                result[i] = item
            }
            return result
        }
    }

    return nil
}

// Set an item at given index selected
listbox_set_item_selected :: proc(lbx : ^ListBox, indx : int) {
    lbx._dummyIndex = indx
    if len(lbx.items) > 0 do SendMessage(lbx.handle, LB_SETCURSEL, Wparam(i32(indx)), 0)
}

// Select all items of a multi selection ListBox
listbox_select_all :: proc(lbx : ^ListBox) {
    bflag := true
    if lbx._is_created && lbx.multi_selection do SendMessage(lbx.handle, LB_SETSEL, Wparam(bflag), Lparam(-1))
}


// Select a items t given idices
listbox_set_items_selected :: proc(lbx : ^ListBox, flag : bool, indices : ..int) {
    if lbx.multi_selection {
        //bflag : b32 = false
        for i in indices {
             SendMessage(lbx.handle, LB_SETSEL, Wparam(flag), Lparam(i32(i)))
        }
    }
}



// Clear the selection from listbox.
listbox_clear_selection :: proc(lbx : ^ListBox) {
    indx : int = -1
    if len(lbx.items) > 0 {
        if lbx.multi_selection  {
            bflag : bool = false
            SendMessage(lbx.handle, LB_SETSEL, Wparam(bflag), -1)
        } else do SendMessage(lbx.handle, LB_SETCURSEL, Wparam(i32(indx)) , 0)
    }
}

@private
lbx_clear_items_internal :: proc(lb : ^ListBox) {
    SendMessage(lb.handle, LB_RESETCONTENT, 0, 0)
    UpdateWindow(lb.handle)
}

@private
lbx_fill_items_internal :: proc(lb : ^ListBox) {
    for item in lb.items {
        SendMessage(lb.handle, LB_ADDSTRING, 0, convert_to(Lparam, to_wstring(item)))
    }
}



// Delete an item from listbox.
listbox_delete_item :: proc(lbx : ^ListBox, indx : int) {
    if len(lbx.items) > 0  && lbx._is_created {
        lbx_clear_items_internal(lbx)
        ordered_remove(&lbx.items, indx)
        lbx_fill_items_internal(lbx)
    }
}

//Insert an item at given index into listbox
listbox_insert_item :: proc(lbx : ^ListBox, indx : int, item : any) {
    lb_item : string
    if value, is_str := item.(string) ; is_str {
        lb_item = value
    } else {
        lb_item = fmt.tprint(item)
    }
    lbx_clear_items_internal(lbx)
    runtime.inject_at_elem(&lbx.items, indx, lb_item)
    lbx_fill_items_internal(lbx)
}

// Find the index of given item in listbox.
listbox_find_index :: proc(lbx : ^ListBox, item : any) -> int {
    lb_item : string
    if value, is_str := item.(string) ; is_str {
        lb_item = value
    } else {
        lb_item = fmt.tprint(item)
    }
    wp : i32 = -1
    return int(SendMessage(lbx.handle, LB_FINDSTRINGEXACT, Wparam(wp), convert_to(Lparam, to_wstring(lb_item)) ))
}

// Get the index of the item under mouse pointer.
listbox_get_hot_index :: proc(lbx : ^ListBox) -> int {
    if lbx.multi_selection {
        return int(SendMessage(lbx.handle, LB_GETCARETINDEX, 0, 0))
    }
    return -1
}

// Get the item under mouse pointer.
listbox_get_hot_item :: proc(lbx : ^ListBox) -> string {
    if lbx.multi_selection {
        indx := int(SendMessage(lbx.handle, LB_GETCARETINDEX, 0, 0))
        return listbox_get_item( lbx, indx)
    }
    return ""
}

// Clear all items in listbox.
listbox_clear_items :: proc(lbx : ^ListBox)  {
    SendMessage(lbx.handle, LB_RESETCONTENT, 0, 0)
    clear_dynamic_array(&lbx.items)

}

@private lbx_before_creation :: proc(lbx : ^ListBox) {set_lbox_style_internal(lbx)}

@private lbx_after_creation :: proc(lbx : ^ListBox) {
	set_subclass(lbx, lbx_wnd_proc)
    lbx_additem_internal(lbx)
    if lbx._dummyIndex > -1 do SendMessage(lbx.handle, LB_SETCURSEL, Wparam(i32(lbx._dummyIndex)), 0)

}


listbox_set_selected_index :: proc(lbx : ^ListBox, indx : int) {
    if !lbx.multi_selection {
        SendMessage(lbx.handle, LB_SETCURSEL, Wparam(i32(indx)), 0)
    }
}

@private lbx_finalize :: proc(lbx: ^ListBox, scid: UintPtr) {
    delete(lbx.items)
    delete(lbx._private_sel_indices)
    delete_gdi_object(lbx._bk_brush)
    RemoveWindowSubclass(lbx.handle, lbx_wnd_proc, scid)
}

@private lbx_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam,
                                                    sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    lbx := control_cast(ListBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : lbx_finalize(lbx, sc_id)


        case CM_CTLLCOLOR :
            if lbx.fore_color != def_fore_clr || lbx.back_color != def_back_clr {
                dc_handle := direct_cast(wp, Hdc)
                SetBkMode(dc_handle, Transparent)
                if lbx.fore_color != def_fore_clr do SetTextColor(dc_handle, get_color_ref(lbx.fore_color))
                if lbx._bk_brush == nil do lbx._bk_brush = CreateSolidBrush(get_color_ref(lbx.back_color))
                return to_lresult(lbx._bk_brush)
            }


        case CM_CTLCOMMAND :
            ncode := hiword_wparam(wp)
            switch ncode {
                case LBN_DBLCLK :
                    if lbx.double_click != nil {
                        ea := new_event_args()
                        lbx.double_click(lbx, &ea)
                    }
                case LBN_KILLFOCUS :
                    if lbx.lost_focus != nil {
                        ea := new_event_args()
                        lbx.lost_focus(lbx, &ea)
                    }
                case LBN_SELCHANGE :
                    sel_indx := SendMessage(lbx.handle, LB_GETCURSEL, 0, 0)
                    if sel_indx != LB_ERR {
                        if lbx.selection_changed != nil {
                            ea := new_event_args()
                            lbx.selection_changed(lbx, &ea)
                        }
                    }

                case LBN_SETFOCUS :
                    if lbx.got_focus != nil {
                        ea := new_event_args()
                        lbx.got_focus(lbx, &ea)
                    }


                case LBN_SELCANCEL :
                    //print("sel cancel")


            }
        case WM_LBUTTONDOWN:
            lbx._mdown_happened = true
            if lbx.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.left_mouse_down(lbx, &mea)
                return 0
            }
        case WM_LBUTTONUP :
            if lbx.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.left_mouse_up(lbx, &mea)
            }
            if lbx._mdown_happened {
                lbx._mdown_happened = false
                SendMessage(lbx.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            lbx._mdown_happened = false
            if lbx.mouse_click != nil {
                ea := new_event_args()
                lbx.mouse_click(lbx, &ea)
                return 0
            }
        case WM_RBUTTONDOWN:
            lbx._mrdown_happened = true
            if lbx.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.right_mouse_down(lbx, &mea)
            }

        case WM_RBUTTONUP :
            if lbx.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.right_mouse_up(lbx, &mea)
            }
            if lbx._mrdown_happened {
                lbx._mrdown_happened = false
                SendMessage(lbx.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            lbx._mrdown_happened = false
            if lbx.right_click != nil {
                ea := new_event_args()
                lbx.right_click(lbx, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if lbx.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.mouse_scroll(lbx, &mea)
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if lbx._is_mouse_entered {
                if lbx.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    lbx.mouse_move(lbx, &mea)
                }
            }
            else {
                lbx._is_mouse_entered = true
                if lbx.mouse_enter != nil  {
                    ea := new_event_args()
                    lbx.mouse_enter(lbx, &ea)
                }
            }

         case WM_MOUSELEAVE :
            lbx._is_mouse_entered = false
            if lbx.mouse_leave != nil {
                ea := new_event_args()
                lbx.mouse_leave(lbx, &ea)
            }


        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}