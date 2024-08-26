// Moved on 25-Aug-2024 20:52 
// ContextMenu related features



package winforms
import api "core:sys/windows"

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


@private 
cmenu_insert_internal :: proc(this: ^MenuItem)
{
    if len(this.menus) > 0 {
        for menu in this.menus {cmenu_insert_internal(menu)}
    }
    if this.kind == .Context_Menu {         
        insert_menu_internal(this, this.parentHandle)
    } else if this.kind == .Seprator {
        api.AppendMenuW(this.parentHandle, MF_SEPARATOR, 0, nil)
    }
}

// Creates all the menu items. This will get called automatically at the first usage.
// But you can call this explicitly after you added the last menu item.
// That will imrove the context menu opening speed.
cmenu_create_handle :: proc(this: ^ContextMenu)
{
    if len(this.menus) > 0 {
        for menu in this.menus { 
            cmenu_insert_internal(menu)
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


// Display context menu on mouse click or short key press.
// Both TrayIcon and Control class use this function.
// When using from tray icon, lpm will be zero.
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
        mid := uint(api.TrackPopupMenu(this.handle, TPM_FLAG, pt.x, pt.y, 0, this._dummyHwnd, nil))
        if mid > 0 {
            menu, okay := get_menuitem_from_idnumber(this, mid)
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
    // print("context menu dtor finished")
}


@private cmenu_wndproc :: proc "fast" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM) -> LRESULT
{
    context = global_context
    // display_msg(msg)
    switch msg {
        // case WM_DESTROY:
        //     print("context menu's message-only window destroyed")

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

            api.SetBkMode(dis.hDC, api.BKMODE.TRANSPARENT)
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
    
        case : return DefWindowProc(hw, msg, wp, lp)
    }
    return 0
}

