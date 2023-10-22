package winforms
import "core:runtime"
import "core:fmt"
//import "core:slice"

WcListBoxW : wstring = L("ListBox")

ListBox :: struct {
    using control : Control,
    items : [dynamic]string,
    hasSort : b64,
    noSelection : b64,
    multiSelection : b64,
    multiColumn : b64,
    keyPreview : b64,
    _selIndices : [dynamic]i32,
    _dummyIndex : int,
    _bkBrush : HBRUSH,
    onSelectionChanged : EventHandler,
}

@private lbox_ctor :: proc(p : ^Form, x, y, w, h : int) -> ^ListBox {
    // if WcListBoxW == nil do WcListBoxW = to_wstring("ListBox")
    lbx := new(ListBox)
    lbx.kind = .List_Box
    lbx.parent = p
    lbx.font = p.font
    lbx.width = w
    lbx.height = h
    lbx.xpos = x
    lbx.ypos = y
    lbx.backColor = app.clrWhite
    lbx.foreColor = app.clrBlack
    lbx._style = WS_VISIBLE | WS_CHILD | LBS_HASSTRINGS  | WS_VSCROLL | WS_BORDER | LBS_NOTIFY //LBS_SORT
    lbx._exStyle = 0
    lbx._clsName = WcListBoxW
	lbx._fp_beforeCreation = cast(CreateDelegate) lbx_before_creation
	lbx._fp_afterCreation = cast(CreateDelegate) lbx_after_creation
    lbx._dummyIndex = -1
    return lbx
}

// Create new listbox type.
new_listbox :: proc{lbox_ctor1, lbox_ctor2, lbox_ctor3}

@private lbox_ctor1 :: proc(parent : ^Form, rapid: b8 = false) -> ^ListBox {
    lb := lbox_ctor(parent, 10, 10, 180, 200)
    if rapid do create_control(lb)
    return lb
}
@private lbox_ctor2 :: proc(parent : ^Form, x, y : int, rapid: b8 = false) -> ^ListBox {
    lb := lbox_ctor(parent, x, y, 180, 200)
    if rapid do create_control(lb)
    return lb
}

@private lbox_ctor3 :: proc(parent : ^Form, x, y, w, h : int, rapid: b8 = false) -> ^ListBox {
    lb := lbox_ctor(parent, x, y, w, h)
    if rapid do create_control(lb)
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
    if lbox.hasSort do lbox._style |= LBS_SORT
    if lbox.multiSelection do lbox._style |= LBS_EXTENDEDSEL | LBS_MULTIPLESEL
    if lbox.multiColumn do lbox._style |= LBS_MULTICOLUMN
    if lbox.noSelection do lbox._style |= LBS_NOSEL
    if lbox.keyPreview do lbox._style |= LBS_WANTKEYBOARDINPUT
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
    if lbx._isCreated {
        SendMessage(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(sitem), LPARAM))
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
    if lbx._isCreated {
        for item in tempItems {
            SendMessage(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(item), LPARAM))
        }
    }
}

@private
lbx_additem_internal :: proc(lbx : ^ListBox) {
    if len(lbx.items) > 0 {
        for item in lbx.items {
            SendMessage(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(item), LPARAM))
        }
    }
}

// Get the selected index from a single selection listbox
listbox_get_selected_index :: proc(lbx : ^ListBox) -> int {
    if !lbx.multiSelection {
        return int(SendMessage(lbx.handle, LB_GETCURSEL, 0, 0))
    }
    return -1
}

// Get the selected indices from a multi selection listbox.
listbox_get_selected_indices :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]i32 {
    if lbx.multiSelection {
        num := SendMessage(lbx.handle, LB_GETSELCOUNT, 0, 0)
        if num > 0 {
            buffer := make([dynamic]i32, num, alloc)
            //defer delete(buffer)
            SendMessage(lbx.handle, LB_GETSELITEMS, direct_cast(num, WPARAM), direct_cast(&buffer[0], LPARAM))
            return buffer
        } else do return nil  //err_val
    } else do return nil //err_val
    return nil //err_val
}

@private
lb_get_item :: proc(lbx : ^ListBox, #any_int index : int, alloc := context.allocator) -> string {
    if len(lbx.items) > 0 { // Check for items
        indx := i32(index)
        tlen := int(SendMessage(lbx.handle, LB_GETTEXTLEN, WPARAM(indx), 0))
        if tlen != LB_ERR { // Check for invalid index
            memory := make([]WCHAR, tlen, alloc)
            //defer delete(memory)
            str_buffer : wstring = &memory[0]
            SendMessage(lbx.handle, LB_GETTEXT, WPARAM(indx), convert_to(LPARAM, str_buffer))
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
        if !lbx.multiSelection { // Only allow single selection list box's
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
    if lbx.multiSelection  { // Only allow multi selection list boxes
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
    if len(lbx.items) > 0 do SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(indx)), 0)
}

// Select all items of a multi selection ListBox
listbox_select_all :: proc(lbx : ^ListBox) {
    bflag := true
    if lbx._isCreated && lbx.multiSelection do SendMessage(lbx.handle, LB_SETSEL, WPARAM(bflag), LPARAM(-1))
}


// Select a items t given idices
listbox_set_items_selected :: proc(lbx : ^ListBox, flag : bool, indices : ..int) {
    if lbx.multiSelection {
        //bflag : b32 = false
        for i in indices {
             SendMessage(lbx.handle, LB_SETSEL, WPARAM(flag), LPARAM(i32(i)))
        }
    }
}



// Clear the selection from listbox.
listbox_clear_selection :: proc(lbx : ^ListBox) {
    indx : int = -1
    if len(lbx.items) > 0 {
        if lbx.multiSelection  {
            bflag : bool = false
            SendMessage(lbx.handle, LB_SETSEL, WPARAM(bflag), -1)
        } else do SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(indx)) , 0)
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
        SendMessage(lb.handle, LB_ADDSTRING, 0, convert_to(LPARAM, to_wstring(item)))
    }
}



// Delete an item from listbox.
listbox_delete_item :: proc(lbx : ^ListBox, indx : int) {
    if len(lbx.items) > 0  && lbx._isCreated {
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
    return int(SendMessage(lbx.handle, LB_FINDSTRINGEXACT, WPARAM(wp), convert_to(LPARAM, to_wstring(lb_item)) ))
}

// Get the index of the item under mouse pointer.
listbox_get_hot_index :: proc(lbx : ^ListBox) -> int {
    if lbx.multiSelection {
        return int(SendMessage(lbx.handle, LB_GETCARETINDEX, 0, 0))
    }
    return -1
}

// Get the item under mouse pointer.
listbox_get_hot_item :: proc(lbx : ^ListBox) -> string {
    if lbx.multiSelection {
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
    if lbx._dummyIndex > -1 do SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(lbx._dummyIndex)), 0)
}


listbox_set_selected_index :: proc(lbx : ^ListBox, indx : int) {
    if !lbx.multiSelection {
        SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(indx)), 0)
    }
}

@private lbx_finalize :: proc(lbx: ^ListBox, scid: UINT_PTR) {
    delete(lbx.items)
    delete(lbx._selIndices)
    delete_gdi_object(lbx._bkBrush)
    RemoveWindowSubclass(lbx.handle, lbx_wnd_proc, scid)
    free(lbx)
}

@private lbx_wnd_proc :: proc "std" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
                                                    sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT {
    context = global_context //runtime.default_context()
    lbx := control_cast(ListBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : lbx_finalize(lbx, sc_id)


        case CM_CTLLCOLOR :
            if lbx.foreColor != def_fore_clr || lbx.backColor != def_back_clr {
                dc_handle := direct_cast(wp, HDC)
                SetBkMode(dc_handle, Transparent)
                if lbx.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(lbx.foreColor))
                if lbx._bkBrush == nil do lbx._bkBrush = CreateSolidBrush(get_color_ref(lbx.backColor))
                return to_lresult(lbx._bkBrush)
            }


        case CM_CTLCOMMAND :
            ncode := hiword_wparam(wp)
            switch ncode {
                case LBN_DBLCLK :
                    if lbx.onDoubleClick != nil {
                        ea := new_event_args()
                        lbx.onDoubleClick(lbx, &ea)
                    }
                case LBN_KILLFOCUS :
                    if lbx.onLostFocus != nil {
                        ea := new_event_args()
                        lbx.onLostFocus(lbx, &ea)
                    }
                case LBN_SELCHANGE :
                    sel_indx := SendMessage(lbx.handle, LB_GETCURSEL, 0, 0)
                    if sel_indx != LB_ERR {
                        if lbx.onSelectionChanged != nil {
                            ea := new_event_args()
                            lbx.onSelectionChanged(lbx, &ea)
                        }
                    }

                case LBN_SETFOCUS :
                    if lbx.onGotFocus != nil {
                        ea := new_event_args()
                        lbx.onGotFocus(lbx, &ea)
                    }


                case LBN_SELCANCEL :
                    //print("sel cancel")


            }
        case WM_LBUTTONDOWN:
            lbx._mDownHappened = true
            if lbx.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onMouseDown(lbx, &mea)
                return 0
            }
        case WM_LBUTTONUP :
            if lbx.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onMouseUp(lbx, &mea)
            }
            if lbx._mDownHappened {
                lbx._mDownHappened = false
                SendMessage(lbx.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            lbx._mDownHappened = false
            if lbx.onMouseClick != nil {
                ea := new_event_args()
                lbx.onMouseClick(lbx, &ea)
                return 0
            }
        case WM_RBUTTONDOWN:
            lbx._mRDownHappened = true
            if lbx.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onRightMouseDown(lbx, &mea)
            }

        case WM_RBUTTONUP :
            if lbx.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onRightMouseUp(lbx, &mea)
            }
            if lbx._mRDownHappened {
                lbx._mRDownHappened = false
                SendMessage(lbx.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            lbx._mRDownHappened = false
            if lbx.onRightClick != nil {
                ea := new_event_args()
                lbx.onRightClick(lbx, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if lbx.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onMouseScroll(lbx, &mea)
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if lbx._isMouseEntered {
                if lbx.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    lbx.onMouseMove(lbx, &mea)
                }
            }
            else {
                lbx._isMouseEntered = true
                if lbx.onMouseEnter != nil  {
                    ea := new_event_args()
                    lbx.onMouseEnter(lbx, &ea)
                }
            }

         case WM_MOUSELEAVE :
            lbx._isMouseEntered = false
            if lbx.onMouseLeave != nil {
                ea := new_event_args()
                lbx.onMouseLeave(lbx, &ea)
            }


        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}