// graphics module, created on 21-Sep-2024 06:54

package winforms
import api "core:sys/windows"

Graphics :: struct 
{
    hdc: HDC,
    hwnd: HWND,
    freeDC: b32,
}

new_graphics :: proc{new_graphics1, new_graphics2}

new_graphics1 :: proc(hw: HWND) -> ^Graphics
{
    gfx := new(Graphics)
    gfx.hdc = GetDC(hw)
    gfx.hwnd = hw 
    gfx.freeDC = true
    return gfx
}

new_graphics2 :: proc(wp: WPARAM) -> ^Graphics
{
    gfx := new(Graphics)
    gfx.hdc = dir_cast(wp, HDC)
    gfx.hwnd = nil 
    gfx.freeDC = false
    return gfx
}

gfx_destroy :: proc(this: ^Graphics)
{
    if this.freeDC do ReleaseDC(this.hwnd, this.hdc)
    free(this)
}

gfx_draw_hline :: proc(this: ^Graphics, mPen: HPEN, sx, y, ex: i32)
{
    select_gdi_object(this.hdc, mPen)
    MoveToEx(this.hdc, sx, y, nil)
    LineTo(this.hdc, ex, y)
}

gfx_draw_text :: proc(this: ^Graphics, pc: ^Control, x, y : i32)
{
    api.SetBkMode(this.hdc, api.BKMODE.TRANSPARENT)
    select_gdi_object(this.hdc, pc.font.handle)
    api.SetTextColor(this.hdc, pc._fcref)
    TextOut(this.hdc, x, y, pc._wtext.ptr, pc._wtext.strLen)
}