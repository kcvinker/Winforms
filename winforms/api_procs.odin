// A header file for all win32 related functions & types

package winforms

//import "core:strings"
//import "core:fmt"

//=================================== Functions===================================

to_wstring :: proc(value : string) -> wstring {return utf8_to_wstring(value)}
to_string :: proc(value : wstring) -> string {return wstring_to_utf8(value, -1)}

lo_word :: #force_inline proc "contextless" (x: Dword) -> Word {return Word(x & 0xffff)}
hi_word :: #force_inline proc "contextless" (x: Dword) -> Word {return Word(x >> 16)}


utf8_to_utf16 :: proc(s: string, allocator := context.temp_allocator) -> []u16 {
   if len(s) < 1 { return nil }
   b := transmute([]byte)s
   cstr := raw_data(b)
   n := multibyte_to_wchar(CP_UTF8, MB_ERR_INVALID_CHARS, cast(cstring) cstr, i32(len(s)), nil, 0)
   if n == 0 {return nil}
   text := make([]u16, n+1, allocator)
   n1 := multibyte_to_wchar(CP_UTF8, MB_ERR_INVALID_CHARS, cast(cstring) cstr, i32(len(s)), raw_data(text), n)
   if n1 == 0 {
      delete(text, allocator)
      return nil
   }
   text[n] = 0
   for n >= 1 && text[n-1] == 0 {
      n -= 1
   }
   return text[:n]
}

utf8_to_wstring :: proc(s: string, allocator := context.temp_allocator) -> wstring {
   if res := utf8_to_utf16(s, allocator); res != nil {
      //fmt.println("become utf16,", res);
      return &res[0]
   }
   return nil
}

wstring_to_utf8 :: proc(s: wstring, N: int, allocator := context.temp_allocator) -> string {
   if N == 0 {
      return ""
   }

   n := wchar_to_multibyte(CP_UTF8, WC_ERR_INVALID_CHARS, s, i32(N), nil, 0, nil, nil)
   if n == 0 {
      return ""
   }

   // If N == -1 the call to WideCharToMultiByte assume the wide string is null terminated
   // and will scan it to find the first null terminated character. The resulting string will
   // also null terminated.
   // If N != -1 it assumes the wide string is not null terminated and the resulting string
   // will not be null terminated, we therefore have to force it to be null terminated manually.
   text := make([]byte, n+1 if N != -1 else n, allocator)

   n1 := wchar_to_multibyte(CP_UTF8, WC_ERR_INVALID_CHARS, s, i32(N), cast(cstring) raw_data(text), n, nil, nil)
   if n1 == 0 {
      delete(text, allocator)
      return ""
   }

   for i in 0..<n {
      if text[i] == 0 {
         n = i
         break
      }
   }

   return string(text[:n])
}

utf16_to_utf8 :: proc(s: []u16, allocator := context.temp_allocator) -> string {
   if len(s) == 0 {
      return ""
   }
   return wstring_to_utf8(raw_data(s), len(s), allocator)
}

make_int_resource::proc(value : uint) -> wstring {return wstring(rawptr(uintptr(value))) }

FILETIME_as_unix_nanoseconds :: proc "contextless" (ft: FILETIME) -> i64 {
	t := i64(u64(ft.dwLowDateTime) | u64(ft.dwHighDateTime) << 32)
	return (t - 0x019db1ded53e8000) * 100
}



foreign import "system:user32.lib"
@(default_calling_convention = "std")
foreign user32 {
   @(link_name="RegisterClassExW") register_class_ex_w :: proc(wc: ^WNDCLASSEXW) -> i16 ---
   @(link_name="LoadIconW")        load_icon_w         :: proc(instance: Hinstance, icon_name: wstring) -> Hicon ---
   @(link_name="LoadCursorW")      load_cursor_w       :: proc(instance: Hinstance, cursor_name: wstring) -> Hcursor ---

   @(link_name="CreateWindowExW") create_window_ex :: proc(  ex_style: u32, 
                                                               class_name, title: wstring, 
                                                               style: u32, 
                                                               x, y, w, h: i32, 
                                                               parent: Hwnd, 
                                                               menu: Hmenu, 
                                                               instance: Hinstance, 
                                                               param: rawptr) -> Hwnd ---

   @(link_name="SetWindowLongPtrW") set_window_long_ptr :: proc(wnd: Hwnd, index: i32, new_long: LongPtr) -> LongPtr ---
   @(link_name="GetWindowLongPtrW") get_window_long_ptr :: proc(wnd: Hwnd, index: i32) -> LongPtr ---
   @(link_name="GetMessageW") get_message_w :: proc(msg: ^Msg, hwnd: Hwnd, msg_filter_min, msg_filter_max: u32) -> i32 ---
   @(link_name="TranslateMessage") translate_message  :: proc(msg: ^Msg) -> Bool ---
   @(link_name="DispatchMessageW") dispatch_message_w :: proc(msg: ^Msg) -> Lresult ---
   @(link_name="UpdateWindow") update_window :: proc(hwnd: Hwnd) -> Bool ---
   @(link_name="DefWindowProcW") def_window_proc_w :: proc(hwnd: Hwnd, msg: u32, wparam: Wparam, lparam: Lparam) -> Lresult ---
   @(link_name="ShowWindow") showing_window :: proc(hwnd: Hwnd, nCmdShow: i32) -> Bool ---
   @(link_name="PostQuitMessage") post_quit_message :: proc(nExitCode: i32) ---
   @(link_name="GetDC") get_dc :: proc(h: Hwnd) -> Hdc ---
   @(link_name="ReleaseDC") release_dc :: proc(wnd: Hwnd, hdc: Hdc) -> i32 ---
   @(link_name="SendMessageW") send_message :: proc(hwnd: Hwnd, msg: u32, wparam: Wparam, lparam: Lparam) -> Lresult ---
   @(link_name="MessageBoxW") message_box :: proc(wnd: Hwnd, text, caption: wstring, type: u32) -> i32 ---
   @(link_name="MapVirtualKeyW") map_virtual_key :: proc(u_code: u32, u_map_type : u32) -> u32 ---
   @(link_name="TrackMouseEvent") track_mouse_event :: proc(lp_tme: ^TrackMouseEvent) -> Bool ---
   @(link_name="GetClientRect") get_client_rect :: proc(hwnd: Hwnd, rect: ^Rect) -> Bool ---
   @(link_name="InvalidateRect") invalidate_rect :: proc(hwnd: Hwnd, rect: ^Rect, berase : Bool) -> Bool ---
   @(link_name="SetWindowPos") set_window_pos :: proc(hwnd, hw_ins_after: Hwnd, x, y, cx, cy : i32, flags : u32) -> Bool ---
   @(link_name="SetWindowTextW") set_window_text :: proc(hwnd : Hwnd, lp_string : wstring) -> Bool ---
   @(link_name="GetWindowTextW") get_window_text :: proc(hwnd : Hwnd, lp_string : wstring, count : i32) -> i32 ---
   @(link_name="GetWindowTextLengthW") get_window_text_length :: proc(hwnd : Hwnd) -> i32 ---
   @(link_name="DrawTextW") draw_text :: proc(hdc : Hdc, lp_txt : wstring, cch_txt : i32, lprc : ^Rect, format : Uint) -> i32 ---
   @(link_name="InflateRect") inflate_rect :: proc(lprct : ^Rect, dx, dy : i32) -> Bool ---
   @(link_name="RedrawWindow") redraw_window :: proc(hw : Hwnd, lprct : ^Rect, upd_rgn : Hrgn, flags : Uint) -> Bool ---
   @(link_name="MoveWindow") move_window :: proc(hw : Hwnd, x, y, w, h : i32, repaint : Bool) -> Bool ---
   @(link_name="PostMessageW") post_message :: proc(hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam) -> Bool ---
   @(link_name="FrameRect") frame_rect :: proc(dch : Hdc, rct : ^Rect, hbr : Hbrush) -> i32 ---
   @(link_name="DrawEdge") draw_edge :: proc(dch : Hdc, rct : ^Rect, edge, gr_flags : u32) -> Bool ---
   @(link_name="BeginPaint") begin_paint :: proc(hw : Hwnd, lp_paint : ^PAINTSTRUCT) -> Hdc ---
   @(link_name="EndPaint") end_paint :: proc(hw : Hwnd, lp_paint : ^PAINTSTRUCT) -> Bool ---
   @(link_name="GetClassLongPtrW") get_class_long_ptr :: proc(hw : Hwnd, indx : i32) -> u64 ---
   @(link_name="GetClassLongW") get_class_long :: proc(hw : Hwnd, indx : i32) -> u64 ---
   @(link_name="DestroyWindow") destroy_window :: proc(hw : Hwnd) -> Bool ---
   @(link_name="GetCursorPos") get_cursror_pos :: proc(pt : ^Point) -> Bool ---
   @(link_name="ScreenToClient") screen_to_client :: proc(hw : Hwnd, pt : ^Point) -> Bool ---
   @(link_name="WindowFromPoint") window_from_point :: proc(pt : Point) -> Hwnd ---
   @(link_name="EnableWindow") enable_window :: proc(hw : Hwnd, bEnable : bool) -> Bool ---
   @(link_name="SetFocus") set_focus :: proc(hw : Hwnd) -> Hwnd ---
   @(link_name="GetFocus") get_focus :: proc() -> Hwnd ---
   @(link_name="SetActiveWindow") set_active_window :: proc(hw : Hwnd) -> Hwnd ---
   


} // User32 library



foreign import "system:kernel32.lib"
@(default_calling_convention = "std")
foreign kernel32 {
   @(link_name="GetLastError") get_last_error :: proc() -> Dword ---
   @(link_name="GetModuleHandleW") get_module_handle_w :: proc(module_name: wstring) -> Hinstance ---
   @(link_name="GetSystemMetrics") get_system_metrics :: proc(index: i32) -> i32 ---
   @(link_name="MultiByteToWideChar") multibyte_to_wchar :: proc(code_page: u32, flags: u32,
                                                                      mb_str: cstring, mb: i32,
                                                                      wc_str: wstring, wc: i32) -> i32 ---
   @(link_name="WideCharToMultiByte") wchar_to_multibyte :: proc(code_page: u32, flags: u32,
                                                                      wchar_str: wstring, wchar: i32,
                                                                      multi_str: cstring, multi: i32,
                                                                      default_char: cstring, used_default_char: ^Bool) -> i32 ---
   @(link_name="MulDiv") mul_div :: proc(nNumber, nNumerator, nDenominator : i32) -> i32 ---
   @(link_name="GetSystemTimeAsFileTime") get_systemtime_as_filetime :: proc(pfile_time : ^FILETIME) ---
   @(link_name="GetSystemTime") get_system_time :: proc(sys_time : ^SYSTEMTIME) ---
   @(link_name="GetLocalTime") get_local_time :: proc(sys_time : ^SYSTEMTIME) ---

} // Kernel32 library

foreign import "system:gdi32.lib"
@(default_calling_convention = "std")
foreign gdi32 {
   @(link_name="CreateSolidBrush") create_solid_brush :: proc(color: ColorRef) -> Hbrush ---
   @(link_name="CreateFontW") create_font :: proc(cHeight, cWidth, cEscapement, cOrientation, cWeight : i32,
                                                   bItalic, bUnderline, bStrikeOut : Dword,
                                                   iCharSet, iOutPrecision, iClipPrecision : Dword,
                                                   iQuality, iPitchAndFamily : Dword,
                                                   pszFaceName : wstring ) -> Hfont ---
   @(link_name="GetDeviceCaps") get_device_caps :: proc(hdc: Hdc, index : i32) -> i32 ---
   @(link_name="FillRect") fill_rect :: proc(hdc: Hdc, rct : ^Rect, hb : Hbrush) -> i32 ---
   @(link_name="DeleteObject") delete_object :: proc(hgdi_obj: Hgdiobj) -> Bool ---
   @(link_name="CreateCompatibleDC") create_compatible_dc :: proc(hdc: Hdc) -> Hdc ---
   @(link_name="CreateCompatibleBitmap") create_compatible_bitmap :: proc(hdc: Hdc, cx, cy : i32) -> Hbitmap ---
   @(link_name="SelectObject") select_object :: proc(hdc: Hdc, hobj : Hgdiobj) -> Hgdiobj ---
   @(link_name="CreatePatternBrush") create_pattern_brush :: proc(hbmp : Hbitmap) -> Hbrush ---
   @(link_name="DeleteDC") delete_dc :: proc(hdc : Hdc) -> Bool ---
   @(link_name="SetTextColor") set_text_color :: proc(hdc : Hdc, clr : ColorRef) -> ColorRef ---
   @(link_name="SetBkMode") set_bk_mode :: proc(hdc : Hdc, mode : i32) -> i32 ---
   @(link_name="Rectangle") draw_rectangle :: proc(hdc : Hdc, left, top, right, bottom : i32) -> Bool ---
   @(link_name="CreatePen") create_pen :: proc(style, width : i32, cref : ColorRef) -> Hpen ---
   @(link_name="GetTextExtentPoint32W") get_text_extent_point :: proc(dch : Hdc, 
                                                                        lp_string : wstring, 
                                                                        str_len : i32, 
                                                                        psize : ^Size) -> Bool ---
   @(link_name="SetBkColor") set_bk_color :: proc(dchandle : Hdc, cref : ColorRef) -> ColorRef ---   
   @(link_name="GetStockObject") get_stock_object :: proc(fn_object : i32) -> Hgdiobj ---
   @(link_name="SaveDC") save_dc :: proc(dch : Hdc) -> i32 ---
   @(link_name="RestoreDC") restore_dc :: proc(dch : Hdc, ndc : i32) -> Bool ---
   

} // Gdi32 library

foreign import "system:Comctl32.lib"
@(default_calling_convention = "std")
foreign Comctl32 {
   @(link_name="SetWindowSubclass") set_windows_subclass :: proc(hw : Hwnd, pfn : SUBCLASSPROC, uid : UintPtr, rd : DwordPtr) -> Bool ---
   @(link_name="DefSubclassProc") def_subclass_proc :: proc(hw : Hwnd, ms : u32, wpm : Wparam, lpm : Lparam) -> Lresult ---
   @(link_name="RemoveWindowSubclass") remove_window_subclass :: proc(hw : Hwnd, pfn : SUBCLASSPROC, uid : UintPtr) -> Bool ---
   @(link_name="InitCommonControlsEx") init_comm_ctrl_ex :: proc(picc_ex : ^INITCOMMONCONTROLSEX) -> Bool ---

} // Comctrl library

foreign import "system:UxTheme.lib"
@(default_calling_convention = "std")
foreign UxTheme {
   @(link_name="SetWindowTheme") set_window_theme :: proc(hw : Hwnd, sub_app : wstring, sub_id : wstring) -> Hresult ---

}
