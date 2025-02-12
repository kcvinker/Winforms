// Created on 03-Aug-2024 08:46 PM

/*===========================================TrayIcon Docs=========================================================
    TrayIcon struct
        Constructor: new_tray_icon() -> ^TrayIcon
        Properties:
            All props from Control struct
            menuTrigger     : TrayMenuTrigger - An enum in this file
            contextMenu     : ^ContextMenu 
            userData        : rawptr 
        Functions:
			tray_show_balloon
            tray_update_tooltip
            tray_update_icon
            tray_add_context_menu

        Events:
			All events from Control struct
            TrayIconEventHandler type [proc(^TrayIcon, ^EventARgs)]
                onBalloonShow
                onBalloonClose
                onBalloonClick                
                onMouseMove
                onLeftMouseDown
                onLeftMouseUp                
                onRightMouseDown
                onRightMouseUp
                onLeftClick
                onRightClick
                onLeftDoubleClick
            
==============================================================================================================*/


package winforms

import api "core:sys/windows"

trayClass := []WCHAR {'W', 'i', 'n', 'f', 'o', 'r', 'm', 's', '_', 'T', 'r', 'a', 'y', 0}
trayMsgWinRegistered : bool = false

LIMG_FLAG : u32 : LR_DEFAULTCOLOR | LR_LOADFROMFILE

TrayMenuTrigger :: enum u8 {None, Left_Click, Left_Double_Click = 2, Right_Click = 4, Any_Click = 7}
BalloonIcon :: enum {None, Info, Warning, Error, Custom} 

TrayIcon :: struct
{
    menuTrigger: TrayMenuTrigger,
    contextMenu: ^ContextMenu,
    userData: rawptr,
    _resetIcon, _cmenuUsed, _retainIcon: bool,
    _hTrayIcon: HICON,
    _msgWinHwnd: HWND,
    _nid: NOTIFYICONDATA,

    onBalloonShow, onBalloonClose, onBalloonClick: TrayIconEventHandler,
    onMouseMove, onLeftMouseDown, onLeftMouseUp: TrayIconEventHandler, 
    onRightMouseDown, onRightMouseUp, onLeftClick: TrayIconEventHandler,
    onRightClick, onLeftDoubleClick: TrayIconEventHandler
}

// Create new tray icon
new_tray_icon :: proc(tooltip: string, iconpath: string = "") -> ^TrayIcon
{
    this := new(TrayIcon)
    
    if !trayMsgWinRegistered do register_tray_msgwindow()
    create_tray_msgonly_window(this)
    if iconpath == "" {
        this._hTrayIcon = LoadIcon(nil, IDI_SHIELD)
    } else {
        this._hTrayIcon = LoadImage(nil, to_wchar_ptr(iconpath), IMAGE_ICON, 0, 0, LIMG_FLAG)
        if this._hTrayIcon == nil {
            this._hTrayIcon = LoadIcon(nil, IDI_SHIELD);
            ptf("Can't create icon with %s", iconpath);            
        } 
    }
    xu : uint = 0
    ptf("notify icon size %d, uint size %d", size_of(this._nid), size_of(xu))
    tipTxt : []u16 = utf8_to_utf16(tooltip)
    this._nid.cbSize = size_of(this._nid)
    this._nid.hWnd = this._msgWinHwnd
    this._nid.uID = 1
    this._nid.uVersionOrTimeout = 4
    this._nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP
    this._nid.uCallbackMessage = CM_TRAY_MSG
    this._nid.hIcon = this._hTrayIcon 
    copy(this._nid.toolTipText[:], tipTxt)
    x := Shell_NotifyIcon(NIM_ADD, &this._nid);  
    ptf("shell notify res %d", x)
    app.trayHwnd = this._msgWinHwnd
    app.nidUsed = true
    return this
}

// Show balloon notifiction on tray
tray_show_balloon :: proc(this: ^TrayIcon, title, message: string, 
                                timeout: u32,               // In milliseconds. 
                                noSound := false,           // Do you want a silent balloon?
                                icon : BalloonIcon = .Info,  // Use any system icon or custom icon.
                                iconpath := "")             // If custom icon, give the path.
{
    modifyIcon := false;
    bTitle : []u16 = utf8_to_utf16(title)
    bMsg : []u16 = utf8_to_utf16(message)
    this._nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP | NIF_INFO
    copy(this._nid.balloonTitle[:], bTitle)
    copy(this._nid.balloonText[:], bMsg)
    if icon == .Custom && iconpath != "" {
        this._nid.hIcon  = LoadImage(nil, to_wstring(iconpath), IMAGE_ICON, 0, 0, LIMG_FLAG)

        // If any error happened, we will use our base icon.
        if this._nid.hIcon == nil {
            this._nid.hIcon = this._hTrayIcon
        } else { 
            /*=================================================================
            So, we successfully created an icon handle from 'iconpath' parameter.
            So, for this balloon, we will show this icon. But We need to... 
            ...reset the old icon after this balloon vanished. 
            Otherwise, from now on we need to use this icon in Balloons and tray. 
            ======================================================================*/
            this._resetIcon = true        
        }
    }
    this._nid.dwInfoFlags = DWORD(icon) 		
    this._nid.uVersionOrTimeout = timeout        
    if noSound do this._nid.dwInfoFlags |= NIIF_NOSOUND
    Shell_NotifyIcon(NIM_MODIFY, &this._nid)
    this._nid.dwInfoFlags = 0
    this._nid.uFlags = 0
    // ptf("balloon result - %d", x)	
}

// Update tooltip for tray icon
tray_update_tooltip :: proc(this: ^TrayIcon, tooltip: string)
{
    this._nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP // This is for safety,'cause flags might be zero.
    tipTxt : []u16 = utf8_to_utf16(tooltip)
    copy(this._nid.toolTipText[:], tipTxt)
    Shell_NotifyIcon(NIM_MODIFY, &this._nid)
}

// Update icon for tray icon
tray_update_icon :: proc(this: ^TrayIcon, iconpath: string)
{    
    this._hTrayIcon = LoadImage(nil, to_wstring(iconpath), IMAGE_ICON, 0, 0, LIMG_FLAG)
    if this._hTrayIcon == nil {
        this._hTrayIcon = LoadIcon(nil, IDI_WINLOGO)
        ptf("Can't create icon with %s", iconpath)
    }
    this._nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP // This is for safety,'cause flags might be zero.  
    this._nid.hIcon = this._hTrayIcon   
    Shell_NotifyIcon(NIM_MODIFY, &this._nid)    
}

// Add context menu to tray icon
tray_add_context_menu :: proc(this: ^TrayIcon, trigger: TrayMenuTrigger, menuNames: ..string) -> ^ContextMenu
{
    cmenu := new_contextmenu(true);
    contextmenu_add_items(cmenu, ..menuNames)
    cmenu.tray = this
    cmenu._hasTrayParent = true  
    this.contextMenu = cmenu
    this._cmenuUsed = true
    this.menuTrigger = trigger
    return cmenu
}

//=======================================Private Functions================================

@private tray_icon_finalize :: proc(this: ^TrayIcon)
{
    DestroyWindow(this._msgWinHwnd)
    app.trayHwnd = nil // So that app's finalizer won't call this finalizer.
}

@private resetIconInternal :: proc(this: ^TrayIcon)
{
    this._nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP
    this._nid.hIcon = this._hTrayIcon
    Shell_NotifyIcon(NIM_MODIFY, &this._nid)
    this._resetIcon = false // Revert to default state.
}

@private register_tray_msgwindow :: proc()
{
    wc : WNDCLASSEXW 
    wc.cbSize = size_of(wc)
    wc.lpfnWndProc = tray_wndproc
    wc.hInstance = app.hInstance
    wc.lpszClassName = &trayClass[0]
    RegisterClassEx(&wc)
    trayMsgWinRegistered = true
}

@private create_tray_msgonly_window :: proc(this: ^TrayIcon)
{
    this._msgWinHwnd = CreateWindowEx(0, &trayClass[0], nil, 0, 0, 0, 0, 0, HWND_MESSAGE, nil, app.hInstance, nil)
    ptf("msg win hwnd %d", this._msgWinHwnd)
    SetWindowLongPtr(this._msgWinHwnd, GWLP_USERDATA, cast(LONG_PTR) cast(UINT_PTR) this)
    // if this.font.handle == nil do CreateFont_handle(&this.font)
}

@private tray_wndproc :: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM) -> LRESULT
{
    context = global_context
    // display_msg(msg)
    switch msg {
        case WM_DESTROY:            
            this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
            Shell_NotifyIcon(NIM_DELETE, &this._nid)
            if this._hTrayIcon != nil do DestroyIcon(this._hTrayIcon)
            if this._cmenuUsed do contextmenu_dtor(this.contextMenu)
            free(this)
            print("context menu's message-only window destroyed")

        case CM_TRAY_MSG:
            switch lp {
                case NIN_BALLOONSHOW:
                    print("tray balloon show")
                case NIN_BALLOONTIMEOUT:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)                    
                    if this.onBalloonClose != nil {
                        ea := new_event_args()
                        this.onBalloonClose(this, &ea)
                    }
                    if this._resetIcon do resetIconInternal(this) // Need to revert the default icon

                case NIN_BALLOONUSERCLICK:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onBalloonClick != nil {
                        ea := new_event_args()
                        this.onBalloonClick(this, &ea)
                    }
                    if this._resetIcon do resetIconInternal(this) // Need to revert the default icon

                case WM_LBUTTONDOWN:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onLeftMouseDown != nil {
                        ea := new_event_args()
                        this.onLeftMouseDown(this, &ea)
                    }
                    
                case WM_LBUTTONUP:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onLeftMouseUp != nil {
                        ea := new_event_args()
                        this.onLeftMouseUp(this, &ea)
                    }
                    if this.onLeftClick != nil {
                        ea := new_event_args()
                        this.onLeftClick(this, &ea)
                    }
                    if this._cmenuUsed && (u8(this.menuTrigger) & 1) == 1 {
                        contextmenu_show(this.contextMenu, 0)
                    }

                case WM_LBUTTONDBLCLK:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onLeftDoubleClick != nil {
                        ea := new_event_args()
                        this.onLeftDoubleClick(this, &ea)
                    }
                    if this._cmenuUsed && u8(this.menuTrigger) & 2 == 2 {
                        contextmenu_show(this.contextMenu, 0)
                    }                   

                case WM_RBUTTONDOWN:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onRightMouseDown != nil {
                        ea := new_event_args()
                        this.onRightMouseDown(this, &ea)
                    }

                case WM_RBUTTONUP:                    
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onRightMouseUp != nil {
                        ea := new_event_args()
                        this.onRightMouseUp(this, &ea)
                    }
                    if this.onRightClick != nil {
                        ea := new_event_args()
                        this.onRightClick(this, &ea)
                    }
                    if this._cmenuUsed && u8(this.menuTrigger) & 4 == 4 {
                        contextmenu_show(this.contextMenu, 0)
                    }                    
                    
                case WM_MOUSEMOVE:
                    this := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^TrayIcon)
                    if this.onMouseMove != nil {
                        ea := new_event_args()
                        this.onMouseMove(this, &ea)
                    }
                    
            }

        case : return DefWindowProc(hw, msg, wp, lp)
    }
    return DefWindowProc(hw, msg, wp, lp)
}