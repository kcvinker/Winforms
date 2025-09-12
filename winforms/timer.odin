
// Timer module. Moved on 26-Aug-2024 02:02

package winforms
import api "core:sys/windows"

GLBL_HKEY_ID : i32 = 1000

Timer :: struct {
	interval: u32,
	onTick: EventHandler,
	_parentHwnd: HWND,
    _idNum: UINT_PTR,
    _isEnabled: bool,
}

new_timer :: proc(pHwnd: HWND, interval: u32, ontickFunc: EventHandler) -> ^Timer
{
    context = global_context
    this := new(Timer, context.allocator)
    this.interval = interval
    this.onTick = ontickFunc
    this._parentHwnd = pHwnd
    this._idNum = UINT_PTR(this) // Unique ID based on memory address
    this._isEnabled = false
    return this
}


timer_start :: proc(this: ^Timer)
{
    this._isEnabled = true
    SetTimer(this._parentHwnd, this._idNum, this.interval, nil)
}

timer_stop :: proc(this: ^Timer)
{
    KillTimer(this._parentHwnd, this._idNum)
    this._isEnabled = false
}

@private timer_dtor :: proc(this: ^Timer)
{
    if this._isEnabled do KillTimer(this._parentHwnd, this._idNum)
    free(this)
}


// Add hotkey helper function
reg_new_hotkey :: proc(hWnd: HWND, keyList: []KeyEnum, repeat: b32 = false) -> i32
{   
    res : i32 = -1
    fmode : u32 = 0
    vkey : u32 = 0
    for k in keyList {
        #partial switch k {
            case KeyEnum.Alt: fmode |= 0x0001
            case KeyEnum.Ctrl: fmode |= 0x0002
            case KeyEnum.Shift: fmode |= 0x0004
            case KeyEnum.Left_Win, KeyEnum.Right_Win: fmode |= 0x0008
            case:
                if vkey < 256 do vkey = cast(u32)k                
        }
    }
    if repeat do fmode |= 0x4000
    fres := api.RegisterHotKey(hWnd, GLBL_HKEY_ID, fmode, vkey)
    if fres do res = GLBL_HKEY_ID
    GLBL_HKEY_ID += 1
    return res
}