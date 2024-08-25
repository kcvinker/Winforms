// Created on 05-Aug-2024 07:39

package winforms

import "base:runtime"
import "core:mem"
import api "core:sys/windows"

winFormsClass := []u16 {'W', 'i', 'n', 'f', 'o', 'r', 'm', 's', '_', 'W', 'i', 'n', 'd', 'o', 'w', 0}
global_context      : runtime.Context
def_window_color    : uint  : 0xF5F5F5
def_fore_color      : uint  : 0x000000
pure_white          : uint  : 0xFFFFFF
pure_black          : uint  : 0x000000
def_font_name       :: "Tahoma"
def_font_size       :: 11
def_bgc : Color
def_fgc : Color
app : Application // Global variable for storing data needed by the entire library.

@private
Application :: struct
{
    mainHandle : HWND,
    hInstance : HINSTANCE,
    trayHwnd : HWND,
    screenWidth, screenHeight : int,
    scaleFactor, sysDPI: i32,
    formCount : int,
    clrWhite : uint,
    clrBlack : uint,
    fontHeight : LONG,
    mainLoopStarted : bool,
    nidUsed : bool,
    startState : FormState,
    globalFont : Font,
    iccx : INITCOMMONCONTROLSEX,    
    winMap : map[HWND]^Form,
    
}

@(init)
@private 
app_start :: proc() 
{
    app.hInstance = GetModuleHandle(nil)
    app.screenWidth = int(api.GetSystemMetrics(0))
    app.screenHeight = int(api.GetSystemMetrics(1))
    app.iccx.dwSize = size_of(app.iccx)
    app.iccx.dwIcc = ICC_STANDARD_CLASSES
    InitCommonControlsEx(&app.iccx)    
    app.clrWhite = pure_white
    app.clrBlack = pure_black    
}

@private get_system_dpi :: proc(this: ^Application)
{
    hdc: HDC = GetDC(nil)
    defer ReleaseDC(nil, hdc)
    this.sysDPI = GetDeviceCaps(hdc, LOGPIXELSY)    
    this.scaleFactor = GetScaleFactorForDevice(0)
}

@private
app_finalize :: proc(this: Application) // Will be executed right after main loop exit
{
    if this.nidUsed {
        if this.trayHwnd != nil do DestroyWindow(this.trayHwnd)
    }
    delete(this.winMap)
}