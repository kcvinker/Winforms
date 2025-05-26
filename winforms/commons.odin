package winforms
import "core:fmt"
import "base:runtime"
import "base:intrinsics"
import "core:mem"
import api "core:sys/windows"


ptf :: fmt.printfln
print :: fmt.println

// All controls has a default back & fore color.
def_back_clr :: 0xFFFFFF
def_fore_clr :: 0x000000
gea : EventArgs = new_event_args()





/*----------------------------------------------------------------------------------
Use this function to update ui components from another thread.
Usage : Call this function with required data packed in wpm and lpm.
Then set the `onThreadMsg` property of Form struct. It is a function pointer.
Signature is `ThreadMsgHandler :: proc(wpm: WPARAM, lpm: LPARAM)`.
Function pointer assigned to onThreadMsg property will be called when CM_THREAD_MSG receives.
---------------------------------------------------------------------------------------------*/
send_thread_msg :: proc(formHwnd: HWND, wpm: WPARAM, lpm: LPARAM) -> LRESULT
{
	return SendNotifyMessage(formHwnd, CM_THREAD_MSG, wpm, lpm)
}

to_str :: proc(value : any) -> string {return fmt.tprint(value)}
L :: intrinsics.constant_utf16_cstring

current_time_internal :: proc() -> Time
{
	ftime : FILETIME
	GetSysTimeAsFileTime(&ftime)
	ns := FILETIME_as_unix_nanoseconds(ftime)
	return Time{_nano_sec = ns}
}

current_filetime :: proc(tm : TimeMode) -> i64
{
	result : i64
	n := current_time_internal()
	switch tm {
		case .Nano_Sec : result = n._nano_sec
		case .Micro_Sec : result = n._nano_sec / 1000
		case .Milli_Sec : result = n._nano_sec / 1000000
	}
	return result
}

check_redraw :: #force_inline proc(ctl: ^Control, draw: b32 = false) 
{
	if ctl._isCreated do InvalidateRect(ctl.handle, nil, BOOL(draw))
}

create_hbrush :: proc(clr : uint) -> HBRUSH
{
	cref := get_color_ref(clr)
	return CreateSolidBrush(cref)
}

draw_ellipse :: proc(dch : HDC, rc : RECT)
{
	Ellipse(dch, rc.left, rc.top, rc.right, rc.bottom)
}

// Caller must free the string buffer.
@private get_ctrl_text_internal :: proc(hw : HWND, alloc := context.allocator) -> string
{
	tlen := GetWindowTextLength(hw)
	wsBuffer := make([]WCHAR, tlen + 1, alloc)
	defer delete(wsBuffer)
	GetWindowText(hw, &wsBuffer[0], i32(len(wsBuffer)))
	return utf16_to_utf8(wsBuffer, alloc)
}

@private calculate_ctl_size :: proc(ctl : ^Control)
{
	ss : SIZE
    SendMessage(ctl.handle, BCM_GETIDEALSIZE, 0, dir_cast( &ss, LPARAM))
    ctl.width = int(ss.cx)
    ctl.height = int(ss.cy)
    MoveWindow(ctl.handle, i32(ctl.xpos), i32(ctl.ypos), ss.cx, ss.cy, true)
}

@private in_range :: proc(value, min_val, max_val : i32) -> bool
{
	if value > min_val && value < max_val do return true
	return false
}

@private alert :: proc(txt : string)
{
	@static cntr : int = 1
	ptf("%s - [%d]\n", txt, cntr)
	cntr += 1
}

@private alert2 :: proc(txt : string, data : any)
{
	@static cntr : int = 1
	ptf("[%d] %s - %s\n", cntr, txt, fmt.tprint(data))
	cntr += 1
}

conc_num :: proc{conc_num1, conc_num2}
conc_num1 :: proc(value : string, num : int ) -> string {return fmt.tprint(args = {value, num},sep = "")}
conc_num2 :: proc(value : string, num : uint ) -> string {return fmt.tprint(args = {value, num},sep = "")}

dir_cast :: #force_inline proc(value : $T, $tp : typeid) -> tp
{
	return cast(tp)cast(UINT_PTR) value
}

convert_to :: proc($tp : typeid, value : $T) -> tp
{
	up := cast(UINT_PTR) cast(rawptr) value
	return cast(tp) up
}

to_lparam :: proc(value: $T) -> LPARAM
{
	up := cast(UINT_PTR) value
	return cast(LPARAM) up
}

to_wparam :: proc(value: $T) -> WPARAM
{
	up := cast(UINT_PTR) value
	return cast(WPARAM) up
}

to_dwptr :: proc(ctl : ^Control) -> DWORD_PTR
{
	up := cast(UINT_PTR) ctl
	return cast(DWORD_PTR) up
}

get_rect :: proc(hw : HWND) -> RECT
{
	rct : RECT
	GetClientRect(hw, &rct)
	return rct
}

get_win_rect :: proc(hw : HWND) -> RECT
{
	rc : RECT
	GetWindowRect(hw, &rc)
	return rc
}

make_dword :: proc(lo_val, hi_val : $T) -> DWORD
{
	hv := cast(WORD) hi_val
    lv := cast(WORD) lo_val
	dw_val := DWORD(DWORD(lv) | (DWORD(hv)) << 16)
	return dw_val
}

tostring :: proc(value: $T) -> string
{
	sitem : string
    when T == string {
        sitem = item
    } else {
        sitem = fmt.tprint(value)
    }
	return sitem
}
// left = loword, right side - highword

// There a lot of time we need to convert a handle like HBrush to HGDIOBJ.
// This proc will help for it.
toHGDI :: proc(value : $T ) -> HGDIOBJ {return cast(HGDIOBJ) value}
toLRES :: proc(value : $T) -> LRESULT
{
	up := cast(UINT_PTR) value
	return cast(LRESULT) up
}

// If we want to get the virtual key code (VK_KEY_NUMPAD1 etc) from lparam...
// in any keyboard related message, this proc helps to extract it
get_virtual_key :: proc(value : LPARAM) -> u32
{
	scan_code : u32 = u32(value >> 16 )
    return MapVirtualKey(scan_code, MAPVK_VSC_TO_VK)
}

// get_x_lparam :: proc(lpm : LPARAM) -> int { return int(i16(loword_lparam(lpm)))}
// get_y_lparam :: proc(lpm : LPARAM) -> int { return int(i16(hiword_lparam(lpm)))}

get_mouse_points :: proc{get_mouse_points1, get_mouse_points2}

@private
get_mouse_points1 :: proc(lpm : LPARAM) -> POINT  // Used in mouse messages
{
	pt : POINT
	pt.x = get_x_lpm(lpm)
	pt.y = get_y_lpm(lpm)
	return pt
}

@private
get_mouse_points2 :: proc(pt: ^POINT, lpm : LPARAM)  // Used in mouse messages
{
	// ptf("dwd ptr lpm %d", (cast(u16)lpm))
	if lpm == 0 {
		GetCursorPos(pt)
	} else {
		pt.x = get_x_lpm(lpm)
		pt.y = get_y_lpm(lpm)
	}
}

get_mouse_pos_on_msg :: proc() -> POINT
{
	result : POINT
    dw_value := GetMessagePos()
    result.x = i32(LOWORD(dw_value))
    result.y = i32(HIWORD(dw_value))
	ptf("x: %d, y: %d", result.x, result.y)
	return result
}

LOWORD :: #force_inline proc "contextless" (x: $T) -> WORD { return cast(u16)x}
HIWORD :: #force_inline proc "contextless" (x: $T) -> WORD { return cast(u16)(x >> 16)}

// loword_wparam :: #force_inline proc "contextless" (x : WPARAM) -> WORD { return WORD(x & 0xffff)}
// hiword_wparam :: #force_inline proc "contextless" (x : WPARAM) -> WORD { return WORD(x >> 16)}
// loword_lparam :: #force_inline proc "contextless" (x : LPARAM) -> WORD { 
// 	return cast(WORD)(cast(DWORD_PTR)x & 0xffff)
	
// }
// hiword_lparam :: #force_inline proc "contextless" (x : LPARAM) -> WORD { 
// 	// return cast(WORD)(cast(DWORD_PTR)x >> 16)
// 	return cast(u16)(x >> 16)

// }

get_x_lpm :: #force_inline proc "contextless"(x: LPARAM) -> i32 {
	return cast(i32)(cast(i16)LOWORD((x)))
}

get_y_lpm :: #force_inline proc "contextless"(y: LPARAM) -> i32 {
	return cast(i32)(cast(i16)HIWORD((y)))
}


@private select_gdi_object :: #force_inline proc(hd : HDC, obj : $T)
{
	SelectObject(hd, cast(HGDIOBJ)obj)
}

@private delete_gdi_object :: #force_inline proc(obj : $T)
{
	DeleteObject(cast(HGDIOBJ) obj)
}

@private dynamic_array_search :: proc(arr : [dynamic]$T, item : T) -> (index : int, is_found : bool)
{
	for i := 0 ; i < len(arr) ; i += 1 {
		if arr[i] == item {
			index = i
			is_found = true
			break
		}
	}
	return index, is_found
}

@private static_array_search :: proc(arr : []$T, item : T) -> (index : int, is_found : bool)
{
	for i := 0 ; i < len(arr) ; i += 1 {
		if arr[i] == item {
			index = i
			is_found = true
			break
		}
	}
	return index, is_found
}

array_search :: proc{	dynamic_array_search, static_array_search,}

// This proc will return an HBRUSH to paint the window or a button in gradient colors.
@private create_gradient_brush :: proc(hdc : HDC, rct : RECT, c1, c2 : Color, t2b : bool = true) -> HBRUSH
{
	
	mem_hdc : HDC = CreateCompatibleDC(hdc)
	hbmp : HBITMAP = CreateCompatibleBitmap(hdc, rct.right, rct.bottom)
	loop_end : i32 = rct.bottom if t2b else rct.right

	SelectObject(mem_hdc, HGDIOBJ(hbmp))
	i : i32
	for i = 0; i < loop_end; i += 1 {
		t_rct : RECT
		r, g, b : uint

		r = c1.red + uint((i * i32(c2.red - c1.red) / loop_end))
        g = c1.green + uint((i * i32(c2.green - c1.green) / loop_end))
        b = c1.blue + uint((i * i32(c2.blue - c1.blue) / loop_end))
		t_brush : HBRUSH = CreateSolidBrush(get_color_ref(r, g, b))
		defer DeleteObject(HGDIOBJ(t_brush))
		t_rct.left = 0 if t2b else i
		t_rct.top = i if t2b else 0
		t_rct.right = rct.right if t2b else i + 1
		t_rct.bottom = i + 1 if t2b else loop_end
		api.FillRect(mem_hdc, &t_rct, t_brush)
		
	}
	gradient_brush : HBRUSH = CreatePatternBrush(hbmp)
	DeleteDC(mem_hdc)
	DeleteObject(HGDIOBJ(hbmp))
	return gradient_brush
}


@private
print_rect :: proc(rc : RECT, name: string) {
	ptf("[%s]	%d, %d, %d, %d", name, rc.left, rc.top, rc.right, rc.bottom)
	// print("----------------------------------------------------")
}

@private
screen_to_window :: proc(rc: RECT, hw: HWND) -> RECT
{
	p1: POINT = {rc.left, rc.top}
	p2: POINT = {rc.right, rc.bottom}
	api.ScreenToClient(hw, api.LPPOINT(&p1))
	api.ScreenToClient(hw, api.LPPOINT(&p2))
	return {p1.x, p1.y, p2.x, p2.y}
}

@private set_rect :: proc(rc : ^RECT, left, top, right, bottom: i32)
{
	rc.left = left
	rc.top = top
	rc.right = right
	rc.bottom = bottom
}

Test :: proc()
{
	dw : DWORD = 100 | 200 | 300
	ptf("dw in decimal %d\n", dw)
	ptf("dw in binary %b\n", dw)
	ptf("dw in hex %X\n", dw)
}



create_handle :: proc(ctl : ^$T)
{
	when T == Form {
		create_form(ctl)
	} else {
		create_control(ctl)
	}
}

create_controls :: proc(ctls : ..^Control)
{
	for c in ctls {
		create_control(c)
	}
}

show_memory_report :: proc(track: ^mem.Tracking_Allocator)
{
    for _, v in track.allocation_map { ptf("%v leaked %v bytes\n", v.location, v.size) }
    for bf in track.bad_free_array { ptf("%v allocation %p was freed badly\n", bf.location, bf.memory) }
}
