// Created on 13-Nov-2023 06:13 PM
// Menu related features
package winforms

import api "core:sys/windows"

// import "core:time"
// Constants
    MF_POPUP :: 0x00000010
    MF_STRING :: 0x00000000
    MF_SEPARATOR :: 0x00000800
    MF_CHECKED :: 0x00000008
    MNS_NOTIFYBYPOS :: 0x08000000

    MIM_STYLE :: 0x00000010
    TPM_LEFTBUTTON :: 0x0000
    TPM_RIGHTBUTTON :: 0x0002
    MF_OWNERDRAW :: 0x00000100

    MIIM_STATE :: 0x00000001
    MIIM_ID :: 0x00000002
    MIIM_SUBMENU :: 0x00000004
    MIIM_CHECKMARKS :: 0x00000008
    MIIM_TYPE :: 0x00000010
    MIIM_DATA :: 0x00000020
    MIIM_STRING :: 0x00000040
    MIIM_BITMAP :: 0x00000080
    MIIM_FTYPE :: 0x00000100
    MIM_MENUDATA :: 0x00000008

    MF_INSERT :: 0x00000000
    MF_CHANGE :: 0x00000080
    MF_APPEND :: 0x00000100
    MF_DELETE :: 0x00000200
    MF_REMOVE :: 0x00001000
    MF_BYCOMMAND :: 0x00000000
    MF_BYPOSITION :: 0x00000400
    MF_ENABLED :: 0x00000000
    MF_GRAYED :: 0x00000001
    MF_DISABLED :: 0x00000002
    MF_UNCHECKED :: 0x00000000

    MF_USECHECKBITMAPS :: 0x00000200
    MF_BITMAP :: 0x00000004
    MF_MENUBARBREAK :: 0x00000020
    MF_MENUBREAK :: 0x00000040
    MF_UNHILITE :: 0x00000000
    MF_HILITE :: 0x00000080
    MF_DEFAULT :: 0x00001000
    MF_SYSMENU :: 0x00002000
    MF_HELP :: 0x00004000
    MF_RIGHTJUSTIFY :: 0x00004000
    MF_MOUSESELECT :: 0x00008000
    MF_END :: 0x00000080
    HWND_MESSAGE :: HWND(cast(UINT_PTR)(U64MAX - 3) + 1)
// End Constants

MenuType :: enum {Base_Menu, Menu_Item, Popup, Context_Menu, Seprator}

TPM_RETURNCMD :: 0x0100
TPM_FLAG :: TPM_LEFTBUTTON | TPM_RETURNCMD

menuNumber : uint = 101
bf : i32 = 0
bt : i32 = 1
bfalse : BOOL = cast(BOOL)bf
btrue : BOOL = cast(BOOL)bt
cmenuMsgWinCreated : bool = false
cmenuClass := []WCHAR {'W', 'i', 'n', 'f', 'o', 'r', 'm', 's', '_', 'C', 'm', 'e', 'n', 'u', 0}

MenuBase :: struct
{
    handle: HMENU,
    font: Font,
    menus : [dynamic]^MenuItem,
    _menuCount: uint,
}

MenuBar :: struct
{
    using _base: MenuBase,
    _pForm: ^Form,
    _menuGrayCref: COLORREF,
    _menuDefBgBrush,
    _menuHotBgBrush,
    _menuFrameBrush,
    _menuGrayBrush : HBRUSH,
}

MenuItem :: struct
{
    using _base: MenuBase,
	parentHandle : HMENU,
	bgColor: Color,
	fgColor: Color,
	idNum : uint,
    text: string,
	kind: MenuType,
    hasCheckMark : bool,

    _wideText: LPCWSTR,
	_index : uint,
	_evtFlag : uint,
    _uFlag: uint,
	_iLevel: int,
	_isCreated : bool,
	_isEnabled : bool,
	_popup : bool,
	_formMenu : bool,
    _formHwnd: HWND,
	_parent: ^MenuItem,
    _menubar: ^MenuBar,

    // Events
	onClick, onPopup, onCloseup, onFocus: MenuEventHandler,
}

ContextMenu :: struct {
    using _base: MenuBase,
    parent : ^Control,
    tray : ^TrayIcon,
    width, height : int,

    _dummyHwnd : HWND,
    _selTxtClr, _grayCref : COLORREF,
    _rightClick, _menuInserted, _hasTrayParent : bool,
    _defBgBrush, _hotBgBrush, _borderBrush, _grayBrush: HBRUSH,

    onMenuShown, onMenuClose : ContextMenuEventHandler,
    onTrayMenuShown, onTrayMenuClose: TrayIconEventHandler,
}

MenuEvents :: enum {On_Click, On_Popup, On_Closeup, On_Focus}

new_menubar :: proc{menubar_ctor1, menubar_ctor2}

@private menubar_ctor :: proc(frm: ^Form) -> ^MenuBar
{
    this := new(MenuBar)
    this.handle = CreateMenu()
    this._pForm = frm
    this.font = new_font("Tahoma", 11)
    this._menuGrayBrush = get_solid_brush(0xced4da)
    this._menuGrayCref = get_color_ref(0x979dac)
    this._pForm.menubar = this
    // this.menus = make(map[string]^MenuItem)
    this._pForm._menuItemMap = make(map[uint]^MenuItem)
    this._pForm._menubarUsed = true
    // ptf("MenuBar handle %d\n", this.handle)
    return this
}

@private menubar_ctor1 :: proc(frm : ^Form) -> ^MenuBar
{
    return menubar_ctor(frm)
}

@private menubar_ctor2 :: proc(frm : ^Form, menuitems: ..string) -> ^MenuBar
{
    this := menubar_ctor(frm)
    menubar_additems1(this, ..menuitems)
    return this
}

new_menuitem :: proc{menuitem_ctor}

@private menuitem_ctor :: proc(menutxt: string, mtyp: MenuType, pHandle: HMENU, indexNum: uint) -> ^MenuItem
{
    this:= new(MenuItem)
    this._popup = mtyp == .Base_Menu || mtyp == .Popup ? true : false
    this.handle = this._popup ? CreatePopupMenu() : CreateMenu()
    this._index = indexNum
    this.idNum = menuNumber
    this.text = menutxt
    this._wideText = to_wstring(this.text, context.allocator)
    this.kind = mtyp
    this.parentHandle = pHandle
    this.bgColor = new_color(0xe9ecef)
    this.fgColor = new_color(0x000000)
    this._isEnabled = true
    menuNumber += 1
    // ptf("Menu item handle %d\n", this.handle)

	return this
}

// Add single item to menubar.
menubar_add_item :: proc{ menubar_additem1, menubar_additem2}

menubar_additem1 :: proc(this: ^MenuBar, menuTxt: string, txtColor: uint = 0x000000) -> ^MenuItem
{
    mi := new_menuitem(menuTxt, MenuType.Base_Menu, this.handle, this._menuCount )
    mi._formHwnd = this._pForm.handle
    mi.fgColor = new_color(txtColor)
    mi._formMenu = true
    this._menuCount += 1
    append(&this.menus, mi)
    this._pForm._menuItemMap[mi.idNum] = mi
    return mi
}

menubar_additem2 :: proc(this: ^MenuBar, menuTxt: string, parent: ^MenuItem, txtColor: uint = 0x000000) -> ^MenuItem
{
    mi := new_menuitem(menuTxt, MenuType.Menu_Item, parent.handle, parent._menuCount )
    mi._formHwnd = parent._formHwnd
    mi.fgColor = new_color(txtColor)
    mi._formMenu = true
    parent._menuCount += 1
    append(&parent.menus, mi)
    this._pForm._menuItemMap[mi.idNum] = mi
    return mi
}

// Add more than one menu items to parent menu.
menubar_add_items :: proc{menubar_additems1, menubar_additems2, menubar_additems3}

// Create more than one base menus in this MenuBar.
@private menubar_additems1 :: proc(this: ^MenuBar, menuTxts: ..string)
{
    for item in menuTxts {
        mi := new_menuitem(item, MenuType.Base_Menu, this.handle, this._menuCount )
        mi._formHwnd = this._pForm.handle
        mi._formMenu = true
        this._menuCount += 1
        // this.menus[item] = mi
        append(&this.menus, mi)
        this._pForm._menuItemMap[mi.idNum] = mi
    }
}


@private menubar_additems2 :: proc(this: ^MenuBar, parentIndex: int, menu_txts: ..string)
{
    if len(this.menus) > 0 {
        parent := this.menus[parentIndex]
        add_multi_childs(parent, this, ..menu_txts)
    }
}

@private menubar_additems3 :: proc(this: ^MenuBar, parentMenu: ^MenuItem, menu_txts: ..string)
{
    add_multi_childs(parentMenu, this, ..menu_txts)
}


@private add_multi_childs :: proc(this: ^MenuItem, mbar: ^MenuBar, childMenuNames: ..string)
{
    for item in childMenuNames {
        mi := new_menuitem(item, MenuType.Menu_Item, this.handle, this._menuCount )
        mi._formHwnd = this._formHwnd
        mi._formMenu = true
        this._menuCount += 1
        append(&this.menus, mi)
        mbar._pForm._menuItemMap[mi.idNum] = mi
    }
}

// Find a child menu with given name and create child menus in it.
// menubar_additems3 :: proc(this: ^MenuBar, parentName: string, newSubmenu: string, childMenuNames: []string)

// This will get called right before the form first appeared on the screen.
@private menubar_create_handle :: proc(this: ^MenuBar)
{
    this._menuDefBgBrush = get_solid_brush(0xe9ecef)
    this._menuHotBgBrush = get_solid_brush(0x90e0ef)
    this._menuFrameBrush = get_solid_brush(0x0077b6)
	if (this.font.handle == nil)  do CreateFont_handle(&this.font)

    // If there are menus, we need to create the handles for them too.
    if this._menuCount > 0 {
		for menu in this.menus {
            menuitem_create_handle(menu)
        }
	}
    SetMenu(this._pForm.handle, this.handle)
}

@private insert_menu_internal :: proc(mi: ^MenuItem, parent: HMENU)
{
	mii : MENUITEMINFO
    mii.cbSize = size_of(mii)
    mii.fMask = MIIM_ID | MIIM_TYPE | MIIM_DATA | MIIM_SUBMENU | MIIM_STATE
    mii.fType = MF_OWNERDRAW
    mii.dwTypeData = mi._wideText
    mii.cch = auto_cast(len(mi.text))
    mii.dwItemData = dir_cast(rawptr(mi), ULONG_PTR)
    mii.wID = auto_cast(mi.idNum)
    mii.hSubMenu = mi._popup ? mi.handle : nil
    x:= InsertMenuItem(parent, mi.idNum, btrue, &mii)
    mi._isCreated = true
    // ptf("257: Parent handle %d, child name : %s, child handle : %d\n", parent, mi.text, mi.handle)
}

@private menuitem_create_handle :: proc(mi: ^MenuItem)
{
    switch mi.kind {
        case .Base_Menu, .Popup:
            if len(mi.menus) > 0 {
                for menu in mi.menus {
                    // ptf("265: menu item name %s\n", menu.text)
                    menuitem_create_handle(menu)
                }
            }
            insert_menu_internal(mi, mi.parentHandle)
        case .Menu_Item: insert_menu_internal(mi, mi.parentHandle)
        case .Seprator: api.AppendMenuW(mi.parentHandle, MF_SEPARATOR, 0, nil)
        case .Context_Menu: break
    }
}

@private find_parentmenu :: proc(frm: ^Form, parentTxt: string) -> (okay: bool, result: ^MenuItem)
{
    result = nil
    okay = false
    for _, mi in frm._menuItemMap {
        if mi.text == parentTxt {
            result = mi
            okay = true
            break
        }
    }
    return okay, result
}

@private get_child_menu_from_id :: proc(mi: ^MenuItem, index: uint) -> (bool, ^MenuItem)
{
    if mi._menuCount > 0 {
        for menu in mi.menus {
            if menu.idNum == index do return true, menu
        }
    }
    return false, nil
}

// Get the menu item with given name.
menubar_get_item :: proc{ menubar_getitem1, menubar_getitem2 }

@private menubar_getitem1 :: proc(this: ^MenuBar, menu_text: string) -> (^MenuItem, bool)
{
    if len(this._pForm._menuItemMap) > 0 {
        for _, menu in this._pForm._menuItemMap {
            if menu.text == menu_text do return menu, true
        }
    }
    return nil, false
}

// You can pass the menu structure like this - "File", "New File", "Start"
// This will finf the Start menu under 'New File' which is a child of 'File'
@private menubar_getitem2 :: proc(this: ^MenuBar, menu_name: string, parent_name: string) -> (^MenuItem, bool)
{
    if len(this.menus) == 0 do return nil, false
    menuList : [dynamic]^MenuItem
    for _, menu in this._pForm._menuItemMap {
        if menu.text == menu_name do append(&menuList, menu)
    }
    switch len(menuList) {
        case 0: return nil, false
        case 1: return menuList[0], true
        case :
            if len(parent_name) > 0 {
                for menu in menuList {
                    if menu._parent.text == parent_name do return menu, true
                }
            }
    }
    return nil, false
}

@private find_child_menu :: proc(this: ^MenuItem, child_name: string) -> (^MenuItem, bool)
{
    if this.text == child_name do return this, true
    if len(this.menus) > 0 {
        for menu in this.menus do if menu.text == child_name do return menu, true
    }
    return nil, false
}



@private cmenu_ctor :: proc() -> ^ContextMenu
{
    this := new(ContextMenu)
    this.handle = CreatePopupMenu()
    this._rightClick = true
    this.width = 120
    this.height = 25
    this._defBgBrush = get_solid_brush(0xe9ecef)
    this._hotBgBrush = get_solid_brush(0x90e0ef)
    this._borderBrush = get_solid_brush(0x0077b6)
    this._grayBrush = get_solid_brush(0xced4da)
    this._grayCref = get_color_ref(0x979dac)
    if !cmenuMsgWinCreated do register_msgwindow()
    // create_message_only_window(this)
    return this
}

new_contextmenu :: proc{new_contextmenu1, new_contextmenu2}

@private new_contextmenu1 :: proc(parent: ^Control) -> ^ContextMenu
{
    this := cmenu_ctor()
    this.parent = parent
    this.font = parent.font
    return this
}

@private new_contextmenu2 :: proc() -> ^ContextMenu
{
    this := cmenu_ctor()
    this.font = new_font("Tahoma", 11)
    return this
}



control_add_contextmenu :: proc{add_contextmenu1, add_contextmenu2}

add_contextmenu1 :: proc(ctl: ^Control)
{
    cmenu := new_contextmenu(ctl)
    ctl.contextMenu = cmenu
    ctl._cmenuUsed = true
}

add_contextmenu2 :: proc(ctl: ^Control, cmenus: ..string)
{
    this := new_contextmenu(ctl)
    ctl.contextMenu = this
    ctl._cmenuUsed = true
    if len(cmenus) > 0 {
        for name in cmenus {
            mtyp : MenuType = name == "|" ? .Seprator : .Context_Menu
            mi := new_menuitem(name, mtyp, this.handle, this._menuCount)
            this._menuCount += 1
            append(&this.menus, mi)
        }
    }
}

// Adds single item to context menu
contextmenu_add_item :: proc(this: ^ContextMenu, item: string) -> ^MenuItem
{
    mtyp : MenuType = item == "|" ? .Seprator : .Context_Menu
    mi := new_menuitem(item, mtyp, this.handle, this._menuCount)
    this._menuCount += 1
    append(&this.menus, mi)
    return mi
}

// Adds multiple items to context menu
contextmenu_add_items :: proc(this: ^ContextMenu, items: ..string)
{
    for item in items {
        mtyp : MenuType = item == "|" ? .Seprator : .Context_Menu
        mi := new_menuitem(item, mtyp, this.handle, this._menuCount)
        this._menuCount += 1
        append(&this.menus, mi)
    }
}

// Removes a menu item from context menu. Pass either index or name
contextmenu_remove_item :: proc(this: ^ContextMenu, indexOrName: $T) -> bool
{
    res := false
    index := -1
    if len(this.menus) > 0 {
        for menu in this.menus {
            when T == int {
                if indexOrName >= 0 && indexOrName < len(this.menus) {
                    menu := this.menus[indexOrName]
                    res:= DeleteMenu(menu.handle, u32(menu.idNum), 0)
                    res = bool(res)
                    index = menu._index
                }
            } else when T == string {
                if menu.text == indexOrName {
                    res:= DeleteMenu(menu.handle, u32(menu.idNum), 0)
                    res = bool(res)
                    index = menu._index
                }
            }
            
        }
        if res && index > -1{
            ordered_remove(&this.menus, index)
        }
    }
    return res
}


// sw : time.Stopwatch
@private 
cmenu_insert_internal :: proc(this: ^MenuItem)
{
    if len(this.menus) > 0 {
        for menu in this.menus {cmenu_insert_internal(menu)}
    }
    if this.kind == .Context_Menu {         
        insert_menu_internal(this, this.parentHandle)
    } else if this.kind == .Seprator {
        api.AppendMenuW(this.handle, MF_SEPARATOR, 0, nil)
    }
}

// Creates all the menu items. This will get called automatically at the first usage.
// But you can call this explicitly after you added the last menu item.
// That will imrove the context menu opening speed.
cmenu_create_handle :: proc(this: ^ContextMenu)
{
    if len(this.menus) > 0 {
        for menu in this.menus {
            // time.stopwatch_start(&sw) 
            cmenu_insert_internal(menu)
            // time.stopwatch_stop(&sw)
            // ptf("menu insertion time %s", time.stopwatch_duration(sw))
            // time.stopwatch_reset(&sw)
        }
    }
    this._menuInserted = true
}

@private register_msgwindow :: proc()
{
    wc : WNDCLASSEXW 
    wc.cbSize = size_of(wc)
    wc.lpfnWndProc = cmenu_wndproc
    wc.hInstance = app.hInstance
    wc.lpszClassName = &cmenuClass[0]
    RegisterClassEx(&wc)
    cmenuMsgWinCreated = true
}

// Creating message-only window to handle context menu messages
@private create_message_only_window :: proc(this: ^ContextMenu)
{
    this._dummyHwnd = CreateWindowEx(0, &cmenuClass[0], nil, 0, 0, 0, 0, 0, HWND_MESSAGE, nil, app.hInstance, nil)
    SetWindowLongPtr(this._dummyHwnd, GWLP_USERDATA, cast(LONG_PTR) cast(UINT_PTR) this)
    if this.font.handle == nil do CreateFont_handle(&this.font)
}


// Display context menu on right click or short key press.
// Both TrayIcon and Control class use this function.
// When using from tray icon, lpm would be zero.
contextmenu_show :: proc(this: ^ContextMenu, lpm: LPARAM)
{   
    /*--------------------------------------------------------------------
    We are creating the message-only window right before the context menu
    appears on the screen and we will destroy it right after the context
    menu dissappears. 
    ---------------------------------------------------------------------*/
    if len(this.menus) > 0 {
        create_message_only_window(this)
        defer {
            DestroyWindow(this._dummyHwnd)
            this._dummyHwnd = nil
        }
        if !this._menuInserted do cmenu_create_handle(this)
        pt : POINT
        get_mouse_points(&pt, lpm)
            /*---------------------------------------------------- 
        Context menus are triggered by either mouse right click
        or keyboard shortcuts like VK_APPS. When triggered from
        a mouse click, lparam contains the mouse points. But when
        triggered by keyboard shortcut, mouse coordinates are -1.
        ----------------------------------------------------------*/
        if pt.x == -1 || pt.y == -1 do pt = get_mouse_pos_on_msg()

        /*--------------------------------------------------------
        This is a hack. If context menu is displayed from a tray icon
        A window from this thread must be in forground, otherwise we 
        won't get any keyboard messages. If user wants to select any 
        menu item, we must activate any window. So we are bringing our
        tray's message-only window to foreground. 
        --------------------------------------------------------------*/        
        if (lpm == 0) do SetForegroundWindow(this.tray._msgWinHwnd)
        
        /*------------------------------------------------------------------------
        We are using TPM_RETURNCMD in the tpm_flag, so we don't get the 
        WM_COMMAND in our wndproc, we will get the selected menu id in return value.
        ----------------------------------------------------------------------------*/
        mid := api.TrackPopupMenu(this.handle, TPM_FLAG, int(pt.x), int(pt.y), 0, this._dummyHwnd, nil)
        if mid > 0 {
            menu, okay := get_menuitem_from_idnumber(this, uint(mid))
            if okay && menu._isEnabled {
                if menu.onClick != nil{
                    ea := new_event_args()
                    menu.onClick(menu, &ea)
                }
            }
        }

    }
    
}

@private get_menuitem_from_idnumber :: proc(this: ^ContextMenu, idnum: uint) -> (^MenuItem, bool)
{
    if len(this.menus) > 0 {
        for menu in this.menus {
            if menu.idNum == idnum do return menu, true
        }
    }
    return nil, false
}



@private contextmenu_dtor :: proc(this: ^ContextMenu)
{
    if len(this.menus) > 0 {
        for menu in this.menus do menuitem_dtor(menu)
        delete(this.menus)
    }
    api.DestroyMenu(this.handle)
    api.DestroyWindow(this._dummyHwnd)
    free(this)
    print("context menu dtor finished")
}





@private menuitem_dtor :: proc(this: ^MenuItem)
{
    if this._menuCount > 0 {
        for menu in this.menus do menuitem_dtor(menu)
        delete(this.menus)
    }
    free(this._wideText)
    free(this)
}

@private menubar_dtor :: proc(this: ^MenuBar)
{
    if this._menuCount > 0 {
        for menu in this.menus do menuitem_dtor(menu)
        delete(this.menus)
    }
    free(this)
}





@private cmenu_wndproc :: proc "fast" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM) -> LRESULT
{
    context = global_context
    // cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
    // display_msg(msg)
    switch msg {
        case WM_DESTROY:
            print("context menu's message-only window destroyed")

        case WM_MEASUREITEM:
            cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
            pmi := dir_cast(lp, LPMEASUREITEMSTRUCT)
            pmi.itemWidth = UINT(cmenu.width)
            pmi.itemHeight = UINT(cmenu.height)
            return 1

        case WM_DRAWITEM:
            cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
            dis := dir_cast(lp, LPDRAWITEMSTRUCT)
            mi := dir_cast(dis.itemData, ^MenuItem)
            txtClrRef : COLORREF = mi.fgColor.ref

            if dis.itemState & 1 == 1 {
                if mi._isEnabled {
                    rc := RECT{dis.rcItem.left + 4, dis.rcItem.top + 2, dis.rcItem.right, dis.rcItem.bottom - 2}
                    api.FillRect(dis.hDC, &rc, cmenu._hotBgBrush)
                    FrameRect(dis.hDC, &rc, cmenu._borderBrush)
                    txtClrRef = 0x00000000
                } else {
                    api.FillRect(dis.hDC, &dis.rcItem, cmenu._grayBrush)
                    txtClrRef = cmenu._grayCref
                }
            } else {
                api.FillRect(dis.hDC, &dis.rcItem, cmenu._defBgBrush)
                if !mi._isEnabled do txtClrRef = cmenu._grayCref
            }

            SetBkMode(dis.hDC, 1)
            dis.rcItem.left += 25
            SelectObject(dis.hDC, cast(HGDIOBJ)cmenu.font.handle)
            SetTextColor(dis.hDC, txtClrRef)
            DrawText(dis.hDC, mi._wideText, -1, &dis.rcItem, DT_LEFT | DT_SINGLELINE | DT_VCENTER)
            return 0

        case WM_ENTERMENULOOP:
            cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
            if cmenu.onMenuShown != nil {
                ea := new_event_args()
                cmenu.onMenuShown(cmenu, &ea)
            }
        case WM_EXITMENULOOP:
            cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
            if cmenu.onMenuClose != nil {
                ea := new_event_args()
                cmenu.onMenuClose(cmenu, &ea)
            }
        case WM_MENUSELECT:
            cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
            idNumber := uint(LOWORD(wp))
            hMenu := dir_cast(lp, HMENU)
            if hMenu != nil && idNumber > 0 {
                menu, okay := get_menuitem_from_idnumber(cmenu, idNumber)
                if okay && menu._isEnabled {
                    if menu.onFocus != nil {
                        ea := new_event_args()
                        menu.onFocus(menu, &ea)
                    }
                }
            }
        case WM_COMMAND:
            cmenu := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^ContextMenu)
            idNumber := uint(LOWORD(wp))
            if idNumber > 0 {
                menu, okay := get_menuitem_from_idnumber(cmenu, idNumber)
                if okay && menu._isEnabled {
                    if menu.onClick != nil{
                        ea := new_event_args()
                        menu.onClick(menu, &ea)
                    }
                }
            }
    
        case : return DefWindowProc(hw, msg, wp, lp)
    }
    return 0
}
