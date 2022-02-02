
package winforms

import "core:c"
//import "core:sys/win32"

//=================================== Types=======================================
c_char     :: c.char
c_uchar    :: c.uchar
c_int      :: c.int
c_uint     :: c.uint
c_long     :: c.long
c_longlong :: c.longlong
c_ulong    :: c.ulong
c_short    :: c.short
c_ushort   :: c.ushort
size_t     :: c.size_t
wchar_t    :: c.wchar_t


Uint :: c_uint
UintPtr :: distinct uintptr
IntPtr :: distinct int
Long   :: distinct c_long
LongPtr :: distinct int

Bool :: distinct b32
Wchar :: wchar_t
wstring :: [^]Wchar


Handle    :: distinct rawptr
Hwnd      :: distinct Handle
Hfont 	  :: distinct Handle
Hdc       :: distinct Handle
Hpen	  :: distinct Handle
Hinstance :: distinct Handle
Hicon     :: distinct Handle
Hcursor   :: distinct Handle
Hmenu     :: distinct Handle
Hbitmap   :: distinct Handle
Hbrush    :: distinct Handle
Hgdiobj   :: distinct Handle
Hmodule   :: distinct Handle
Hmonitor  :: distinct Handle
Hrawinput :: distinct Handle
Hresult   :: distinct i32
Hkl       :: distinct Handle
Hrgn	  :: distinct Handle
Htheme	  :: distinct Handle
Wparam    :: distinct UintPtr
Lparam    :: distinct LongPtr
Lresult   :: distinct LongPtr
Dword     :: c_ulong
DwordPtr :: ^c_ulong
Word      :: u16
ColorRef :: distinct Dword


WNDPROC  :: distinct #type proc "std" (Hwnd, u32, Wparam, Lparam) -> Lresult
SUBCLASSPROC :: distinct #type proc "std" (Hwnd, u32, Wparam, Lparam, UintPtr, DwordPtr) -> Lresult

WNDCLASSEXW :: struct { 
	cbSize, 
	style : u32, 
	lpfnWndProc: WNDPROC,
	cbClsExtra, 
	cbWndExtra: i32, 
	hInstance: Hinstance, 
	hIcon: Hicon, 
	hCursor: Hcursor, 
	hbrBackground: Hbrush, 
	lpszMenuName, 
	lpszClassName: wstring, 
	hIconSm: Hicon, 
}

Point :: struct { x, y: i32,}

Msg :: struct {hwnd: Hwnd, message: u32, wparam: Wparam, lparam: Lparam, time: u32, pt: Point,}

TRACKMOUSEEVENT :: struct {
	cbSize : Dword,
	dwFlags : Dword,
	hwndTrack : Hwnd,
	dwHoverTime : Dword,	
}


Rect :: struct {
	left:   i32,
	top:    i32,
	right:  i32,
	bottom: i32,
}


NMHDR :: struct {
	hwndFrom : Hwnd,
	idFrom : u64,
	code : u64,
}

NMCUSTOMDRAW :: struct {
    hdr : NMHDR,
    dwDrawStage : Dword,
    hdc : Hdc,
    rc : Rect,
    dwItemSpec : DwordPtr,
    uItemState : u64,
    lItemParam : Lparam,
}
LPNMCUSTOMDRAW :: ^NMCUSTOMDRAW

INITCOMMONCONTROLSEX :: struct {
	dwSize : Dword,
	dwIcc : Dword,
}

Size :: struct {width : i32, height : i32,}

DRAWITEMSTRUCT :: struct {
	ctlType : Uint, 
	ctlID: Uint, 
	itemID, itemAction, itemState : Uint,
	hwndItem : Hwnd,
	hDC : Hdc,
	rcItem : Rect,
	itemData : DwordPtr,
}

PAINTSTRUCT :: struct {
	hdc : Hdc,
	fErase : b32,
	rcPaint : Rect,
	fRestore : b32,
	fIncUpdate : b32,
	rgbReserved : [32]byte,
}

COMBOBOXINFO :: struct {
	cbSize : Dword,
	rcItem,
	rcButton : Rect,
	stateButton : Dword,
	hwndCombo,
	hwndItem,
	hwndList : Hwnd,	
}

FILETIME :: struct {
	dwLowDateTime: Dword,
	dwHighDateTime: Dword,
}

SYSTEMTIME :: struct{
	wYear,
	wMonth,
	wDayOfWeek,
	wDay,
	wHour,
	wMinute,
	wSecond,
	wMilliseconds : Word,
}

DTBGOPTS :: struct {
	dwSize : Dword,
	dwFlags : Dword,
	rcClip : Rect,	
}

WINDOWPOS :: struct {
	hwnd : Hwnd,
	hwndInsertAfter : Hwnd,
	x, y : i32,
	cx, cy : i32,
	flags : u32,
}

