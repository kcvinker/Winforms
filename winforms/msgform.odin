// Created on 07-Sep-2025 9:56 PM
// Purpose :   Message-Only form for Winforms library

package winforms

import "core:fmt"
import "base:runtime"
// import "core:mem"
// import "core:time"
import api "core:sys/windows"

MessageHandler :: proc(sender : ^MessageForm, msg : u32, wp : WPARAM, lp : LPARAM) -> bool

MessageForm :: struct
{
    tray : ^TrayIcon,
    isActive : bool,
    noTray : bool,
    handle : HWND,
    timers : [dynamic]^Timer,
    hkeys : map[i32]EventHandler,
    msgHandler : MessageHandler,
}

new_messageform :: proc(msgHandler: MessageHandler, autoc: bool = true,
                notray: bool = false, nocmenu: bool = false,
                traytip: string = "Winforms MessageForm",
                iconpath: string = ""  ) -> ^MessageForm
{
    context = global_context
    if app.isMowReg == false do initMsgForm()    
    this := new(MessageForm, context.allocator)
    this.noTray = notray
    this.msgHandler = msgHandler
    this.isActive = true
    if !notray {
        this.tray = new_tray_icon(traytip, iconpath)
        if !nocmenu {
            tray_add_context_menu(this.tray, false, TrayMenuTrigger.Any_Click, "Quit")
            cmenu_set_itemtag(this.tray.contextMenu, "Quit", this)
            cmenu_add_handler(this.tray.contextMenu, "Quit", onTrayQuit)
        }
    }
    if autoc do msgform_create_handle(this)
    return this
}

    
msgform_create_handle :: proc(this: ^MessageForm) -> HWND
{
    this.handle = CreateWindowEx(0, &mfclass[0], nil, 0, 0, 0, 0, 0,
                                HWND_MESSAGE, nil, app.hInstance, nil)

    if this.handle != nil {
        app.mfMap[this.handle] = this
    }
    return this.handle
}

onTrayQuit :: proc(c: rawptr, e: ^EventArgs) 
{
    mi := cast(^MenuItem)c
    mf := cast(^MessageForm)mi.tag
    DestroyWindow(mf.handle)
}

// Start the main loop and display the form
msgform_start_listening :: proc(this: ^MessageForm)
{
    ms : MSG
    for GetMessage(&ms, nil, 0, 0) != 0
    {
        TranslateMessage(&ms)
        DispatchMessage(&ms)
    }
    app_finalize(app)
}

msgform_close :: proc(this: ^MessageForm)
{
    if this.handle != nil do DestroyWindow(this.handle)
}

msgform_sendmsg :: proc(this: ^MessageForm, hwnd: HWND, msg: u32, wp: WPARAM, lp: LPARAM) -> LRESULT
{
    return SendMessage(hwnd, msg, wp, lp)
}

msgform_addtimer :: proc(this: ^MessageForm, interval: u32, handler: EventHandler) -> ^Timer
{
    tmr := new_timer(this.handle, interval, handler)
    append(&this.timers, tmr)
    return tmr
}

msgform_addhotkey :: proc(this: ^MessageForm, keyList: []KeyEnum, handler: EventHandler, repeat: b32 = false) -> i32
{
    hkid := reg_new_hotkey(this.handle, keyList, repeat)
    if hkid != -1 do this.hkeys[hkid] = handler        
    return hkid    
}

msgform_remove_hotkey :: proc(this: ^MessageForm, hkid: i32) -> bool
{
    if len(this.hkeys) > 0 {
        okay := hkid in this.hkeys 
        if okay {
            UnregisterHotKey(this.handle, hkid)
            delete_key(&this.hkeys, hkid)
            return true
        }
    }
    return false
}

msgform_remove_hotkeys :: proc(this: ^MessageForm, hkidList: ..i32) -> bool
{
    if len(this.hkeys) > 0 {
        counter : int = 0
        for hkid in hkidList {
            okay := hkid in this.hkeys 
            if okay {
                UnregisterHotKey(this.handle, hkid)
                delete_key(&this.hkeys, hkid)
                counter += 1                
            }
        }
        if counter == len(hkidList) do return true
    }
    return false
}

msgform_get_hkey_handler :: proc(this: ^MessageForm, hkid: i32) -> EventHandler
{
    if len(this.hkeys) > 0 {
        pfunc, okay := this.hkeys[hkid]
        if okay do return pfunc
    }
    return nil
}

msgform_get_timer :: proc(this: ^MessageForm, tid: UINT_PTR) -> ^Timer
{
    if len(this.timers) > 0 {
        for tmr in this.timers {
            if tmr._idNum == tid do return tmr
        }
    }
    return nil
}

msgform_get_timer_index :: proc(this: ^MessageForm, tid: UINT_PTR) -> (int, bool)
{
    for tmr, i in this.timers {
        if tmr._idNum == tid do return i, true
    }
    return -1, false
}



@private
msgfrm_destroy :: proc(this: ^MessageForm)
{
    if this.isActive {
        if this.noTray && this.tray != nil do DestroyWindow(this.tray._msgWinHwnd)
        this.tray = nil

        if len(this.timers) > 0 {
            for tmr in this.timers {timer_dtor(tmr)}        
        }

        if len(this.hkeys) > 0 {
            for hkid, _ in this.hkeys {
                UnregisterHotKey(this.handle, hkid)
            }        
        }
        
        delete(this.timers)
        delete(this.hkeys)        
        this.isActive = false
    }
    delete_key(&app.mfMap, this.handle)
    free(this)
    print("MessageForm destroyed.")
}

@private
msgfrm_wndproc :: proc "stdcall" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM ) -> LRESULT
{
    context = global_context
    display_msg(msg)
    switch msg {
        case WM_GETMINMAXINFO, WM_NCCREATE, WM_NCCALCSIZE, WM_CREATE:
            return DefWindowProc(hw, msg, wp, lp)

        case WM_NCDESTROY:
            this := app.mfMap[hw]
            if this != nil do msgfrm_destroy(this)
            return 0

        case WM_DESTROY, CM_CLOSE_MSGFORM:
            PostQuitMessage(0)
            return 0 

        case WM_HOTKEY:
            this := app.mfMap[hw]            
            pfunc := msgform_get_hkey_handler(this, cast(i32)wp)
            if pfunc != nil do pfunc(this, &gea)
            return 0     

        case WM_TIMER:
            this := app.mfMap[hw]
            timer := msgform_get_timer(this, cast(UINT_PTR)wp)
            if timer != nil && timer.onTick != nil do timer.onTick(this, &gea) 
            return 0 

        case CM_TIMER_DESTROY:
            this := app.mfMap[hw]
            tmindex, okay := msgform_get_timer_index(this, cast(UINT_PTR)wp)
            if okay do unordered_remove(&this.timers, tmindex)
            return 0

        case :
            this := app.mfMap[hw]
            res := this.msgHandler(this, msg, wp, lp)
            if res {
                return 0
            } else {
                return DefWindowProc(hw, msg, wp, lp)
            }
    }
    return DefWindowProc(hw, msg, wp, lp)
}