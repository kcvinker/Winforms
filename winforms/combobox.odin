
/*===========================================ComboBox Docs=========================================================
    ComboBox struct
        Constructor: new_comboBox() -> ^ComboBox
        Properties:
            All props from Control struct
            comboStyle          : DropDownStyle enum
            items               : [dynamic]string
            visibleItemCount    : int
            selectedIndex       : int
            selectedItem        : string
        Functions:
            combo_set_style()
            combo_add_item()
            combo_open_list()
            combo_close_list()
            combo_add_items()
            combo_add_array()
            combo_get_selected_index()
            combo_set_selected_index()
            combo_set_selected_item()
            combo_get_selected_item()
            combo_delete_selected_item()
            combo_delete_item()
            combo_clear_items()
        Events:
            EventHandler type -proc(^Control, ^EventArgs) [See events.odin]
                onSelectionChanged
                onSelectionCommitted
                onSelectionCancelled
                onTextChanged
                onTextUpdated
                onListOpened
                onListClosed
                onTBClick
                onTBMouseLeave
                onTBMouseEnter
        
==============================================================================================================*/

package winforms

import "core:fmt"
import "base:runtime"
import api "core:sys/windows"


WcComboW : wstring = L("ComboBox")

DropDownStyle :: enum {Tb_Combo, Lb_Combo,}

ComboBox :: struct
{
    using control : Control,
    comboStyle : DropDownStyle,
    items : [dynamic]string, // Don't forget to delete it when combo box deing destroyed.
    visibleItemCount : int,
    selectedIndex : int,
    selectedItem : string,
    _recreateEnabled : bool, // Used when we need to recreate existing combo
    _bkBrush : HBRUSH,
    _oldCtlID : UINT,
    _editSubclsID : UINT_PTR,
    _myrc : RECT,

    // Events
    onSelectionChanged,
    onSelectionCommitted,
    onSelectionCancelled,
    onTextChanged,
    onTextUpdated,
    onListOpened,
    onListClosed,
    onTBClick,
    onTBMouseLeave,
    onTBMouseEnter : EventHandler,
}

// Create new ComboBox
new_combobox :: proc{new_combo1, new_combo2, new_combo3}

// Show combo's dropdown list
combo_open_list :: proc(cmb : ^ComboBox) { SendMessage(cmb.handle, CB_SHOWDROPDOWN, WPARAM(1), 0) }

// Close combo's dropdown list
combo_close_list :: proc(cmb : ^ComboBox) { SendMessage(cmb.handle, CB_SHOWDROPDOWN, WPARAM(0), 0) }

// Add an item to combo.
combo_add_item :: proc(cmb : ^ComboBox, item : $T )
{
    sitem : string
    when T == string {
        sitem = item
    } else {
        sitem := fmt.tprint(an_item)
    }
    append(&cmb.items, sitem)
    if cmb._isCreated {
        SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(sitem), LPARAM))
        // free_all(context.temp_allocator)
    }
}

// Add items to combo in bulk
combo_add_items :: proc{add_items2}

// Add an array to combo box
combo_add_array :: proc(cmb : ^ComboBox, items : []$T )
{
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

// Get the selected index number
combo_get_selected_index :: proc(cmb : ^ComboBox) -> int
{
    cmb.selectedIndex = int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    return cmb.selectedIndex
}

// Set the item in given index as selected item
combo_set_selected_index :: proc(cmb : ^ComboBox, indx : int)
{
    SendMessage(cmb.handle, CB_SETCURSEL, WPARAM(i32(indx)), 0)
    cmb.selectedIndex = indx
}

// Set the given item as selected item
combo_set_selected_item :: proc(cmb : ^ComboBox, item : $T)
{
    sitem := fmt.tprint(item)
    wp : i32 = -1
    indx := cast(i32) SendMessage(cmb.handle, CB_FINDSTRINGEXACT, WPARAM(wp), dir_cast(to_wstring(sitem), LPARAM))
    if indx == LB_ERR do return
    SendMessage(cmb.handle, CB_SETCURSEL, WPARAM(indx), 0)
    cmb.selectedIndex = int(indx)
    cmb.selectedItem = sitem
    // free_all(context.temp_allocator)
}

// Get the selected item
combo_get_selected_item :: proc(cmb : ^ComboBox) -> any
{
    indx := int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        return cmb.items[indx]
    } else do return ""
}

// Delete the selected item
combo_delete_selected_item :: proc(cmb : ^ComboBox)
{
    indx := i32(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        SendMessage(cmb.handle, CB_DELETESTRING, WPARAM(indx), 0)
        ordered_remove(&cmb.items, int(indx))
    }
}

// Delete the item in given index
combo_delete_item :: proc(cmb : ^ComboBox, indx : int)
{
    SendMessage(cmb.handle, CB_DELETESTRING, dir_cast(i32(indx), WPARAM), 0)
    ordered_remove(&cmb.items, indx)
}

// Clear all items from combo
combo_clear_items :: proc(cmb : ^ComboBox)
{
    SendMessage(cmb.handle, CB_DELETESTRING, 0, 0)
    // TODO - clear dynamic array of combo.
}

// Set combo box's drop down style
combo_set_style :: proc(cmb : ^ComboBox, style : DropDownStyle)
{
    /* There is no other way to change the dropdown style of an existing combo box.
     * We need to destroy the old combo and create a new one with same size and pos.
     * Then fill the old combo items. */
    if cmb._isCreated {
        if cmb.comboStyle == style do return
        cmb.comboStyle = style
        cmb._recreateEnabled = true
        DestroyWindow(cmb.handle)
        cmb.handle = nil
        create_control(cmb)
    } else {
        // Not now baby
        cmb.comboStyle = style
    }
}


//============================================Private functions==========================================
@private ComboData :: struct
{
    listBoxHwnd : HWND,
    comboHwnd : HWND,
    editHwnd : HWND,
    comboID : u32,
}

@private new_combo_data :: proc(cbi : COMBOBOXINFO, id : u32) -> ComboData
{
    cd : ComboData
    cd.comboHwnd = cbi.hwndCombo
    cd.comboID = id
    cd.editHwnd = cbi.hwndItem
    cd.listBoxHwnd = cbi.hwndList
    return cd
}

@private get_combo_info :: proc(cmb : ^ComboBox) -> ComboData
{
    // Collect the data from Combobox control.
    cmInfo : COMBOBOXINFO
    cmInfo.cbSize = size_of(cmInfo)
    SendMessage(cmb.handle, CB_GETCOMBOBOXINFO, 0, dir_cast(&cmInfo, LPARAM))
    cd := new_combo_data(cmInfo, cmb.controlID)
    return cd
}

@private cmb_ctor :: proc(p : ^Form, w : int = 130, h : int = 30, x: int = 10, y: int = 10) -> ^ComboBox
{
    // if WcComboW == nil do WcComboW = to_wstring("ComboBox")
    cmb := new(ComboBox)
    cmb.kind = .Combo_Box
    cmb.parent = p
    cmb.font = p.font
    cmb.xpos = x
    cmb.ypos = y
    cmb.width = w
    cmb.height = h
    cmb.backColor = app.clrWhite
    cmb.foreColor = app.clrBlack
    cmb._exStyle = 0
    cmb.selectedIndex = -1
    cmb.comboStyle = DropDownStyle.Lb_Combo
    cmb._style = WS_CHILD | WS_VISIBLE | CBS_DROPDOWN
    cmb._exStyle = WS_EX_CLIENTEDGE    // WS_EX_WINDOWEDGE WS_EX_STATICEDGE
    //cmb._txt_style = DT_SINGLELINE | DT_VCENTER
    cmb._clsName = WcComboW
    cmb._fp_beforeCreation = cast(CreateDelegate) cmb_before_creation
	cmb._fp_afterCreation = cast(CreateDelegate) cmb_after_creation
    append(&p._controls, cmb)
    return cmb
}

@private new_combo1 :: proc(parent : ^Form) -> ^ComboBox
{
    cmb := cmb_ctor(parent)
    if parent.createChilds do create_control(cmb)
    return cmb
}

@private new_combo2 :: proc(parent : ^Form, x, y : int ) -> ^ComboBox
{
    cmb := cmb_ctor(parent, x = x, y= y)
    if parent.createChilds do create_control(cmb)
    return cmb
}

@private new_combo3 :: proc(parent : ^Form, x, y, w, h : int ) -> ^ComboBox
{
    cmb := cmb_ctor(parent, w, h, x, y)
    if parent.createChilds do create_control(cmb)
    return cmb
}

@private add_items2 :: proc(cmb : ^ComboBox, items : ..any )
{
    for i in items {
        if value, is_str := i.(string) ; is_str { // Magic -- type assert
            append(&cmb.items, value)
            if cmb._isCreated {
                SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(value), LPARAM))
                // // free_all(context.temp_allocator)
            }
        } else {
            a_string := fmt.tprint(i)
            append(&cmb.items, a_string)
            if cmb._isCreated {
                SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(a_string), LPARAM))
                // // free_all(context.temp_allocator)
            }
        }
    }
}

@private additem_internal :: proc(cmb : ^ComboBox)
{
    for i in cmb.items {
        SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(i), LPARAM))
        // free_all(context.temp_allocator)
    }
}

@private check_mouse_leave :: proc(cmb: ^ComboBox) -> bool
{
    /* Since combo box is a combination of button, edit and list box...
     * we need to take extra care for handling mouse enter & leave messages.
     * So we are checking whether the current mouse pos is in our...
     * control rect or not. To do that check, we need to convert the mouse...
     * points into our window's client coordinate level. */
    pt : POINT
    GetCursorPos(&pt)
    ScreenToClient(cmb.parent.handle, &pt)
    res := cast(bool) PtInRect(&cmb._myrc, pt)

    /* Inverting the result because, PtInRect will return true if mouse is inside rect.
     * We just want the opposite of that. */
    return !res
}

@private cmb_before_creation :: proc(cmb : ^ComboBox)
{
    if cmb.comboStyle == .Lb_Combo {
        cmb._style |= CBS_DROPDOWNLIST
    } else {
        cmb._style |= CBS_DROPDOWN
    }

    /* We need to take special care about contril ID.
     * If this is the first time a combo is created, we can use...
     * global control ID. But if a combo is recreating, then...
     * we must use the old comb's control ID. */
    if cmb._recreateEnabled {
        cmb.controlID = cmb._oldCtlID

        // Collect the selected index if any
        cmb.selectedIndex = int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    } else {
        globalCtlID += 1
    	cmb.controlID = globalCtlID
    }

    // Set back color brush
    cmb._bkBrush = get_solid_brush(cmb.backColor)
}

@private cmb_after_creation :: proc(cmb : ^ComboBox)
{
	set_subclass(cmb, cmb_wnd_proc)
    // cmb._old_hwnd = cmb.handle
    cmb._oldCtlID = cmb.controlID
    cd : ComboData = get_combo_info(cmb)

    // Collecting child controls info
    if cmb._recreateEnabled {
        cmb._recreateEnabled = false
        update_combo_data(cmb.parent, cd)

        // If selected index was a valid number, set the selection again.
        if cmb.selectedIndex != -1 {
            SendMessage(cmb.handle, CB_SETCURSEL, WPARAM(i32(cmb.selectedIndex)), 0)
        }
    } else {
        collect_combo_data(cmb.parent, cd)
    }

    // Now, subclass the edit control.
    SetWindowSubclass(cd.editHwnd, edit_wnd_proc, cmb._editSubclsID, to_dwptr(cmb))
    cmb._editSubclsID += 1 // We don't want to use the same id again and again.

    if len(cmb.items) > 0 do additem_internal(cmb)

    if cmb.selectedIndex > -1 { // User wants to set the selected index.
        combo_set_selected_index(cmb, cmb.selectedIndex)
    }

    // Lastly, we need to collect the control rect for managing mouse enter & leave events
    set_rect(&cmb._myrc, i32(cmb.xpos), i32(cmb.ypos), i32(cmb.width + cmb.xpos), i32(cmb.height + cmb.ypos))
}

@private combo_property_setter :: proc(this: ^ComboBox, prop: ComboProps, value: $T)
{
    switch prop {
        case .Combo_Style: when T == DropDownStyle do combo_set_style(this, value)
        case .Visible_Item_Count: break
        case .Selected_Index: when T == int do combo_set_selected_index(this, value)
        case .Selected_Item: combo_set_selected_item(this, value)
    }
}

@private cmb_finalize :: proc(cmb: ^ComboBox, scid: UINT_PTR)
{
    RemoveWindowSubclass(cmb.handle, cmb_wnd_proc, scid)
    if !cmb._recreateEnabled
    {
        delete_gdi_object(cmb.font.handle)
        delete_gdi_object(cmb._bkBrush)
        delete(cmb.items)
        free(cmb)
    }
}

@private cmb_wnd_proc :: proc "fast" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
                                sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT
{
    context = global_context
    cmb := control_cast(ComboBox, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_PAINT :
            if cmb.onPaint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cmb.onPaint(cmb, &pea)
                EndPaint(hw, &ps)
                return 0
            }
        case WM_DESTROY: cmb_finalize(cmb, sc_id)

        case WM_CONTEXTMENU:
		    if cmb.contextMenu != nil do contextmenu_show(cmb.contextMenu, lp)

        case CM_CTLCOMMAND :
            ncode := HIWORD(wp)
           // ptf("WM_COMMAND notification code - %d\n", ncode)
            switch ncode {
                case CBN_SELCHANGE :
                    if cmb.onSelectionChanged != nil {
                        ea := new_event_args()
                        cmb.onSelectionChanged(cmb, &ea)
                    }
                case CBN_DBLCLK :

                case CBN_SETFOCUS :
                    if cmb.onGotFocus != nil {
                        ea := new_event_args()
                        cmb.onGotFocus(cmb, &ea)
                    }
                case CBN_KILLFOCUS :
                    if cmb.onLostFocus != nil {
                        ea := new_event_args()
                        cmb.onLostFocus(cmb, &ea)
                    }
                case CBN_EDITCHANGE :
                    if cmb.onTextChanged != nil {
                        ea := new_event_args()
                        cmb.onTextChanged(cmb, &ea)
                    }
                case CBN_EDITUPDATE :
                     if cmb.onTextUpdated != nil {
                        ea := new_event_args()
                        cmb.onTextUpdated(cmb, &ea)
                    }
                case CBN_DROPDOWN :
                    if cmb.onListOpened != nil {
                        ea := new_event_args()
                        cmb.onListOpened(cmb, &ea)
                    }
                case CBN_CLOSEUP :
                    if cmb.onListClosed != nil {
                        ea := new_event_args()
                        cmb.onListClosed(cmb, &ea)
                    }
                case CBN_SELENDOK :
                    if cmb.onSelectionCommitted != nil {
                        ea := new_event_args()
                        cmb.onSelectionCommitted(cmb, &ea)
                    }
                case CBN_SELENDCANCEL :
                    if cmb.onSelectionCancelled != nil {
                        ea := new_event_args()
                        cmb.onSelectionCancelled(cmb, &ea)
                    }

            }

        case CM_COMBOLBCOLOR :
            //print("color combo list box")
            if cmb.foreColor != def_fore_clr || cmb.backColor != def_back_clr {
                //print("combo color rcvd")
                dc_handle := dir_cast(wp, HDC)
                api.SetBkMode(dc_handle, api.BKMODE.TRANSPARENT)
                if cmb.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(cmb.foreColor))
                if cmb._bkBrush == nil do cmb._bkBrush = CreateSolidBrush(get_color_ref(cmb.backColor))
                return toLRES(cmb._bkBrush)
            } else {
                if cmb._bkBrush == nil do cmb._bkBrush = CreateSolidBrush(get_color_ref(cmb.backColor))
                return toLRES(cmb._bkBrush)
            }

        case WM_PARENTNOTIFY :
            wp_lw := LOWORD(wp)
            switch wp_lw {
                case 512 :  // WM_MOUSEFIRST
                    if cmb.onTBMouseEnter != nil {
                        ea := new_event_args()
                        cmb.onTBMouseEnter(cmb, &ea)
                    }
                case 513 : // WM_LBUTTONDOWN
                    if cmb.onTBClick != nil {
                        ea := new_event_args()
                        cmb.onTBClick(cmb, &ea)
                    }
                case 675 : // WM_MOUSELEAVE
                    if cmb.onTBMouseLeave != nil {
                        ea := new_event_args()
                        cmb.onTBMouseLeave(cmb, &ea)
                    }
            }

        case WM_LBUTTONDOWN:  // Only work in lb_comb and the triange btn of tb_combo            
            if cmb.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onMouseDown(cmb, &mea)
                return 0
            }

        case WM_LBUTTONUP :  // Only work in lb_comb and the triange btn of tb_combo
            if cmb.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onMouseUp(cmb, &mea)
            }
            if cmb.onClick != nil {
                ea := new_event_args()
                cmb.onClick(cmb, &ea)
                return 0
            }            

         case WM_RBUTTONDOWN: // Only work in lb_comb and the triange btn of tb_combo            
            if cmb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onRightMouseDown(cmb, &mea)
            }

        case WM_RBUTTONUP :
            if cmb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onRightMouseUp(cmb, &mea)
            }
            if cmb.onRightClick != nil {
                ea := new_event_args()
                cmb.onRightClick(cmb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if cmb.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onMouseScroll(cmb, &mea)
            }
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if cmb._isMouseEntered {
                if cmb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    cmb.onMouseMove(cmb, &mea)
                }
            } else {
                cmb._isMouseEntered = true
                if cmb.onMouseEnter != nil  {
                    ea := new_event_args()
                    cmb.onMouseEnter(cmb, &ea)
                }
            }

        case WM_MOUSELEAVE : // Main Proc
            if cmb.onMouseLeave != nil || cmb.onMouseEnter != nil || cmb.onMouseMove != nil {
                if check_mouse_leave(cmb) {
                    cmb._isMouseEntered = false
                    if cmb.onMouseLeave != nil {
                        ea := new_event_args()
                        cmb.onMouseLeave(cmb, &ea)
                    }
                }
            }
    }
    return DefSubclassProc(hw, msg, wp, lp)
}


@private edit_wnd_proc :: proc "fast" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
                                sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT
{
    context = runtime.default_context()
    cmb := control_cast(ComboBox, ref_data)
    switch msg {
        case WM_DESTROY: RemoveWindowSubclass(hw, edit_wnd_proc, sc_id)

        case CM_CTLLCOLOR :
            if cmb.foreColor != def_fore_clr || cmb.backColor != def_back_clr {
                dc_handle := dir_cast(wp, HDC)
                // SetBkMode(dc_handle, Transparent)
                if cmb.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(cmb.foreColor))
                if cmb.backColor != def_back_clr do SetBackColor(dc_handle, get_color_ref(cmb.backColor))
                return toLRES(cmb._bkBrush)
            }

        case WM_KEYDOWN : // only works in Tb_combo style
            if cmb.onKeyDown != nil {
                kea := new_key_event_args(wp)
                cmb.onKeyDown(cmb, &kea)
            }

        case WM_KEYUP : // only works in Tb_combo style
            if cmb.onKeyUp != nil {
                kea := new_key_event_args(wp)
                cmb.onKeyUp(cmb, &kea)
            }

        case WM_LBUTTONDOWN:  // Only work in lb_comb and the triange btn of tb_combo             
            if cmb.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onMouseDown(cmb, &mea)
                return 0
            }

        case WM_LBUTTONUP :  // Only work in lb_comb and the triange btn of tb_combo
            if cmb.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onMouseUp(cmb, &mea)
            }
            if cmb.onClick != nil {
                ea := new_event_args()
                cmb.onClick(cmb, &ea)
                return 0
            }
      
        case WM_RBUTTONDOWN: // Only work in lb_comb and the triange btn of tb_combo
            cmb._mRDownHappened = true
            if cmb.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onRightMouseDown(cmb, &mea)
            }

        case WM_RBUTTONUP :
            if cmb.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cmb.onRightMouseUp(cmb, &mea)
            } 
            if cmb.onRightClick != nil {
                ea := new_event_args()
                cmb.onRightClick(cmb, &ea)
                return 0
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if cmb._isMouseEntered {
                if cmb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    cmb.onMouseMove(cmb, &mea)
                }
            } else {
                cmb._isMouseEntered = true
                if cmb.onMouseEnter != nil  {
                    ea := new_event_args()
                    cmb.onMouseEnter(cmb, &ea)
                }
            }

        case WM_MOUSELEAVE : // Edit Proc
            if cmb.comboStyle == .Tb_Combo && (cmb.onMouseLeave != nil || cmb.onMouseEnter != nil || cmb.onMouseMove != nil) {
                if check_mouse_leave(cmb) {
                    cmb._isMouseEntered = false
                    if cmb.onMouseLeave != nil {
                        ea := new_event_args()
                        cmb.onMouseLeave(cmb, &ea)
                    }
                }
            }
    }
    return DefSubclassProc(hw, msg, wp, lp)
}
