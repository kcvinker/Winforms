package winforms
import "core:fmt"
// My Own messages

	ptf :: fmt.printf
	MSG_FIXED_VALUE :: 9000
	CM_NOTIFY :: MSG_FIXED_VALUE + 1
	CM_CTLLCOLOR :: MSG_FIXED_VALUE + 2
	CM_LABELDRAW :: MSG_FIXED_VALUE + 3
	CM_LMOUSECLICK :: MSG_FIXED_VALUE + 4
	CM_RMOUSECLICK :: MSG_FIXED_VALUE + 5
	CM_TBTXTCHANGED :: MSG_FIXED_VALUE + 6
	CM_CBCOLOR :: MSG_FIXED_VALUE  + 7
	CM_CTLCOMMAND :: MSG_FIXED_VALUE + 8
	CM_PARENTNOTIFY :: MSG_FIXED_VALUE + 9
	CM_COMBOLBCOLOR :: MSG_FIXED_VALUE + 10
	CM_COMBOTBCOLOR :: MSG_FIXED_VALUE + 11
	CM_GBFORECOLOR :: MSG_FIXED_VALUE + 12
	CM_HSCROLL :: MSG_FIXED_VALUE + 13
	CM_VSCROLL :: MSG_FIXED_VALUE + 14
	CM_TVNODEEXPAND :: MSG_FIXED_VALUE + 15



// My Own messages

// All controls has a default back & fore color.
def_back_clr :: 0xFFFFFF
def_fore_clr :: 0x000000



// Controls like window & button wants to paint themselve with a gradient brush.
// In that cases, we need an option for painting in two directions.
// So this enum will be used in controls which had the ebility to draw a gradient bkgnd.
GradientStyle :: enum {Top_To_Bottom, Left_To_Right,}
TextAlignment :: enum {Top_Left, Top_Center, Top_Right, Mid_Left, Center, Mid_Right, Bottom_Left, Bottom_Center, Bottom_Right}
SimpleTextAlignment :: enum {Left, Center, Right}
TicPosition :: enum {Down_Side, Up_Side, Left_Side, Right_Side, Both_Side} // For trackbar


TimeMode :: enum {Nano_Sec, Micro_Sec, Milli_Sec}

Time :: struct {_nano_sec : i64,}
SizeIncrement :: struct {width, height : int,}
Area :: struct {width, height : int,}
WordValue :: enum {Low, High}

to_str :: proc(value : any) -> string {return fmt.tprint(value)}





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
		case .Nano_Sec : result = n._nano_sec
		case .Micro_Sec : result = n._nano_sec / 1000
		case .Milli_Sec : result = n._nano_sec / 1000000
	}
	return result
}

create_hbrush :: proc(clr : uint) -> Hbrush {
	cref := get_color_ref(clr)
	return CreateSolidBrush(cref)
}

draw_ellipse :: proc(dch : Hdc, rc : Rect) {
	Ellipse(dch, rc.left, rc.top, rc.right, rc.bottom)
}

@private
get_ctrl_text_internal :: proc(hw : Hwnd, alloc := context.allocator) -> string {
	tlen := GetWindowTextLength(hw)
	mem_chunks := make([]Wchar, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	//defer delete(mem_chunks)
	GetWindowText(hw, wsBuffer, i32(len(mem_chunks)))
	return wstring_to_utf8(wsBuffer, -1)
}



@private
calculate_ctl_size :: proc(ctl : ^Control) {
	ss : Size
    SendMessage(ctl.handle, BCM_GETIDEALSIZE, 0, direct_cast( &ss, Lparam))
    ctl.width = int(ss.width)
    ctl.height = int(ss.height)
    MoveWindow(ctl.handle, i32(ctl.xpos), i32(ctl.ypos), ss.width, ss.height, true)
}


@private
in_range :: proc(value, min_val, max_val : i32) -> bool {
	if value > min_val && value < max_val do return true
	return false
}

@private
alert :: proc(txt : string) {
	@static cntr : int = 1
	ptf("%s - [%d]\n", txt, cntr)
	cntr += 1
}

@private
alert2 :: proc(txt : string, data : any) {
	@static cntr : int = 1
	ptf("[%d] %s - %s\n", cntr, txt, fmt.tprint(data))
	cntr += 1
}

@private




concat_number :: proc{concat_number1, concat_number2}
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


@private
select_gdi_object :: proc(hd : Hdc, obj : $T) {
	gdi_obj := cast(Hgdiobj) obj
	SelectObject(hd, gdi_obj)
}

@private
delete_gdi_object :: proc(obj : $T) {
	gdi_obj := cast(Hgdiobj) obj
	DeleteObject(gdi_obj)
}




@private
dynamic_array_search :: proc(arr : [dynamic]$T, item : T) -> (index : int, is_found : bool) {
	for i := 0 ; i < len(arr) ; i += 1 {
		if arr[i] == item {
			index = i
			is_found = true
			break
		}
	}
	return index, is_found
}

@private
static_array_search :: proc(arr : []$T, item : T) -> (index : int, is_found : bool) {
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
@private
create_gradient_brush :: proc(gc : GradientColors, gs : GradientStyle, hdc : Hdc, rct : Rect) -> Hbrush {
	t_brush : Hbrush
	mem_hdc : Hdc = CreateCompatibleDC(hdc)
	hbmp : Hbitmap = CreateCompatibleBitmap(hdc, rct.right, rct.bottom)
	loop_end : i32 = rct.bottom if gs == .Top_To_Bottom else rct.right

	SelectObject(mem_hdc, Hgdiobj(hbmp))
	i : i32
	for i = 0; i < loop_end; i += 1 {
		t_rct : Rect
		r, g, b : uint

		r = gc.color1.red + uint((i * i32(gc.color2.red - gc.color1.red) / loop_end))
        g = gc.color1.green + uint((i * i32(gc.color2.green - gc.color1.green) / loop_end))
        b = gc.color1.blue + uint((i * i32(gc.color2.blue - gc.color1.blue) / loop_end))
		t_brush = CreateSolidBrush(get_color_ref(r, g, b))

		t_rct.left = 0 if gs == .Top_To_Bottom else i
		t_rct.top = i if gs == .Top_To_Bottom else 0
		t_rct.right = rct.right if gs == .Top_To_Bottom else i + 1
		t_rct.bottom = i + 1 if gs == .Top_To_Bottom else loop_end
		FillRect(mem_hdc, &t_rct, t_brush)
		DeleteObject(Hgdiobj(t_brush))
	}
	gradient_brush : Hbrush = CreatePatternBrush(hbmp)
	DeleteDC(mem_hdc)
	DeleteObject(Hgdiobj(t_brush))
	DeleteObject(Hgdiobj(hbmp))
	return gradient_brush
}


@private
print_rect :: proc(rc : Rect) {
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

// Create a Control. Use this for all controls.
create_control :: proc(c : ^Control) {
	_global_ctl_id += 1
    c.control_id = _global_ctl_id
	c._before_creation(c)
	width : i32 = 0
	height : i32 = 0
	if c.kind != ControlKind.Number_Picker {
		width = i32(c.width)
		height = i32(c.height)
	}
    c.handle = CreateWindowEx(   c._ex_style,
                                    c._cls_name,
                                    to_wstring(c.text),
                                    c._style,
                                    i32(c.xpos),
                                    i32(c.ypos),
                                    width,
                                    height,
                                    c.parent.handle,
                                    direct_cast(c.control_id, Hmenu),
                                    app.h_instance,
                                    nil )

    if c.handle != nil {
        c._is_created = true
        setfont_internal(c)
		c._after_creation(c)
    }
}

create_controls :: proc(ctls : ..^Control) {
	for c in ctls {
		create_control(c)
	}
}