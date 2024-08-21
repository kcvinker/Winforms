// A header file for all win32 related functions & types

package winforms

//import "core:strings"
import "core:fmt"
import "base:runtime"

//=================================== Functions===================================

// lo_word :: #force_inline proc "contextless" (x: DWORD) -> WORD {return WORD(x & 0xffff)}
// hi_word :: #force_inline proc "contextless" (x: DWORD) -> WORD {return WORD(x >> 16)}

// lo_word_wpm :: #force_inline proc "contextless" (x: WPARAM) -> WORD {return WORD(x & 0xffff)}
// hi_word_wpm :: #force_inline proc "contextless" (x: WPARAM) -> WORD {return WORD(x >> 16)}


utf8_to_utf16 :: proc(s: string, allocator := context.temp_allocator) -> []u16 {
    slen := i32(len(s))
    if slen < 1 do return nil
    b := transmute([]byte)s
    cstr := raw_data(b)
    n := MultiByteToWideChar(CP_UTF8, 0, cstr, slen, nil, 0)
    if n == 0 do return nil
    text := make([]u16, n + 1, allocator)
    n1 := MultiByteToWideChar(CP_UTF8, 0, cstr, slen, raw_data(text), n)
    if n1 == 0 {
        delete(text, allocator)
        return nil
    }
    text[n] = 0
    for n >= 1 && text[n - 1] == 0 { n -= 1 }
    return text[:n]
}

to_wstring :: proc(s: string, allocator := context.temp_allocator) -> ^u16 {
   if res := utf8_to_utf16(s, allocator); res != nil {
      return &res[0]
   }
   return nil
}

to_wchar_ptr :: proc(s: string, allocator := context.temp_allocator) -> ^u16 {
   if res := utf8_to_utf16(s, allocator); res != nil {
      return &res[0]
   }
   return nil
}


wstring_to_utf8 :: proc(s: wstring, N: int, allocator := context.temp_allocator) -> (res: string, err: runtime.Allocator_Error)  {
   if N == 0  do return "", nil

   n := WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, s, i32(N) if N > 0 else -1, nil, 0, nil, nil)
   if n == 0 do return "", nil

   // If N < 0 the call to WideCharToMultiByte assume the wide string is null terminated
	// and will scan it to find the first null terminated character. The resulting string will
	// also be null terminated.
	// If N > 0 it assumes the wide string is not null terminated and the resulting string
	// will not be null terminated.
   text := make([]byte, n, allocator) or_return

   n1 := WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, s, i32(N), raw_data(text), n, nil, nil)
   if n1 == 0 {
      delete(text, allocator)
      return "", nil
   }

   for i in 0..<n {
      if text[i] == 0 {
         n = i
         break
      }
   }

   return string(text[:n]), nil
}

// takes a wchar array
utf16_to_utf8 :: proc(s: []u16, allocator := context.temp_allocator) -> string {
   if len(s) == 0 do return ""
   res, _ := wstring_to_utf8(raw_data(s), len(s), allocator)
   return res
}

// Takes a multi pointer.
wstring_to_string :: proc(s: wstring, allocator := context.temp_allocator) -> string {
   res, _ := wstring_to_utf8(s, -1, allocator)
   return res
}

make_int_resource::proc(value : UINT) -> wstring {return wstring(rawptr(UINT_PTR(value))) }

FILETIME_as_unix_nanoseconds :: proc "contextless" (ft: FILETIME) -> i64 {
	t := i64(u64(ft.dwLowDateTime) | u64(ft.dwHighDateTime) << 32)
	return (t - 0x019db1ded53e8000) * 100
}

// enable_window :: proc(hw : HWND, bEnable : bool) -> BOOL{
//    return EnableWindow(hw, bEnable)
// }


foreign import "system:user32.lib"
@(default_calling_convention = "fast")
foreign user32 {
   @(link_name="RegisterClassExW") RegisterClassEx :: proc(wc: ^WNDCLASSEXW) -> i16 ---
   @(link_name="LoadIconW") LoadIcon :: proc(instance: HINSTANCE, icon_name: wstring) -> HICON ---
   @(link_name="LoadCursorW") LoadCursor :: proc(instance: HINSTANCE, cursor_name: wstring) -> HCURSOR ---

   @(link_name="CreateWindowExW") CreateWindowEx :: proc(  ex_style: u32,
                                                            class_name, title: wstring,
                                                            style: u32,
                                                            #any_int x, y, w, h: i32,
                                                            parent: HWND,
                                                            menu: HMENU,
                                                            instance: HINSTANCE,
                                                            param: rawptr) -> HWND ---

   @(link_name="SetWindowLongPtrW") SetWindowLongPtr :: proc(wnd: HWND, index: i32, new_long: LONG_PTR) -> LONG_PTR ---
   @(link_name="GetWindowLongPtrW") GetWindowLongPtr :: proc(wnd: HWND, index: i32) -> LONG_PTR ---
   @(link_name="GetMessageW") GetMessage :: proc(msg: ^MSG, hwnd: HWND, msg_filter_min, msg_filter_max: u32) -> i32 ---
   @(link_name="TranslateMessage") TranslateMessage  :: proc(msg: ^MSG) -> BOOL---
   @(link_name="DispatchMessageW") DispatchMessage :: proc(msg: ^MSG) -> LRESULT ---
   @(link_name="UpdateWindow") UpdateWindow :: proc(hwnd: HWND) -> BOOL---
   @(link_name="DefWindowProcW") DefWindowProc :: proc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT ---
   @(link_name="ShowWindow") ShowWindow :: proc(hwnd: HWND, nCmdShow: i32) -> BOOL---
   @(link_name="PostQuitMessage") PostQuitMessage :: proc(nExitCode: i32) ---
   @(link_name="GetDC") GetDC :: proc(h: HWND) -> HDC ---
   @(link_name="GetMessagePos") GetMessagePos :: proc() -> DWORD ---
   @(link_name="ReleaseDC") ReleaseDC :: proc(wnd: HWND, hdc: HDC) -> i32 ---
   @(link_name="GetWindowDC") GetWindowDC :: proc(wnd: HWND) -> HDC ---
   @(link_name="SendMessageW") SendMessage :: proc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT ---
   @(link_name="SendNotifyMessageW") SendNotifyMessage :: proc(hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM) -> LRESULT ---
   @(link_name="MessageBoxW") MessageBox :: proc(wnd: HWND, text, caption: wstring, type: u32) -> i32 ---
   @(link_name="MapVirtualKeyW") MapVirtualKey :: proc(u_code: u32, u_map_type : u32) -> u32 ---
   @(link_name="TrackMouseEvent") TrackMouseEvent :: proc(lp_tme: ^TRACKMOUSEEVENT) -> BOOL---
   @(link_name="GetClientRect") GetClientRect :: proc(hwnd: HWND, rect: ^RECT) -> BOOL---
   @(link_name="InvalidateRect") InvalidateRect :: proc(hwnd: HWND, rect: ^RECT, berase : BOOL) -> BOOL---
   @(link_name="SetWindowPos") SetWindowPos :: proc(hwnd, hw_ins_after: HWND, #any_int x, y, cx, cy : i32, flags : u32) -> BOOL---
   @(link_name="SetWindowTextW") SetWindowText :: proc(hwnd : HWND, lp_string : LPCWSTR) -> BOOL---
   @(link_name="GetWindowTextW") GetWindowText :: proc(hwnd : HWND, lp_string : wstring, count : i32) -> i32 ---
   @(link_name="GetWindowTextLengthW") GetWindowTextLength :: proc(hwnd : HWND) -> i32 ---
   @(link_name="DrawTextW") DrawText :: proc(hdc : HDC, lp_txt : wstring, cch_txt : i32, lprc : ^RECT, format : UINT) -> i32 ---
   @(link_name="InflateRect") InflateRect :: proc(lprct : ^RECT, dx, dy : i32) -> BOOL---
   @(link_name="RedrawWindow") RedrawWindow :: proc(hw : HWND, lprct : ^RECT, upd_rgn : HRGN, flags : UINT) -> BOOL---
   @(link_name="MoveWindow") MoveWindow :: proc(hw : HWND, x, y, w, h : i32, repaint : BOOL) -> BOOL---
   @(link_name="PostMessageW") PostMessage :: proc(hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM) -> BOOL---
   @(link_name="FrameRect") FrameRect :: proc(dch : HDC, rct : ^RECT, hbr : HBRUSH) -> i32 ---
   @(link_name="DrawEdge") DrawEdge :: proc(dch : HDC, rct : ^RECT, edge, gr_flags : u32) -> BOOL---
   @(link_name="BeginPaint") BeginPaint :: proc(hw : HWND, lp_paint : ^PAINTSTRUCT) -> HDC ---
   @(link_name="EndPaint") EndPaint :: proc(hw : HWND, lp_paint : ^PAINTSTRUCT) -> BOOL---
   @(link_name="GetClassLongPtrW") GetClassLongPtr :: proc(hw : HWND, indx : i32) -> u64 ---
   //@(link_name="GetClassLongW") GetClassLong :: proc(hw : HWND, indx : i32) -> u64 ---
   @(link_name="DestroyWindow") DestroyWindow :: proc(hw : HWND) -> BOOL---
   @(link_name="GetCursorPos") GetCursorPos :: proc(pt : ^POINT) -> BOOL---
   @(link_name="ScreenToClient") ScreenToClient :: proc(hw : HWND, pt : ^POINT) -> BOOL---
   @(link_name="WindowFromPoint") WindowFromPoint :: proc(pt : POINT) -> HWND ---
   // @(link_name="EnableWindow") EnableWindow :: proc(hw : HWND, bEnable : bool) -> BOOL---
   @(link_name="HideCaret") HideCaret :: proc(hw : HWND) -> BOOL---
   @(link_name="PtInRect") PtInRect :: proc(lprc : ^RECT, pt : POINT) -> BOOL---
   @(link_name="SetFocus") SetFocus :: proc(hw : HWND) -> HWND ---
   @(link_name="GetFocus") GetFocus :: proc() -> HWND ---
   @(link_name="SetActiveWindow") SetActiveWindow :: proc(hw : HWND) -> HWND ---
   @(link_name="GetDCEx") GetDCEx :: proc(hw : HWND, clp_rgn : HRGN, flags : DWORD) -> HDC ---
   @(link_name="GetWindowRect") GetWindowRect :: proc(hw : HWND, pRc : ^RECT) -> BOOL---
   @(link_name="DestroyIcon") DestroyIcon :: proc(hIco : HICON) -> BOOL---
   @(link_name="SetForegroundWindow") SetForegroundWindow :: proc(hwnd : HWND) -> BOOL---
   @(link_name="SetRect") SetRect :: proc(lprct : ^RECT, left, top, right, bottom : i32 ) -> BOOL---
   @(link_name="LoadImageW") LoadImage :: proc(hInst : HINSTANCE,
                                                img_name : wstring,
                                                img_type : u32,
                                                cx, cy : i32,
                                                fuLoad : u32 ) -> HICON ---

   @(link_name="MapWindowPoints") MapWindowPoints :: proc(hWndFrom : HWND,
                                                            hWndTo : HWND,
                                                            lpPoints : ^POINT,
                                                            cPoints : UINT ) -> HANDLE ---
   @(link_name="CreateMenu") CreateMenu :: proc() -> HMENU ---
   @(link_name="CreatePopupMenu") CreatePopupMenu :: proc() -> HMENU ---
   // @(link_name="AppendMenuW") AppendMenu :: proc(hmenu: HMENU,
   //                                                 uFlags: uint,
   //                                                 uIDNewItem: UINT_PTR,
   //                                                 lpNewItem: LPCWSTR) -> BOOL ---
   @(link_name="SetMenu") SetMenu :: proc(hwnd: HWND, hmenu: HMENU) -> BOOL ---
   @(link_name="DeleteMenu") DeleteMenu :: proc(menuHwnd: HMENU, uID: UINT, uFlag: UINT) -> BOOL ---
   @(link_name="InsertMenuItemW") InsertMenuItem :: proc(hmenu: HMENU,
                                                         item: uint,
                                                         fByPosition: BOOL,
                                                         lpmi: LPCMENUITEMINFO) -> BOOL ---
   // @(link_name="TrackPopupMenu") TrackPopupMenu :: proc(hmenu: HMENU,
   //                                                       uFlags: uint,
   //                                                       x, y, nReserved: int,
   //                                                       hwnd: HWND) -> BOOL ---
   @(link_name="DestroyMenu") DestroyMenu :: proc(hmenu: HMENU) -> BOOL ---
   @(link_name="SetTimer") SetTimer :: proc(hWnd: HWND, nID: UINT_PTR, uEl: UINT, lpfn: TIMERPROC) -> UINT_PTR ---
   @(link_name="KillTimer") KillTimer :: proc(hWnd: HWND, nID: UINT_PTR) -> BOOL ---
   @(link_name="UnregisterClassW") UnregisterClass :: proc(LPCWSTR, HINSTANCE) -> BOOL ---



} // User32 library



foreign import "system:kernel32.lib"
@(default_calling_convention = "fast")
foreign kernel32 {
   @(link_name="GetLastError") GetLastError :: proc() -> DWORD ---
   @(link_name="GetModuleHandleW") GetModuleHandle :: proc(module_name: wstring) -> HINSTANCE ---
   // @(link_name="GetSystemMetrics") GetSystemMetrics :: proc(index: i32) -> i32 ---

   @(link_name="MultiByteToWideChar") MultiByteToWideChar :: proc(code_page: u32, flags: u32,
                                                                      mb_str: LPSTR, mb: i32,
                                                                      wc_str: LPWSTR, wc: i32) -> i32 ---

   @(link_name="WideCharToMultiByte") WideCharToMultiByte :: proc(code_page: u32, flags: DWORD,
                                                                      wchar_str: LPCWSTR, wchar: i32,
                                                                      multi_str: LPSTR, multi: i32,
                                                                      default_char: LPSTR, used_default_char: ^BOOL) -> i32 ---

   @(link_name="MulDiv") MulDiv :: proc(nNumber, nNumerator, nDenominator : i32) -> LONG ---
   @(link_name="GetSystemTimeAsFileTime") GetSysTimeAsFileTime :: proc(pfile_time : ^FILETIME) ---
   @(link_name="GetSystemTime") GetSystemTime :: proc(sys_time : ^SYSTEMTIME) ---
   @(link_name="GetLocalTime") GetLocalTime :: proc(sys_time : ^SYSTEMTIME) ---
   @(link_name="Sleep") Sleep :: proc(milli_sec : DWORD) ---

   @(link_name="GetPrivateProfileStringA") GetPrivateProfileString :: proc(lpAppName : cstring,
                                                                           lpKeyName : cstring,
                                                                           lpDefault : cstring,
                                                                           lpReturn : ^byte,
                                                                           nSize : DWORD,
                                                                           lpFileName : cstring) -> DWORD ---

   // @(link_name="MultiByteToWideChar") MultiByteToWideChar2 :: proc(code_page: u32, flags: u32,
   //                                                                    mb_str: string, mb: i32,
   //                                                                    wc_str: wstring, wc: i32) -> i32 ---


} // Kernel32 library

foreign import "system:gdi32.lib"
@(default_calling_convention = "fast")
foreign gdi32 {
   @(link_name="CreateSolidBrush") CreateSolidBrush :: proc(color: COLORREF) -> HBRUSH ---
   @(link_name="CreateFontW") CreateFont :: proc(cHeight, cWidth, cEscapement, cOrientation, cWeight : i32,
                                                   bItalic, bUnderline, bStrikeOut : DWORD,
                                                   iCharSet, iOutPrecision, iClipPrecision : DWORD,
                                                   iQuality, iPitchAndFamily : DWORD,
                                                   pszFaceName : wstring ) -> HFONT ---
   @(link_name="CreateFontIndirectW") CreateFontIndirect :: proc(^LOGFONT) -> HFONT ---
   @(link_name="GetDeviceCaps") GetDeviceCaps :: proc(hdc: HDC, index : i32) -> i32 ---
   // @(link_name="FillRect") FillRect :: proc(hdc: HDC, rct : ^RECT, hb : HBRUSH) -> i32 ---
   @(link_name="DeleteObject") DeleteObject :: proc(hgdi_obj: HGDIOBJ) -> BOOL---
   @(link_name="CreateCompatibleDC") CreateCompatibleDC :: proc(hdc: HDC) -> HDC ---
   @(link_name="CreateCompatibleBitmap") CreateCompatibleBitmap :: proc(hdc: HDC, cx, cy : i32) -> HBITMAP ---
   @(link_name="SelectObject") SelectObject :: proc(hdc: HDC, hobj : HGDIOBJ) -> HGDIOBJ ---
   @(link_name="CreatePatternBrush") CreatePatternBrush :: proc(hbmp : HBITMAP) -> HBRUSH ---
   @(link_name="DeleteDC") DeleteDC :: proc(hdc : HDC) -> BOOL---
   @(link_name="SetTextColor") SetTextColor :: proc(hdc : HDC, clr : COLORREF) -> COLORREF ---
   @(link_name="SetBkMode") SetBkMode :: proc(hdc : HDC, mode : i32) -> i32 ---
   @(link_name="Rectangle") Rectangle :: proc(hdc : HDC, left, top, right, bottom : i32) -> BOOL---
   @(link_name="CreatePen") CreatePen :: proc(style, #any_int width : i32, cref : COLORREF) -> HPEN ---
   @(link_name="GetTextExtentPoint32W") GetTextExtentPoint32 :: proc(dch : HDC,
                                                                        lp_string : wstring,
                                                                        #any_int str_len : i32,
                                                                        psize : ^SIZE) -> BOOL---
   @(link_name="SetBkColor") SetBackColor :: proc(dchandle : HDC, cref : COLORREF) -> COLORREF ---
   @(link_name="GetStockObject") GetStockObject :: proc(fn_object : i32) -> HGDIOBJ ---
   @(link_name="SaveDC") SaveDC :: proc(dch : HDC) -> i32 ---
   @(link_name="RestoreDC") RestoreDC :: proc(dch : HDC, ndc : i32) -> BOOL---
   @(link_name="Ellipse") Ellipse :: proc(dch : HDC, #any_int left, top, right, bottom : i32) -> BOOL---
   @(link_name="Polygon") Polygon :: proc(dch : HDC, pArr : [^]POINT, #any_int cpt : i32) -> BOOL---
   @(link_name="Polyline") Polyline :: proc(dch : HDC, pArr : rawptr, #any_int cpt : i32) -> BOOL---
   @(link_name="MoveToEx") MoveToEx :: proc(dch : HDC, #any_int x, y : i32, lppt : ^POINT) -> BOOL---
   @(link_name="LineTo") LineTo :: proc(dch : HDC, #any_int x, y : i32) -> BOOL---
   @(link_name="RoundRect") RoundRect :: proc(dch : HDC, left, top, right, bottom, width, height : i32) -> BOOL---
   @(link_name="FillPath") FillPath :: proc(dch : HDC) -> BOOL---
   @(link_name="TextOutW") TextOut :: proc(hdc: HDC, x, y: i32, lpTxt: wstring, tLen: i32) -> BOOL---


} // Gdi32 library

foreign import "system:Comctl32.lib"
@(default_calling_convention = "fast")
foreign Comctl32 {
   @(link_name="SetWindowSubclass") SetWindowSubclass :: proc(hw : HWND, pfn : SUBCLASSPROC, uid : UINT_PTR, rd : DWORD_PTR) -> BOOL---
   @(link_name="DefSubclassProc") DefSubclassProc :: proc(hw : HWND, ms : u32, wpm : WPARAM, lpm : LPARAM) -> LRESULT ---
   @(link_name="RemoveWindowSubclass") RemoveWindowSubclass :: proc(hw : HWND, pfn : SUBCLASSPROC, uid : UINT_PTR) -> BOOL---
   @(link_name="InitCommonControlsEx") InitCommonControlsEx :: proc(picc_ex : ^INITCOMMONCONTROLSEX) -> BOOL---
   @(link_name="ImageList_Create") ImageList_Create :: proc(#any_int cx, cy : i32,
                                                            flags : u32,
                                                            #any_int cIntial,
                                                            cGrow : i32) -> HIMAGELIST ---
   @(link_name="ImageList_Destroy") ImageList_Destroy :: proc(himl : HIMAGELIST) -> BOOL---
   @(link_name="ImageList_Add") ImageList_Add :: proc(himl : HIMAGELIST, hbmImg : HBITMAP, hbmMask : HBITMAP) -> i32 ---
   @(link_name="ImageList_ReplaceIcon") ImageList_ReplaceIcon :: proc(himl : HIMAGELIST, i : i32, icon : HICON) -> i32 ---



} // Comctrl library

foreign import "system:UxTheme.lib"
@(default_calling_convention = "fast")
foreign UxTheme {
   @(link_name="SetWindowTheme") SetWindowTheme :: proc(hw : HWND, sub_app : wstring, sub_id : wstring) -> HRESULT ---
   @(link_name="OpenThemeData") OpenThemeData :: proc(hw : HWND, cls_list : wstring) -> HTHEME ---
   @(link_name="CloseThemeData") CloseThemeData :: proc(htd : HTHEME) -> HRESULT ---
   @(link_name="DrawThemeEdge") DrawThemeEdge :: proc(htd : HTHEME,
                                                      hdc : HDC,
                                                      partId, stateId : i32,
                                                      pRect : ^RECT,
                                                      uEdge : u32,
                                                      uFlags: u32,
                                                      pContRect : ^RECT) -> HRESULT ---

   @(link_name="DrawThemeBackground") DrawThemeBackground :: proc(htd : HTHEME,
                                                                  hdc : HDC,
                                                                  partId, stateId : i32,
                                                                  pRect : ^RECT,
                                                                  pClipRect : ^RECT) -> HRESULT ---

   @(link_name="GetThemeColor") GetThemeColor :: proc(htd : HTHEME,
                                                      hdc : HDC,
                                                      partId, stateId : i32,
                                                      propId : i32,
                                                      clr : ^COLORREF) -> HRESULT ---

    @(link_name="DrawThemeBackgroundEx") DrawThemeBackgroundEx :: proc(htd : HTHEME,
                                                      hdc : HDC,
                                                      partId, stateId : i32,
                                                      pRect : ^RECT,
                                                      opts : ^DTBGOPTS) -> HRESULT ---
}


foreign import "system:shell32.lib"
@(default_calling_convention = "fast")
foreign shell32 {
   @(link_name="ExtractIconExW") ExtractIconEx :: proc(  lpszFile : wstring,
                                                         iconIndex : i32,
                                                         pLgicon : ^HICON,
                                                         pSmIcon : ^HICON,
                                                         nIcons : u32 ) -> u32 ---
   @(link_name = "SHBrowseForFolderW") SHBrowseForFolder :: proc(p1: LPBROWSEINFOW) -> PIDLIST_ABSOLUTE ---
   @(link_name = "SHGetPathFromIDListW") SHGetPathFromIDList :: proc(pidl: PCIDLIST_ABSOLUTE,
                                                                     pszPath: LPWSTR) -> BOOL ---
   @(link_name = "Shell_NotifyIconW") Shell_NotifyIcon :: proc(p1: DWORD, p2: ^NOTIFYICONDATA) -> BOOL ---

}

foreign import "system:comdlg32.lib"
@(default_calling_convention = "fast")
foreign comdlg32 {
   @(link_name = "GetOpenFileNameW") GetOpenFileName :: proc(p1: LPOPENFILENAMEW) -> BOOL ---
   @(link_name = "GetSaveFileNameW") GetSaveFileName :: proc(p1: LPOPENFILENAMEW) -> BOOL ---
}

foreign import "system:ole32.lib"
@(default_calling_convention = "fast")
foreign ole32 {
   @(link_name="CoTaskMemFree") CoTaskMemFree :: proc(pv: LPVOID) ---
}

