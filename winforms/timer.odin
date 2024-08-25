
// Timer module. Moved on 26-Aug-2024 02:02

package winforms
import api "core:sys/windows"

Timer :: struct {
	interval: u32,
	onTick: EventHandler,
	_parentHwnd: HWND,
    _idNum: UINT_PTR,
    _isEnabled: bool,
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