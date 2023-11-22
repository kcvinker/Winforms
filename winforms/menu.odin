// Created on 13-Nov-2023 06:13 PM
// Menu related features
package winforms

import api "core:sys/windows"

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
// End Constants

MenuType :: enum {Base_Menu, Menu_Item, Popup, Seprator}
menuNumber : uint = 101
bf : i32 = 0
bt : i32 = 1
bfalse : BOOL = cast(BOOL)bf
btrue : BOOL = cast(BOOL)bt

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
    menubar_add_items(this, ..menuitems)
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
    this._wideText = to_wstring(this.text)
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

menubar_additem2 :: proc(this: ^MenuBar, menuTxt: string, parent_text: string, txtColor: uint = 0x000000) -> ^MenuItem
{
    okay, pmenu := find_parentmenu(this._pForm, parent_text)
    if okay {
        mi := new_menuitem(menuTxt, MenuType.Menu_Item, pmenu.handle, pmenu._menuCount )
        mi._formHwnd = pmenu._formHwnd
        mi.fgColor = new_color(txtColor)
        mi._formMenu = true
        pmenu._menuCount += 1
        append(&pmenu.menus, mi)
        pmenu._menubar._pForm._menuItemMap[mi.idNum] = mi
        return mi
    }
    return nil
}

/*
    Add menu items to menu bar.
    Overloads:
        1. Add main menu items to a menubar. menubar_add_items(mbar, "item1", "item2")
        2. Add sub menus to main menu or normal menu item. menubar_add_items(mbar, "parent_text", false, "item1", "item2")
        3. If 'creteParent' argument is set to true, the function will create it and add those childs to parent.
            But if 'createParent' is false, function will serch and find the parent with that name.
*/
menubar_add_items :: proc{menubar_additems1, menubar_additems2}

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

// Create new child menus for a base menu or a normal menu item.
// If createParent is true, it will create a new base menu in menubar and create it's childs
// If createParent is false, it will find the existing base menu and create childs.
// If parent is a normal menu item, it will become a popup menu after this.
@private menubar_additems2 :: proc(this: ^MenuBar, parentName: string, createParent: bool, childMenuNames: ..string)
{
    pmenu : ^MenuItem
    okay : bool
    if createParent {
        pmenu = menubar_add_item(this, parentName)
        okay = true
    } else {
        okay, pmenu = find_parentmenu(this._pForm, parentName)
        if pmenu.kind == .Menu_Item {
            pmenu._popup = true
            pmenu.handle = CreatePopupMenu()
            if pmenu.kind != .Base_Menu do pmenu.kind = .Popup
        }
    }

    if okay {
        for item in childMenuNames {
            mi := new_menuitem(item, MenuType.Menu_Item, pmenu.handle, pmenu._menuCount )
            mi._formHwnd = this._pForm.handle
            mi._formMenu = true
            pmenu._menuCount += 1
            append(&pmenu.menus, mi)
            this._pForm._menuItemMap[mi.idNum] = mi
        }
    } else do ptf("Pmenu not found, name %s\n", parentName)
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
    mii.dwItemData = direct_cast(rawptr(mi), ULONG_PTR)
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
menubar_get_item :: proc(this: ^MenuBar, menu_text: string) -> (^MenuItem, bool)
{
    if len(this._pForm._menuItemMap) > 0 {
        for _, menu in this._pForm._menuItemMap {
            if menu.text == menu_text do return menu, true
        }
    }
    return nil, false
}

// Set an event handler function for given event. Function will find the menu item with given name.
menubar_set_event_handler :: proc(this: ^MenuBar, menu_text: string, event: MenuEvents, pFunc: MenuEventHandler)
{
    if len(this._pForm._menuItemMap) > 0 {
        pMenu, okay := menubar_get_item(this, menu_text)
        if okay {
            switch event {
                case .On_Click: pMenu.onClick = pFunc
                case .On_Popup: pMenu.onPopup = pFunc
                case .On_Closeup: pMenu.onCloseup = pFunc
                case .On_Focus: pMenu.onFocus = pFunc
            }
        }
    }
}







@private menuitem_dtor :: proc(this: ^MenuItem)
{
    if this._menuCount > 0 {
        for menu in this.menus do menuitem_dtor(menu)
        delete(this.menus)
    }
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


