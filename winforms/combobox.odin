
/*===========================================ComboBox Docs=========================================================
    ComboBox struct
        Constructor: new_comboBox() -> ^ComboBox
        Properties:
            All props from Control struct
            comboStyle         : DropDownStyle enum
            items              : [dynamic]string
            visibleItemCount   : int
            selectedIndex      : int
            selectedItem       : string
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
import "core:time"


wcnCombo:= L("ComboBox")



ComboBox:: struct
{
    using control: Control,
    comboStyle: DropDownStyle,
    items: [dynamic]string, // Don't forget to delete it when combo box deing destroyed.
    visibleItemCount: int,
    selectedIndex: int,
    selectedItem: string,
    _recreateEnabled: bool, // Used when we need to recreate existing combo
    _dropped: bool, // Used for tracking whether combo's list is dropped or not.
    _meFired: bool, // Used for avoiding firing mouse leave event when combo's dropdown list is opening.
    _bkBrush: HBRUSH,
    _oldCtlID: UINT,
    _editSubclsID: UINT_PTR,
    // _mouseFlag : i32, // General mouse message processing flag
    // _mst : MouseTrackData,
    _cmbRect: RECT, // Used for mouse tracking
    // _editHwnd: HWND,
    // _listHwnd: HWND,
    // _mstInfo: MouseTrackingInfo,
    // _tmr : ^Timer,


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
    onTBMouseEnter: EventHandler,
}

MouseTrackData:: struct
{
    cmbEnter: bool,
    editEnter: bool,
    editLeave: bool,
    cmbLeave: bool,
}

// Create new ComboBox
new_combobox:: proc{new_combo1, new_combo2, new_combo3}

// Show combo's dropdown list
combo_open_list:: proc(cmb: ^ComboBox) { SendMessage(cmb.handle, CB_SHOWDROPDOWN, WPARAM(1), 0) }

// Close combo's dropdown list
combo_close_list:: proc(cmb: ^ComboBox) { SendMessage(cmb.handle, CB_SHOWDROPDOWN, WPARAM(0), 0) }

// Add an item to combo.
combo_add_item:: proc(cmb: ^ComboBox, item: $T )
{
    sitem: string
    when T == string {
        sitem = item
    } else {
        sitem:= fmt.tprint(an_item)
    }
    append(&cmb.items, sitem)
    if cmb._isCreated {
        SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(sitem), LPARAM))
        // free_all(context.temp_allocator)
    }
}

// Add items to combo in bulk
combo_add_items:: proc{add_items2}

// Add an array to combo box
combo_add_array:: proc(cmb: ^ComboBox, items: []$T )
{
    //print("called once")
    when T == string {
        for i in items {
            append(&cmb.items, i)
        }
    } else {
        for i in items {
            a_string:= fmt.tprint(i)
            append(&cmb.items, a_string)
        }
    }
    // IMPORTANT - add code for update combo items
}

// Get the selected index number
combo_get_selected_index:: proc(cmb: ^ComboBox) -> int
{
    cmb.selectedIndex = int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    return cmb.selectedIndex
}

// Set the item in given index as selected item
combo_set_selected_index:: proc(cmb: ^ComboBox, indx: int)
{
    SendMessage(cmb.handle, CB_SETCURSEL, WPARAM(i32(indx)), 0)
    cmb.selectedIndex = indx
}

// Set the given item as selected item
combo_set_selected_item:: proc(cmb: ^ComboBox, item: $T)
{
    sitem:= fmt.tprint(item)
    wp: i32 = -1
    indx:= cast(i32) SendMessage(cmb.handle, CB_FINDSTRINGEXACT, WPARAM(wp), dir_cast(to_wstring(sitem), LPARAM))
    if indx == LB_ERR do return
    SendMessage(cmb.handle, CB_SETCURSEL, WPARAM(indx), 0)
    cmb.selectedIndex = int(indx)
    cmb.selectedItem = sitem
    // free_all(context.temp_allocator)
}

// Get the selected item
combo_get_selected_item:: proc(cmb: ^ComboBox) -> any
{
    indx:= int(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        return cmb.items[indx]
    } else do return ""
}

// Delete the selected item
combo_delete_selected_item:: proc(cmb: ^ComboBox)
{
    indx:= i32(SendMessage(cmb.handle, CB_GETCURSEL, 0, 0))
    if indx > -1 {
        SendMessage(cmb.handle, CB_DELETESTRING, WPARAM(indx), 0)
        ordered_remove(&cmb.items, int(indx))
    }
}

// Delete the item in given index
combo_delete_item:: proc(cmb: ^ComboBox, indx: int)
{
    SendMessage(cmb.handle, CB_DELETESTRING, dir_cast(i32(indx), WPARAM), 0)
    ordered_remove(&cmb.items, indx)
}

// Clear all items from combo
combo_clear_items:: proc(cmb: ^ComboBox)
{
    SendMessage(cmb.handle, CB_DELETESTRING, 0, 0)
    // TODO - clear dynamic array of combo.
}

// Set combo box's drop down style
combo_set_style:: proc(cmb: ^ComboBox, style: DropDownStyle)
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
@private ComboData:: struct
{
    listBoxHwnd: HWND,
    comboHwnd: HWND,
    editHwnd: HWND,
    comboID: u32,
}

@private new_combo_data:: proc(cbi: COMBOBOXINFO, id: u32) -> ComboData
{
    cd: ComboData
    cd.comboHwnd = cbi.hwndCombo
    cd.comboID = id
    cd.editHwnd = cbi.hwndItem
    cd.listBoxHwnd = cbi.hwndList
    return cd
}

@private get_combo_info:: proc(cmb: ^ComboBox) -> ComboData
{
    // Collect the data from Combobox control.
    cmInfo: COMBOBOXINFO
    cmInfo.cbSize = size_of(cmInfo)
    SendMessage(cmb.handle, CB_GETCOMBOBOXINFO, 0, dir_cast(&cmInfo, LPARAM))
    cd:= new_combo_data(cmInfo, cmb.controlID)
    return cd
}

@private cmb_ctor:: proc(p: ^Form, w: int = 130, h: int = 30, x: int = 10, y: int = 10) -> ^ComboBox
{
    // if wcnCombo == nil do wcnCombo = to_wstring("ComboBox")
    cmb:= new(ComboBox)
    init_control(cmb, p, x, y, w, h, .Combo_Box, COMM_CTRL_STYLES | CBS_DROPDOWN, 
                    WS_EX_CLIENTEDGE, wcnCombo, NO_TXT, FONTABLE)
    cmb.backColor = app.clrWhite
    cmb.foreColor = app.clrBlack
    cmb.selectedIndex = -1
    cmb.comboStyle = DropDownStyle.Lb_Combo
    cmb._fp_beforeCreation = cast(CreateDelegate) cmb_before_creation
	cmb._fp_afterCreation = cast(CreateDelegate) cmb_after_creation
    cmb._spMLeaveProc = cmb_mouse_leave_handler
    
    return cmb
}

@private new_combo1:: proc(parent: ^Form) -> ^ComboBox
{
    cmb:= cmb_ctor(parent)
    if parent.createChilds do create_control(cmb)
    return cmb
}

@private new_combo2:: proc(parent: ^Form, x, y: int, 
                            cmbStyle: DropDownStyle = DropDownStyle.Lb_Combo ) -> ^ComboBox
{
    cmb:= cmb_ctor(parent, x = x, y= y)
    cmb.comboStyle = cmbStyle
    if parent.createChilds do create_control(cmb)
    return cmb
}

@private new_combo3:: proc(parent: ^Form, x, y, w, h: int,
                            cmbStyle: DropDownStyle = DropDownStyle.Lb_Combo ) -> ^ComboBox
{
    cmb:= cmb_ctor(parent, w, h, x, y)
    cmb.comboStyle = cmbStyle
    if parent.createChilds do create_control(cmb)
    return cmb
}

@private add_items2:: proc(cmb: ^ComboBox, items: ..any )
{
    for i in items {
        if value, is_str:= i.(string) ; is_str { // Magic -- type assert
            append(&cmb.items, value)
            if cmb._isCreated {
                SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(value), LPARAM))
                // // free_all(context.temp_allocator)
            }
        } else {
            a_string:= fmt.tprint(i)
            append(&cmb.items, a_string)
            if cmb._isCreated {
                SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(a_string), LPARAM))
                // // free_all(context.temp_allocator)
            }
        }
    }
}

@private additem_internal:: proc(cmb: ^ComboBox)
{
    for i in cmb.items {
        SendMessage(cmb.handle, CB_ADDSTRING, 0, dir_cast(to_wstring(i), LPARAM))
        // free_all(context.temp_allocator)
    }
}


@private cmb_before_creation:: proc(cmb: ^ComboBox)
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

@private cmb_after_creation:: proc(cmb: ^ComboBox)
{
	set_subclass(cmb, cmb_wnd_proc)
    cmb._oldCtlID = cmb.controlID
    cd: ComboData = get_combo_info(cmb)
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
    api.SetWindowSubclass(cd.editHwnd, edit_wnd_proc, cmb._editSubclsID, to_dwptr(cmb))
    cmb._editSubclsID += 1 // We don't want to use the same id again and again.

    if len(cmb.items) > 0 do additem_internal(cmb)

    if cmb.selectedIndex > -1 { // User wants to set the selected index.
        combo_set_selected_index(cmb, cmb.selectedIndex)
    }

    // Lastly, we need to collect the control rect for managing mouse enter & leave events
    GetClientRect(cmb.handle, &cmb._cmbRect)      
}

@private cmb_mouse_leave_handler :: proc(ctl: ^Control) -> MsgHandlerReturn
{
    if ctl.onMouseLeave != nil || ctl.onMouseEnter != nil || ctl.onMouseMove != nil {
        this := cast(^ComboBox) ctl
        pt : POINT = {}
        GetCursorPos(&pt)
        ScreenToClient(this.handle, &pt)        
        inside := PtInRect(&this._cmbRect, pt)
        if inside {        
            return .Immediate_Return
        } else {
            this._isMouseEntered = false
            this._isMouseTracking = false
            if this.onMouseLeave != nil do this.onMouseLeave(this, &gea)
        }
    }
    return .Call_Def_Proc    
}

@private combo_property_setter:: proc(this: ^ComboBox, prop: ComboProps, value: $T)
{
    switch prop {
        case .Combo_Style: when T == DropDownStyle do combo_set_style(this, value)
        case .Visible_Item_Count: break
        case .Selected_Index: when T == int do combo_set_selected_index(this, value)
        case .Selected_Item: combo_set_selected_item(this, value)
    }
}

@private cmb_finalize:: proc(this: ^ComboBox, scid: UINT_PTR)
{
    RemoveWindowSubclass(this.handle, cmb_wnd_proc, scid)
    if !this._recreateEnabled
    {
        delete_gdi_object(this._bkBrush)
        font_destroy(&this.font)
        delete(this.items)
        free(this)
    }
}

@private cmb_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context
    // context = runtime.default_context()
    
    //display_msg(msg)
    cmb:= control_cast(ComboBox, ref_data)
    res := ctrl_common_msg_handler(cmb, hw, msg, wp, lp) 
    #partial switch res {
        case .Call_Def_Proc: return DefSubclassProc(hw, msg, wp, lp)
        case .Immediate_Return: return 1
    }
   
    switch msg {
        case WM_PAINT:            
            if cmb.onPaint != nil {
                ps: PAINTSTRUCT
                hdc:= BeginPaint(hw, &ps)
                pea:= new_paint_event_args(&ps)
                cmb.onPaint(cmb, &pea)
                EndPaint(hw, &ps)
                return 0
            }
        case WM_DESTROY: 
            cmb_finalize(cmb, sc_id)

        case CM_CTLCOMMAND:
            ncode:= HIWORD(wp)
           // ptf("WM_COMMAND notification code - %d\n", ncode)
            switch ncode {
                case CBN_SELCHANGE:
                    if cmb.onSelectionChanged != nil do cmb.onSelectionChanged(cmb, &gea)

                case CBN_DBLCLK:

                case CBN_SETFOCUS:
                    if cmb.onGotFocus != nil do cmb.onGotFocus(cmb, &gea)
                    
                case CBN_KILLFOCUS:
                    if cmb.onLostFocus != nil do cmb.onLostFocus(cmb, &gea)
    
                case CBN_EDITCHANGE:
                    if cmb.onTextChanged != nil do cmb.onTextChanged(cmb, &gea)
                
                case CBN_EDITUPDATE:
                     if cmb.onTextUpdated != nil do  cmb.onTextUpdated(cmb, &gea)
                    
                case CBN_DROPDOWN:
                    cmb._dropped = true
                    if cmb.onListOpened != nil do cmb.onListOpened(cmb, &gea)
                
                case CBN_CLOSEUP:
                    /* When user selects an item from the dropdown list, Windows 
                        will capture the mouse and proceeding with the list that
                        contains the combo box items. So we don't get the mouse leave
                        event from the combo box. So we need to track when the list is
                        opening. This bool flag is used to indicate the dropdown state. */
				    cmb._dropped = false
                    if cmb.onListClosed != nil do cmb.onListClosed(cmb, &gea)

                case CBN_SELENDOK:
                    cmb._isMouseTracking = false
                    if cmb.onSelectionCommitted != nil do cmb.onSelectionCommitted(cmb, &gea)

                case CBN_SELENDCANCEL:
                    if cmb.onSelectionCancelled != nil do cmb.onSelectionCancelled(cmb, &gea)

            }

        case CM_COMBOLBCOLOR:
            //print("color combo list box")
            if cmb.foreColor != def_fore_clr || cmb.backColor != def_back_clr {
                //print("combo color rcvd")
                dc_handle:= dir_cast(wp, HDC)
                api.SetBkMode(dc_handle, api.BKMODE.TRANSPARENT)
                if cmb.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(cmb.foreColor))
                if cmb._bkBrush == nil do cmb._bkBrush = CreateSolidBrush(get_color_ref(cmb.backColor))
                return toLRES(cmb._bkBrush)
            } else {
                if cmb._bkBrush == nil do cmb._bkBrush = CreateSolidBrush(get_color_ref(cmb.backColor))
                return toLRES(cmb._bkBrush)
            }

        case WM_PARENTNOTIFY:
            wp_lw:= LOWORD(wp)
            switch wp_lw {
            case 512:  // WM_MOUSEFIRST
                if cmb.onTBMouseEnter != nil {
                    ea:= new_event_args()
                    cmb.onTBMouseEnter(cmb, &ea)
                }
            case 513: // WM_LBUTTONDOWN
                if cmb.onTBClick != nil {
                    ea:= new_event_args()
                    cmb.onTBClick(cmb, &ea)
                }
            case 675: // WM_MOUSELEAVE
                if cmb.onTBMouseLeave != nil {
                    ea:= new_event_args()
                    cmb.onTBMouseLeave(cmb, &ea)
                }
            }

    }
    return DefSubclassProc(hw, msg, wp, lp)
}


@private edit_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = runtime.default_context()
    cmb:= control_cast(ComboBox, ref_data)
    res := ctrl_common_msg_handler(cmb, hw, msg, wp, lp) 
    #partial switch res {
        case .Call_Def_Proc: return DefSubclassProc(hw, msg, wp, lp)
        case .Immediate_Return: return 1
    }
    switch msg {
        case WM_DESTROY: RemoveWindowSubclass(hw, edit_wnd_proc, sc_id)

        case CM_EDIT_COLOR:
            if cmb.foreColor != def_fore_clr || cmb.backColor != def_back_clr {
                dc_handle:= dir_cast(wp, HDC)
                // SetBkMode(dc_handle, Transparent)
                if cmb.foreColor != def_fore_clr do SetTextColor(dc_handle, get_color_ref(cmb.foreColor))
                if cmb.backColor != def_back_clr do SetBkColor(dc_handle, get_color_ref(cmb.backColor))
                return toLRES(cmb._bkBrush)
            }

        case WM_KEYDOWN: // only works in Tb_combo style
            if cmb.onKeyDown != nil {
                kea:= new_key_event_args(wp)
                cmb.onKeyDown(cmb, &kea)
            }

        case WM_KEYUP: // only works in Tb_combo style
            if cmb.onKeyUp != nil {
                kea:= new_key_event_args(wp)
                cmb.onKeyUp(cmb, &kea)
            }

        
    }
    return DefSubclassProc(hw, msg, wp, lp)
}
