// A header file for all win32 related functions & types

package winforms

//import "core:strings"
//import "core:fmt"
// import "core"

//=================================== Functions===================================

to_wstring :: proc(value : string) -> wstring {return utf8_to_wstring(value)}
to_string :: proc(value : wstring) -> string {return wstring_to_utf8(value, -1)}

lo_word :: #force_inline proc "contextless" (x: Dword) -> Word {return Word(x & 0xffff)}
hi_word :: #force_inline proc "contextless" (x: Dword) -> Word {return Word(x >> 16)}


utf8_to_utf16 :: proc(s: string, allocator := context.temp_allocator) -> []u16 {
   if len(s) < 1 { return nil }
   b := transmute([]byte)s
   cstr := raw_data(b)
   n := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, cast(cstring) cstr, -1, nil, 0)
   if n == 0 {return nil}
   text := make([]u16, n+1, allocator)
   n1 := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, cast(cstring) cstr, i32(len(s)), raw_data(text), n)
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

   n := WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, s, i32(N), nil, 0, nil, nil)
   if n == 0 {
      return ""
   }

   // If N == -1 the call to WideCharToMultiByte assume the wide string is null terminated
   // and will scan it to find the first null terminated character. The resulting string will
   // also null terminated.
   // If N != -1 it assumes the wide string is not null terminated and the resulting string
   // will not be null terminated, we therefore have to force it to be null terminated manually.
   text := make([]byte, n+1 if N != -1 else n, allocator)

   n1 := WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, s, i32(N), cast(cstring) raw_data(text), n, nil, nil)
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

// enable_window :: proc(hw : Hwnd, bEnable : bool) -> Bool {
//    return EnableWindow(hw, bEnable)
// }


foreign import "system:user32.lib"
@(default_calling_convention = "std")
foreign user32 {
   @(link_name="RegisterClassExW") RegisterClassEx :: proc(wc: ^WNDCLASSEXW) -> i16 ---
   @(link_name="LoadIconW") LoadIcon :: proc(instance: Hinstance, icon_name: wstring) -> Hicon ---
   @(link_name="LoadCursorW") LoadCursor :: proc(instance: Hinstance, cursor_name: wstring) -> Hcursor ---

   @(link_name="CreateWindowExW") CreateWindowEx :: proc(  ex_style: u32,
                                                            class_name, title: wstring,
                                                            style: u32,
                                                            #any_int x, y, w, h: i32,
                                                            parent: Hwnd,
                                                            menu: Hmenu,
                                                            instance: Hinstance,
                                                            param: rawptr) -> Hwnd ---

   @(link_name="SetWindowLongPtrW") SetWindowLongPtr :: proc(wnd: Hwnd, index: i32, new_long: LongPtr) -> LongPtr ---
   @(link_name="GetWindowLongPtrW") GetWindowLongPtr :: proc(wnd: Hwnd, index: i32) -> LongPtr ---
   @(link_name="GetMessageW") GetMessage :: proc(msg: ^Msg, hwnd: Hwnd, msg_filter_min, msg_filter_max: u32) -> i32 ---
   @(link_name="TranslateMessage") TranslateMessage  :: proc(msg: ^Msg) -> Bool ---
   @(link_name="DispatchMessageW") DispatchMessage :: proc(msg: ^Msg) -> Lresult ---
   @(link_name="UpdateWindow") UpdateWindow :: proc(hwnd: Hwnd) -> Bool ---
   @(link_name="DefWindowProcW") DefWindowProc :: proc(hwnd: Hwnd, msg: u32, wparam: Wparam, lparam: Lparam) -> Lresult ---
   @(link_name="ShowWindow") ShowWindow :: proc(hwnd: Hwnd, nCmdShow: i32) -> Bool ---
   @(link_name="PostQuitMessage") PostQuitMessage :: proc(nExitCode: i32) ---
   @(link_name="GetDC") GetDC :: proc(h: Hwnd) -> Hdc ---
   @(link_name="ReleaseDC") ReleaseDC :: proc(wnd: Hwnd, hdc: Hdc) -> i32 ---
   @(link_name="SendMessageW") SendMessage :: proc(hwnd: Hwnd, msg: u32, wparam: Wparam, lparam: Lparam) -> Lresult ---
   @(link_name="MessageBoxW") MessageBox :: proc(wnd: Hwnd, text, caption: wstring, type: u32) -> i32 ---
   @(link_name="MapVirtualKeyW") MapVirtualKey :: proc(u_code: u32, u_map_type : u32) -> u32 ---
   @(link_name="TrackMouseEvent") TrackMouseEvent :: proc(lp_tme: ^TRACKMOUSEEVENT) -> Bool ---
   @(link_name="GetClientRect") GetClientRect :: proc(hwnd: Hwnd, rect: ^Rect) -> Bool ---
   @(link_name="InvalidateRect") InvalidateRect :: proc(hwnd: Hwnd, rect: ^Rect, berase : Bool) -> Bool ---
   @(link_name="SetWindowPos") SetWindowPos :: proc(hwnd, hw_ins_after: Hwnd, x, y, cx, cy : i32, flags : u32) -> Bool ---
   @(link_name="SetWindowTextW") SetWindowText :: proc(hwnd : Hwnd, lp_string : wstring) -> Bool ---
   @(link_name="GetWindowTextW") GetWindowText :: proc(hwnd : Hwnd, lp_string : wstring, count : i32) -> i32 ---
   @(link_name="GetWindowTextLengthW") GetWindowTextLength :: proc(hwnd : Hwnd) -> i32 ---
   @(link_name="DrawTextW") DrawText :: proc(hdc : Hdc, lp_txt : wstring, cch_txt : i32, lprc : ^Rect, format : Uint) -> i32 ---
   @(link_name="InflateRect") InflateRect :: proc(lprct : ^Rect, dx, dy : i32) -> Bool ---
   @(link_name="RedrawWindow") RedrawWindow :: proc(hw : Hwnd, lprct : ^Rect, upd_rgn : Hrgn, flags : Uint) -> Bool ---
   @(link_name="MoveWindow") MoveWindow :: proc(hw : Hwnd, x, y, w, h : i32, repaint : Bool) -> Bool ---
   @(link_name="PostMessageW") PostMessage :: proc(hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam) -> Bool ---
   @(link_name="FrameRect") FrameRect :: proc(dch : Hdc, rct : ^Rect, hbr : Hbrush) -> i32 ---
   @(link_name="DrawEdge") DrawEdge :: proc(dch : Hdc, rct : ^Rect, edge, gr_flags : u32) -> Bool ---
   @(link_name="BeginPaint") BeginPaint :: proc(hw : Hwnd, lp_paint : ^PAINTSTRUCT) -> Hdc ---
   @(link_name="EndPaint") EndPaint :: proc(hw : Hwnd, lp_paint : ^PAINTSTRUCT) -> Bool ---
   @(link_name="GetClassLongPtrW") GetClassLongPtr :: proc(hw : Hwnd, indx : i32) -> u64 ---
   //@(link_name="GetClassLongW") GetClassLong :: proc(hw : Hwnd, indx : i32) -> u64 ---
   @(link_name="DestroyWindow") DestroyWindow :: proc(hw : Hwnd) -> Bool ---
   @(link_name="GetCursorPos") GetCursorPos :: proc(pt : ^Point) -> Bool ---
   @(link_name="ScreenToClient") ScreenToClient :: proc(hw : Hwnd, pt : ^Point) -> Bool ---
   @(link_name="WindowFromPoint") WindowFromPoint :: proc(pt : Point) -> Hwnd ---
   @(link_name="EnableWindow") EnableWindow :: proc(hw : Hwnd, bEnable : bool) -> Bool ---
   @(link_name="HideCaret") HideCaret :: proc(hw : Hwnd) -> Bool ---
   @(link_name="PtInRect") PtInRect :: proc(lprc : ^Rect, pt : Point) -> Bool ---
   @(link_name="SetFocus") SetFocus :: proc(hw : Hwnd) -> Hwnd ---
   @(link_name="GetFocus") GetFocus :: proc() -> Hwnd ---
   @(link_name="SetActiveWindow") SetActiveWindow :: proc(hw : Hwnd) -> Hwnd ---
   @(link_name="GetDCEx") GetDCEx :: proc(hw : Hwnd, clp_rgn : Hrgn, flags : Dword) -> Hdc ---
   @(link_name="GetWindowRect") GetWindowRect :: proc(hw : Hwnd, pRc : ^Rect) -> Bool ---
   @(link_name="DestroyIcon") DestroyIcon :: proc(hIco : Hicon) -> Bool ---
   @(link_name="LoadImageW") LoadImage :: proc(hInst : Hinstance,
                                                img_name : wstring,
                                                img_type : u32,
                                                cx, cy : i32,
                                                fuLoad : u32 ) -> Handle ---



} // User32 library



foreign import "system:kernel32.lib"
@(default_calling_convention = "std")
foreign kernel32 {
   @(link_name="GetLastError") GetLastError :: proc() -> Dword ---
   @(link_name="GetModuleHandleW") GetModuleHandle :: proc(module_name: wstring) -> Hinstance ---
   @(link_name="GetSystemMetrics") GetSystemMetrics :: proc(index: i32) -> i32 ---
   @(link_name="MultiByteToWideChar") MultiByteToWideChar :: proc(code_page: u32, flags: u32,
                                                                      mb_str: cstring, mb: i32,
                                                                      wc_str: wstring, wc: i32) -> i32 ---
   @(link_name="WideCharToMultiByte") WideCharToMultiByte :: proc(code_page: u32, flags: u32,
                                                                      wchar_str: wstring, wchar: i32,
                                                                      multi_str: cstring, multi: i32,
                                                                      default_char: cstring, used_default_char: ^Bool) -> i32 ---
   @(link_name="MulDiv") MulDiv :: proc(nNumber, nNumerator, nDenominator : i32) -> i32 ---
   @(link_name="GetSystemTimeAsFileTime") GetSysTimeAsFileTime :: proc(pfile_time : ^FILETIME) ---
   @(link_name="GetSystemTime") GetSystemTime :: proc(sys_time : ^SYSTEMTIME) ---
   @(link_name="GetLocalTime") GetLocalTime :: proc(sys_time : ^SYSTEMTIME) ---
   @(link_name="Sleep") Sleep :: proc(milli_sec : Dword) ---

   @(link_name="GetPrivateProfileStringA") GetPrivateProfileString :: proc(lpAppName : cstring,
                                                                           lpKeyName : cstring,
                                                                           lpDefault : cstring,
                                                                           lpReturn : ^byte,
                                                                           nSize : Dword,
                                                                           lpFileName : cstring) -> Dword ---


} // Kernel32 library

foreign import "system:gdi32.lib"
@(default_calling_convention = "std")
foreign gdi32 {
   @(link_name="CreateSolidBrush") CreateSolidBrush :: proc(color: ColorRef) -> Hbrush ---
   @(link_name="CreateFontW") CreateFont :: proc(cHeight, cWidth, cEscapement, cOrientation, cWeight : i32,
                                                   bItalic, bUnderline, bStrikeOut : Dword,
                                                   iCharSet, iOutPrecision, iClipPrecision : Dword,
                                                   iQuality, iPitchAndFamily : Dword,
                                                   pszFaceName : wstring ) -> Hfont ---
   @(link_name="GetDeviceCaps") GetDeviceCaps :: proc(hdc: Hdc, index : i32) -> i32 ---
   @(link_name="FillRect") FillRect :: proc(hdc: Hdc, rct : ^Rect, hb : Hbrush) -> i32 ---
   @(link_name="DeleteObject") DeleteObject :: proc(hgdi_obj: Hgdiobj) -> Bool ---
   @(link_name="CreateCompatibleDC") CreateCompatibleDC :: proc(hdc: Hdc) -> Hdc ---
   @(link_name="CreateCompatibleBitmap") CreateCompatibleBitmap :: proc(hdc: Hdc, cx, cy : i32) -> Hbitmap ---
   @(link_name="SelectObject") SelectObject :: proc(hdc: Hdc, hobj : Hgdiobj) -> Hgdiobj ---
   @(link_name="CreatePatternBrush") CreatePatternBrush :: proc(hbmp : Hbitmap) -> Hbrush ---
   @(link_name="DeleteDC") DeleteDC :: proc(hdc : Hdc) -> Bool ---
   @(link_name="SetTextColor") SetTextColor :: proc(hdc : Hdc, clr : ColorRef) -> ColorRef ---
   @(link_name="SetBkMode") SetBkMode :: proc(hdc : Hdc, mode : i32) -> i32 ---
   @(link_name="Rectangle") Rectangle :: proc(hdc : Hdc, left, top, right, bottom : i32) -> Bool ---
   @(link_name="CreatePen") CreatePen :: proc(style, #any_int width : i32, cref : ColorRef) -> Hpen ---
   @(link_name="GetTextExtentPoint32W") GetTextExtentPoint32 :: proc(dch : Hdc,
                                                                        lp_string : wstring,
                                                                        str_len : i32,
                                                                        psize : ^Size) -> Bool ---
   @(link_name="SetBkColor") SetBackColor :: proc(dchandle : Hdc, cref : ColorRef) -> ColorRef ---
   @(link_name="GetStockObject") GetStockObject :: proc(fn_object : i32) -> Hgdiobj ---
   @(link_name="SaveDC") SaveDC :: proc(dch : Hdc) -> i32 ---
   @(link_name="RestoreDC") RestoreDC :: proc(dch : Hdc, ndc : i32) -> Bool ---
   @(link_name="Ellipse") Ellipse :: proc(dch : Hdc, #any_int left, top, right, bottom : i32) -> Bool ---
   @(link_name="Polygon") Polygon :: proc(dch : Hdc, pArr : [^]Point, #any_int cpt : i32) -> Bool ---
   @(link_name="Polyline") Polyline :: proc(dch : Hdc, pArr : rawptr, #any_int cpt : i32) -> Bool ---
   @(link_name="MoveToEx") MoveToEx :: proc(dch : Hdc, #any_int x, y : i32, lppt : ^Point) -> Bool ---
   @(link_name="LineTo") LineTo :: proc(dch : Hdc, #any_int x, y : i32) -> Bool ---


} // Gdi32 library

foreign import "system:Comctl32.lib"
@(default_calling_convention = "std")
foreign Comctl32 {
   @(link_name="SetWindowSubclass") SetWindowSubclass :: proc(hw : Hwnd, pfn : SUBCLASSPROC, uid : UintPtr, rd : DwordPtr) -> Bool ---
   @(link_name="DefSubclassProc") DefSubclassProc :: proc(hw : Hwnd, ms : u32, wpm : Wparam, lpm : Lparam) -> Lresult ---
   @(link_name="RemoveWindowSubclass") RemoveWindowSubclass :: proc(hw : Hwnd, pfn : SUBCLASSPROC, uid : UintPtr) -> Bool ---
   @(link_name="InitCommonControlsEx") InitCommonControlsEx :: proc(picc_ex : ^INITCOMMONCONTROLSEX) -> Bool ---
   @(link_name="ImageList_Create") ImageList_Create :: proc(#any_int cx, cy : i32,
                                                            flags : u32,
                                                            #any_int cIntial,
                                                            cGrow : i32) -> HimageList ---
   @(link_name="ImageList_Destroy") ImageList_Destroy :: proc(himl : HimageList) -> Bool ---
   @(link_name="ImageList_Add") ImageList_Add :: proc(himl : HimageList, hbmImg : Hbitmap, hbmMask : Hbitmap) -> i32 ---
   @(link_name="ImageList_ReplaceIcon") ImageList_ReplaceIcon :: proc(himl : HimageList, i : i32, icon : Hicon) -> i32 ---



} // Comctrl library

foreign import "system:UxTheme.lib"
@(default_calling_convention = "std")
foreign UxTheme {
   @(link_name="SetWindowTheme") SetWindowTheme :: proc(hw : Hwnd, sub_app : wstring, sub_id : wstring) -> Hresult ---
   @(link_name="OpenThemeData") OpenThemeData :: proc(hw : Hwnd, cls_list : wstring) -> Htheme ---
   @(link_name="CloseThemeData") CloseThemeData :: proc(htd : Htheme) -> Hresult ---
   @(link_name="DrawThemeEdge") DrawThemeEdge :: proc(htd : Htheme,
                                                      hdc : Hdc,
                                                      partId, stateId : i32,
                                                      pRect : ^Rect,
                                                      uEdge : u32,
                                                      uFlags: u32,
                                                      pContRect : ^Rect) -> Hresult ---

   @(link_name="DrawThemeBackground") DrawThemeBackground :: proc(htd : Htheme,
                                                                  hdc : Hdc,
                                                                  partId, stateId : i32,
                                                                  pRect : ^Rect,
                                                                  pClipRect : ^Rect) -> Hresult ---

   @(link_name="GetThemeColor") GetThemeColor :: proc(htd : Htheme,
                                                      hdc : Hdc,
                                                      partId, stateId : i32,
                                                      propId : i32,
                                                      clr : ^ColorRef) -> Hresult ---

    @(link_name="DrawThemeBackgroundEx") DrawThemeBackgroundEx :: proc(htd : Htheme,
                                                      hdc : Hdc,
                                                      partId, stateId : i32,
                                                      pRect : ^Rect,
                                                      opts : ^DTBGOPTS) -> Hresult ---
}


foreign import "system:shell32.lib"
@(default_calling_convention = "std")
foreign shell32 {
   @(link_name="ExtractIconExW") ExtractIconEx :: proc(  lpszFile : wstring,
                                                         iconIndex : i32,
                                                         pLgicon : ^Hicon,
                                                         pSmIcon : ^Hicon,
                                                         nIcons : u32 ) -> u32 ---

}