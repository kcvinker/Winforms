
/*===========================ListBox Docs==============================
    ListBox struct
        Constructor: new_listbox() -> ^ListBox
        Properties:
            All props from Control struct            
            items           : [dynamic]string
            hasSort         : b64
            noSelection     : b64
            multiSelection  : b64
            multiColumn     : b64
            keyPreview      : b64
            selectedItem    : string
            selectedIndex   : int
            hotIndex        : int
            hotItem         : string

        Functions:
            listbox_add_item
            listbox_add_items
            listbox_get_selected_index
            listbox_get_selected_indices
            listbox_get_item
            listbox_get_selected_item
            listbox_get_selected_items
            listbox_set_item_selected
            listbox_select_all
            listbox_set_items_selected
            listbox_clear_selection
            listbox_delete_item
            listbox_insert_item
            listbox_find_index
            listbox_get_hot_index
            listbox_get_hot_item
            listbox_clear_items
            listbox_set_selected_index
        Events:
            All events from Control struct
            onSelectionChanged
        
===============================================================================*/


package winforms
import "base:runtime"
import "core:fmt"
import api "core:sys/windows"
//import "core:slice"

WcListBoxW : wstring = L("ListBox")

ListBox :: struct 
{
    using control : Control,
    items : [dynamic]string,
    hasSort : b64,
    noSelection : b64,
    multiSelection : b64,
    multiColumn : b64,
    keyPreview : b64,
    selectedItem : string,
    selectedIndex: int,
    hotIndex : int,
    hotItem: string,
    _selIndices : [dynamic]i32,
    _dummyIndex : int,
    _bkBrush : HBRUSH,
    onSelectionChanged : EventHandler,
}

// Create new listbox type.
new_listbox :: proc{lbox_ctor1, lbox_ctor2, lbox_ctor3}

// Add an item to listbox.
listbox_add_item :: proc(lbx : ^ListBox, item : $T) 
{
    sitem : string
    when T == string {
       sitem = item
    } else {
        sitem := fmt.tprint(item)
    }
    append(&lbx.items, sitem)
    if lbx._isCreated {
        SendMessage(lbx.handle, LB_ADDSTRING, 0, dir_cast(to_wstring(sitem), LPARAM))
        // free_all(context.temp_allocator)
    }
}

// Add multiple items to listbox.
listbox_add_items :: proc(lbx : ^ListBox, items : ..any) 
{
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
            SendMessage(lbx.handle, LB_ADDSTRING, 0, dir_cast(to_wstring(item), LPARAM))
            // free_all(context.temp_allocator)
        }
    }
}

// Get the selected index from a single selection listbox
listbox_get_selected_index :: proc(lbx : ^ListBox) -> int 
{
    if !lbx.multiSelection {
        return int(SendMessage(lbx.handle, LB_GETCURSEL, 0, 0))
    }
    return -1
}

// Get the selected indices from a multi selection listbox.
listbox_get_selected_indices :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]i32 
{
    if lbx.multiSelection {
        num := SendMessage(lbx.handle, LB_GETSELCOUNT, 0, 0)
        if num > 0 {
            buffer := make([dynamic]i32, num, alloc)
            //defer delete(buffer)
            SendMessage(lbx.handle, LB_GETSELITEMS, dir_cast(num, WPARAM), dir_cast(&buffer[0], LPARAM))
            return buffer
        } else do return nil  //err_val
    } else do return nil //err_val
    return nil //err_val
}

// Get the item from listbox with given index.
// In case of invalid index, or there is no items in listbox, return an empty string.
// NOTE: Caller must free the string
listbox_get_item :: proc{lb_get_item} 

// Get the current selected item from a single selection listbox.
listbox_get_selected_item :: proc(lbx : ^ListBox) -> string 
{
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
listbox_get_selected_items :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]string 
{
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
listbox_set_item_selected :: proc(lbx : ^ListBox, indx : int) 
{
    lbx._dummyIndex = indx
    if len(lbx.items) > 0 do SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(indx)), 0)
}

// Select all items of a multi selection ListBox
listbox_select_all :: proc(lbx : ^ListBox) 
{
    bflag := true
    if lbx._isCreated && lbx.multiSelection {
        SendMessage(lbx.handle, LB_SETSEL, WPARAM(bflag), LPARAM(-1))
    }
}

// Select a items t given idices
listbox_set_items_selected :: proc(lbx : ^ListBox, flag : bool, indices : ..int) 
{
    if lbx.multiSelection {
        //bflag : b32 = false
        for i in indices {
             SendMessage(lbx.handle, LB_SETSEL, WPARAM(flag), LPARAM(i32(i)))
        }
    }
}

// Clear the selection from listbox.
listbox_clear_selection :: proc(lbx : ^ListBox) 
{
    indx : int = -1
    if len(lbx.items) > 0 {
        if lbx.multiSelection  {
            bflag : bool = false
            SendMessage(lbx.handle, LB_SETSEL, WPARAM(bflag), -1)
        } else {
            SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(indx)) , 0)
        }
    }
}

// Delete an item from listbox.
listbox_delete_item :: proc(lbx : ^ListBox, indx : int) 
{
    if len(lbx.items) > 0  && lbx._isCreated {
        lbx_clear_items_internal(lbx)
        ordered_remove(&lbx.items, indx)
        lbx_fill_items_internal(lbx)
    }
}

//Insert an item at given index into listbox
listbox_insert_item :: proc(lbx : ^ListBox, indx : int, item : any) 
{
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
listbox_find_index :: proc(lbx : ^ListBox, item : any) -> int 
{
    lb_item : string
    if value, is_str := item.(string) ; is_str {
        lb_item = value
    } else {
        lb_item = fmt.tprint(item)
    }
    wp : i32 = -1
    //defer // free_all(context.temp_allocator)
    return int(SendMessage(lbx.handle, LB_FINDSTRINGEXACT, WPARAM(wp), convert_to(LPARAM, to_wstring(lb_item)) ))
}

// Get the index of the item under mouse pointer.
listbox_get_hot_index :: proc(lbx : ^ListBox) -> int 
{
    if lbx.multiSelection {
        return int(SendMessage(lbx.handle, LB_GETCARETINDEX, 0, 0))
    }
    return -1
}

// Get the item under mouse pointer.
listbox_get_hot_item :: proc(lbx : ^ListBox) -> string 
{
    if lbx.multiSelection {
        indx := int(SendMessage(lbx.handle, LB_GETCARETINDEX, 0, 0))
        return listbox_get_item( lbx, indx)
    }
    return ""
}

// Clear all items in listbox.
listbox_clear_items :: proc(lbx : ^ListBox)  
{
    SendMessage(lbx.handle, LB_RESETCONTENT, 0, 0)
    clear_dynamic_array(&lbx.items)
}

listbox_set_selected_index :: proc(lbx : ^ListBox, indx : int) 
{
    if !lbx.multiSelection {
        SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(indx)), 0)
    }
}

//============================================Private Functions==================================
@private lbox_ctor :: proc(p : ^Form, x, y, w, h : int) -> ^ListBox 
{
    // if WcListBoxW == nil do WcListBoxW = to_wstring("ListBox")
    this := new(ListBox)
    this.kind = .List_Box
    this.parent = p
    // this.font = p.font
    this.width = w
    this.height = h
    this.xpos = x
    this.ypos = y
    this.backColor = app.clrWhite
    this.foreColor = app.clrBlack
    this._style = WS_VISIBLE | WS_CHILD | LBS_HASSTRINGS  | WS_VSCROLL | WS_BORDER | LBS_NOTIFY //LBS_SORT
    this._exStyle = 0
    this._clsName = WcListBoxW
	this._fp_beforeCreation = cast(CreateDelegate) lbx_before_creation
	this._fp_afterCreation = cast(CreateDelegate) lbx_after_creation
    this._dummyIndex = -1
    font_clone(&p.font, &this.font )
    append(&p._controls, this)
    return this
}

@private lbox_ctor1 :: proc(parent : ^Form) -> ^ListBox 
{
    lb := lbox_ctor(parent, 10, 10, 180, 200)
    if parent.createChilds do create_control(lb)
    return lb
}

@private lbox_ctor2 :: proc(parent : ^Form, x, y : int) -> ^ListBox 
{
    lb := lbox_ctor(parent, x, y, 180, 200)
    if parent.createChilds do create_control(lb)
    return lb
}

@private lbox_ctor3 :: proc(parent : ^Form, x, y, w, h : int) -> ^ListBox 
{
    lb := lbox_ctor(parent, x, y, w, h)
    if parent.createChilds do create_control(lb)
    return lb
}

@private set_lbox_style_internal :: proc(lbox : ^ListBox) 
{
    if lbox.hasSort do lbox._style |= LBS_SORT
    if lbox.multiSelection do lbox._style |= LBS_EXTENDEDSEL | LBS_MULTIPLESEL
    if lbox.multiColumn do lbox._style |= LBS_MULTICOLUMN
    if lbox.noSelection do lbox._style |= LBS_NOSEL
    if lbox.keyPreview do lbox._style |= LBS_WANTKEYBOARDINPUT
}

@private lbx_additem_internal :: proc(lbx : ^ListBox) 
{
    if len(lbx.items) > 0 {
        for item in lbx.items {
            SendMessage(lbx.handle, LB_ADDSTRING, 0, dir_cast(to_wstring(item), LPARAM))
            // free_all(context.temp_allocator)
        }
    }
}

@private lb_get_item :: proc(lbx : ^ListBox, #any_int index : int, alloc := context.allocator) -> string 
{
    if len(lbx.items) > 0 { // Check for items
        indx := i32(index)
        tlen := int(SendMessage(lbx.handle, LB_GETTEXTLEN, WPARAM(indx), 0))
        if tlen != LB_ERR { // Check for invalid index
            memory := make([]WCHAR, tlen, alloc)
            //defer delete(memory)
            str_buffer : wstring = &memory[0]
            SendMessage(lbx.handle, LB_GETTEXT, WPARAM(indx), convert_to(LPARAM, str_buffer))
            return wstring_to_string(str_buffer, context.allocator)
        }
    }
    return ""
}

@private lbx_clear_items_internal :: proc(lb : ^ListBox) 
{
    SendMessage(lb.handle, LB_RESETCONTENT, 0, 0)
    UpdateWindow(lb.handle)
}

@private lbx_fill_items_internal :: proc(lb : ^ListBox) 
{
    for item in lb.items {
        SendMessage(lb.handle, LB_ADDSTRING, 0, convert_to(LPARAM, to_wstring(item)))
        // free_all(context.temp_allocator)
    }
}

@private lbx_before_creation :: proc(lbx : ^ListBox) {set_lbox_style_internal(lbx)}

@private lbx_after_creation :: proc(lbx : ^ListBox) 
{
	set_subclass(lbx, lbx_wnd_proc)
    lbx_additem_internal(lbx)
    if lbx._dummyIndex > -1 do SendMessage(lbx.handle, LB_SETCURSEL, WPARAM(i32(lbx._dummyIndex)), 0)
}

@private listbox_property_setter :: proc(this: ^ListBox, prop: ListBoxProps, value: $T)
{
	switch prop {
		case .Has_Sort: break
		case .No_Selection: break
		case .Multi_Selection: break
		case .Multi_Column: break
		case .Key_Preview: break
        case .Selected_Item:
            if this._isCreated {
                sitem := tostring(value)
                SendMessage(this.handle, LB_SETCURSEL, WPARAM(to_wstring(sitem)), 0)
                // free_all(context.temp_allocator)
            }
        case .Selected_Index:
            when T == int {
                if this._isCreated && !this.multiSelection {
                    res := SendMessage(this.handle, LB_SETCURSEL, WPARAM(value), 0)
                    if res != LB_ERR do this.selectedIndex = value // Fix this : We can avoid using _selIndex
                } else {
                    this.selectedIndex = value
                }
            }

        case .Hot_Index: break
        case .Hot_Item: break
    }
}

@private lbx_finalize :: proc(this: ^ListBox, scid: UINT_PTR) 
{
    delete(this.items)
    delete(this._selIndices)
    delete_gdi_object(this._bkBrush)
    if this.font.handle != nil do delete_gdi_object(this.font.handle)
    RemoveWindowSubclass(this.handle, lbx_wnd_proc, scid)
    free(this)
}

@private lbx_wnd_proc :: proc "stdcall" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
                                                    sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT 
{
    context = global_context 
    lbx := control_cast(ListBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : lbx_finalize(lbx, sc_id)

        case WM_CONTEXTMENU:
		    if lbx.contextMenu != nil do contextmenu_show(lbx.contextMenu, lp)

        case CM_CTLLCOLOR :
            // ptf("lbx draw flag %d\n", lbx._drawFlag)
            if lbx._drawFlag > 0 {
                dc_handle := dir_cast(wp, HDC)
                api.SetBkMode(dc_handle, api.BKMODE.TRANSPARENT)
                if lbx.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(lbx.foreColor))
                if lbx._bkBrush == nil do lbx._bkBrush = CreateSolidBrush(get_color_ref(lbx.backColor))
                return toLRES(lbx._bkBrush)
            }

        case CM_CTLCOMMAND :
            ncode := HIWORD(wp)
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
            if lbx.onClick != nil {
                ea := new_event_args()
                lbx.onClick(lbx, &ea)
                return 0
            }

        case WM_RBUTTONDOWN:            
            if lbx.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onRightMouseDown(lbx, &mea)
            }

        case WM_RBUTTONUP :
            if lbx.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                lbx.onRightMouseUp(lbx, &mea)
            }            
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