package winforms
import "core:fmt"
// My Own messages
	ptf :: fmt.printf
	CM_NOTIFY :: WM_USER + 1
	CM_CTLLCOLOR :: WM_USER + 2
	CM_LABELDRAW :: WM_USER + 3
	CM_LMOUSECLICK :: WM_USER + 4
	CM_RMOUSECLICK :: WM_USER + 5
	CM_TBTXTCHANGED :: WM_USER + 6
	CM_CBCOLOR :: WM_USER  + 7
	CM_CTLCOMMAND :: WM_USER + 8
	CM_PARENTNOTIFY :: WM_USER + 9
	CM_COMBOLBCOLOR :: WM_USER + 10
	CM_COMBOTBCOLOR :: WM_USER + 11
	CM_GBFORECOLOR :: WM_USER + 12

// My Own messages

// All controls has a default back & fore color.
def_back_clr :: 0xFFFFFF
def_fore_clr :: 0x000000

// Controls like window & button wants to paint themselve with a gradient brush.
// In that cases, we need an option for painting in two directions.
// So this enum will be used in controls which had the ebility to draw a gradient bkgnd.
GradientStyle :: enum {top_to_bottom, left_to_right,}
TextAlignment :: enum {top_left, top_center, top_right, mid_left, center, mid_right, bottom_left, bottom_center, bottom_right}
SimpleTextAlignment :: enum {left, center, right}


TimeMode :: enum {nano_sec, micro_sec, milli_sec}

Time :: struct {_nano_sec : i64,}
SizeIncrement :: struct {width, height : int,}
WordValue :: enum {low, high}

current_time_internal :: proc() -> Time {
	ftime : FILETIME
	GetSysTimeAsFileTime(&ftime)
	ns := FILETIME_as_unix_nanoseconds(ftime)
	return Time{_nano_sec = ns} 
}

current_filetime :: proc(tm : TimeMode) -> i64 {
	result : i64
	n := current_time_internal()
	switch tm {
		case .nano_sec : result = n._nano_sec
		case .micro_sec : result = n._nano_sec / 1000
		case .milli_sec : result = n._nano_sec / 1000000
	}
	return result
}

@private get_ctrl_text_internal :: proc(hw : Hwnd, alloc := context.allocator) -> string {
	tlen := GetWindowTextLength(hw) 	
	mem_chunks := make([]Wchar, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	defer delete(mem_chunks)	
	GetWindowText(hw, wsBuffer, i32(len(mem_chunks)))
	return wstring_to_utf8(wsBuffer, -1)
}

@private calculate_ctl_size :: proc(c : ^Control) {
    hdc := GetDC(c.handle)
    defer DeleteDC(hdc)
    ctl_size : Size            
    select_gdi_object(hdc, c.font.handle)
    GetTextExtentPoint32(hdc, to_wstring(c.text), i32(len(c.text)), &ctl_size )
    c.width = int(ctl_size.width) + c._size_incr.width
    c.height = int(ctl_size.height) + c._size_incr.height       
    MoveWindow(c.handle, i32(c.xpos), i32(c.ypos), i32(c.width), i32(c.height), true )
	print("ctl size - ", ctl_size)
}

@private in_range :: proc(value, min_val, max_val : i32) -> bool {
	if value > min_val && value < max_val do return true
	return false
}

concat_number1 :: proc(value : string, num : int ) -> string {return fmt.tprint(args = {value, num},sep = "")}
concat_number2 :: proc(value : string, num : uint ) -> string {return fmt.tprint(args = {value, num},sep = "")}

direct_cast :: proc(value : $T, $tp : typeid) -> tp {
	up := cast(uintptr) value
	return cast(tp) up
}

convert_to :: proc($tp : typeid, value : $T) -> tp {
	up := cast(uintptr) cast(rawptr) value
	return cast(tp) up
}

to_dwptr :: proc(ctl : ^Control) -> DwordPtr {
	up := cast(uintptr) ctl
	return cast(DwordPtr) up
}

get_rect :: proc(hw : Hwnd) -> Rect {
	rct : Rect
	GetClientRect(hw, &rct)
	return rct
}

get_win_rect :: proc(hw : Hwnd) -> Rect {
	rc : Rect
	GetWindowRect(hw, &rc)
	return rc
}

make_dword :: proc(lo_val, hi_val, : $T) -> Dword {
	hv := cast(Word) hi_val
    lv := cast(Word) lo_val
	dw_val := Dword(Dword(lv) | (Dword(hv)) << 16) 
	return dw_val
}
// left = loword, right side - highword

// There a lot of time we need to convert a handle like HBrush to HGDIOBJ.
// This proc will help for it. 
to_hgdi_obj :: proc(value : $T ) -> Hgdiobj {return cast(Hgdiobj) value}
to_lresult :: proc(value : $T) -> Lresult {
	up := cast(uintptr) value
	return cast(Lresult) up
}

concat_number :: proc{concat_number1, concat_number2}

// If we want to get the virtual key code (VK_KEY_NUMPAD1 etc) from lparam...
// in any keyboard related message, this proc helps to extract it
get_virtual_key :: proc(value : Lparam) -> u32 {
	scan_code : u32 = u32(value >> 16 )
    return MapVirtualKey(scan_code, MAPVK_VSC_TO_VK)
}


get_x_lparam :: proc(lpm : Lparam) -> int { return int(i16(loword_lparam(lpm)))}
get_y_lparam :: proc(lpm : Lparam) -> int { return int(i16(hiword_lparam(lpm)))}


loword_wparam :: #force_inline proc "contextless" (x : Wparam) -> Word { return Word(x & 0xffff)}
hiword_wparam :: #force_inline proc "contextless" (x : Wparam) -> Word { return Word(x >> 16)}
loword_lparam :: #force_inline proc "contextless" (x : Lparam) -> Word { return Word(x & 0xffff)}
hiword_lparam :: #force_inline proc "contextless" (x : Lparam) -> Word { return Word(x >> 16)}


@private select_gdi_object :: proc(hd : Hdc, obj : $T) {
	gdi_obj := cast(Hgdiobj) obj
	SelectObject(hd, gdi_obj)
}

@private delete_gdi_object :: proc(obj : $T) {
	gdi_obj := cast(Hgdiobj) obj
	DeleteObject(gdi_obj)
}




@private dynamic_array_search :: proc(arr : [dynamic]$T, item : T) -> (index : int, is_found : bool) {
	for i := 0 ; i < len(arr) ; i += 1 {
		if arr[i] == item {
			index = i
			is_found = true
			break
		}
	}
	return index, is_found
} 

@private static_array_search :: proc(arr : []$T, item : T) -> (index : int, is_found : bool) {
	for i := 0 ; i < len(arr) ; i += 1 {
		if arr[i] == item {
			index = i
			is_found = true
			break
		}
	}
	return index, is_found
} 

array_search :: proc{	dynamic_array_search,
						static_array_search,
}

// This proc will return an Hbrush to paint the window or a button in gradient colors.
@private create_gradient_brush :: proc(gc : GradientColors, gs : GradientStyle, hdc : Hdc, rct : Rect) -> Hbrush {	
	t_brush : Hbrush
	mem_hdc : Hdc = CreateCompatibleDC(hdc)
	hbmp : Hbitmap = CreateCompatibleBitmap(hdc, rct.right, rct.bottom)
	loop_end : i32 = rct.bottom if gs == .top_to_bottom else rct.right 
	
	SelectObject(mem_hdc, Hgdiobj(hbmp))	
	i : i32		
	for i = 0; i < loop_end; i += 1 {
		t_rct : Rect
		r, g, b : uint	

		r = gc.color1.red + uint((i * i32(gc.color2.red - gc.color1.red) / loop_end))
        g = gc.color1.green + uint((i * i32(gc.color2.green - gc.color1.green) / loop_end))
        b = gc.color1.blue + uint((i * i32(gc.color2.blue - gc.color1.blue) / loop_end))
		t_brush = CreateSolidBrush(get_color_ref(r, g, b))
		
		t_rct.left = 0 if gs == .top_to_bottom else i
		t_rct.top = i if gs == .top_to_bottom else 0
		t_rct.right = rct.right if gs == .top_to_bottom else i + 1
		t_rct.bottom = i + 1 if gs == .top_to_bottom else loop_end
		FillRect(mem_hdc, &t_rct, t_brush)
		DeleteObject(Hgdiobj(t_brush))
	}
	gradient_brush : Hbrush = CreatePatternBrush(hbmp)
	DeleteDC(mem_hdc)
	DeleteObject(Hgdiobj(t_brush))
	DeleteObject(Hgdiobj(hbmp))
	return gradient_brush
}


@private print_rect :: proc(rc : Rect) {
	ptf("top : %d\n", rc.top)
	ptf("bottom : %d\n", rc.bottom)
	ptf("left : %d\n", rc.left)
	ptf("right : %d\n", rc.right)
	print("----------------------------------------------------")
}

Test :: proc() {
	dw : Dword = 100 | 200 | 300
	ptf("dw in decimal %d\n", dw)
	ptf("dw in binary %b\n", dw)
	ptf("dw in hex %X\n", dw)


}