
package winforms

import api "core:sys/windows"
// import "core:c"
// //import "core:sys/win32"

// //=================================== Types=======================================
// c_char     :: c.char
// c_uchar    :: c.uchar
// c_int      :: c.int
// c_uint     :: c.uint
// c_long     :: c.long
// c_longlong :: c.longlong
// c_ulong    :: c.ulong
// c_short    :: c.short
// c_ushort   :: c.ushort
// size_t     :: c.size_t
// wchar_t    :: c.wchar_t


// UINT:: c_uint
// UINT_PTR :: uintptr
// INT_PTR :: distinct int
// LONG   :: distinct c_long
// LONG_PTR :: distinct int
// ULONG_PTR :: distinct c_ulong
// ULONG:: distinct c_ulong

// BOOL:: distinct b32
// WCHAR :: wchar_t
// wstring :: [^]WCHAR
// LPCWSTR :: ^WCHAR
// LPWSTR :: ^WCHAR


// LPVOID 	  :: distinct rawptr
// HANDLE    :: distinct LPVOID
// HWND      :: distinct HANDLE
// HFONT 	  :: distinct HANDLE
// HDC       :: distinct HANDLE
HPEN	  :: distinct HANDLE
// HINSTANCE :: distinct HANDLE
// HICON     :: distinct HANDLE
// HCURSOR   :: distinct HANDLE
// HMENU     :: distinct HANDLE
// HBITMAP   :: distinct HANDLE
// HBRUSH    :: distinct HANDLE
// HGDIOBJ   :: distinct HANDLE
// HMODULE   :: distinct HANDLE
// Hmonitor  :: distinct HANDLE
// Hrawinput :: distinct HANDLE
// HRESULT   :: distinct i32
// Hkl       :: distinct HANDLE
// HRGN	  :: distinct HANDLE
// HTHEME	  :: distinct HANDLE
// WPARAM    :: distinct UINT_PTR
// LPARAM    :: distinct LONG_PTR
// LRESULT   :: distinct LONG_PTR
// DWORD     :: c_ulong
// DWORD_PTR  :: ^c_ulong
// WORD      :: u16
// COLORREF  :: distinct DWORD
// HTREEITEM :: distinct HANDLE
// HIMAGELIST :: distinct HANDLE

LPVOID 	  :: api.LPVOID
HANDLE    :: api.HANDLE
HWND      :: api.HWND
HFONT 	  :: api.HFONT
HDC       :: api.HDC
// HPEN	  :: api.
HINSTANCE :: api.HINSTANCE
HICON     :: api.HICON
HCURSOR   :: api.HCURSOR
HMENU     :: api.HMENU
HBITMAP   :: api.HBITMAP
HBRUSH    :: api.HBRUSH
HGDIOBJ   :: api.HGDIOBJ
HMODULE   :: api.HMODULE
Hmonitor  :: api.HMONITOR
Hrawinput :: api.HRAWINPUT
HRESULT   :: api.HRESULT
Hkl       :: distinct HANDLE
HRGN	  :: api.HRGN
HTHEME	  :: distinct HANDLE
WPARAM    :: api.UINT_PTR
LPARAM    :: api.LONG_PTR
LRESULT   :: api.LONG_PTR
DWORD     :: api.DWORD
DWORD_PTR  :: api.DWORD_PTR
WORD      :: api.WORD
COLORREF  :: api.COLORREF
HTREEITEM :: api.HANDLE
HIMAGELIST :: api.HIMAGELIST

UINT:: api.UINT
UINT_PTR :: api.UINT_PTR
INT_PTR :: distinct int
LONG   :: api.LONG
LONG_PTR :: api.LONG_PTR
ULONG_PTR :: api.ULONG_PTR
ULONG:: api.ULONG

BOOL:: api.BOOL
BOOL2 :: distinct i32
WCHAR :: api.WCHAR
wstring :: [^]WCHAR
LPCWSTR :: api.LPCWSTR
LPWSTR :: api.LPWSTR
LPSTR :: api.LPSTR
MYCWSTR :: ^u16

size_t     :: api.size_t


RECT :: api.RECT
WNDPROC  :: distinct #type proc "stdcall" (HWND, u32, WPARAM, LPARAM) -> LRESULT
SUBCLASSPROC :: distinct #type proc "stdcall" (HWND, u32, WPARAM, LPARAM, UINT_PTR, DWORD_PTR) -> LRESULT
TIMERPROC :: distinct #type proc "stdcall" (HWND, UINT, UINT_PTR, DWORD)

WNDCLASSEXW :: struct {
	cbSize,
	style : u32,
	lpfnWndProc: WNDPROC,
	cbClsExtra,
	cbWndExtra: i32,
	hInstance: HINSTANCE,
	hIcon: HICON,
	hCursor: HCURSOR,
	hbrBackground: HBRUSH,
	lpszMenuName,
	lpszClassName: wstring,
	hIconSm: HICON,
}

POINT :: struct { x, y: i32,}

MSG :: struct {hwnd: HWND, message: u32, wparam: WPARAM, lparam: LPARAM, time: u32, pt: POINT,}

TRACKMOUSEEVENT :: struct
{
	cbSize : DWORD,
	dwFlags : DWORD,
	hwndTrack : HWND,
	dwHoverTime : DWORD,
}

NMSELCHANGE :: struct
    {
        nmhdr : NMHDR,
        stSelStart,
        stSelEnd : SYSTEMTIME,
    }

    NMVIEWCHANGE :: struct
    {
        nmhdr : NMHDR,
        dwOldView : DWORD,
        dwNewView : DWORD,
    }

    MCGRIDINFO :: struct
    {
        cbSize : UINT,
        dwPart : DWORD,
        dwFlags : DWORD,
        iCalendar : i32,
        iRow : i32,
        iCol : i32,
        bSelecte : bool,
        stStart : SYSTEMTIME,
        stEnd : SYSTEMTIME,
        rc : RECT,
        pszName : wstring,
        cchNam : size_t,
    }

    NMMOUSE :: struct
    {
        nmhdr : NMHDR,
        dwItemSpec : DWORD_PTR,
        dwItemData : DWORD_PTR,
        pt : POINT,
        dwHitInfo : LPARAM,

    }

    NMLISTVIEW :: struct  {
        hdr : NMHDR,
        iItem : i32,
        iSubItem : i32,
        uNewState : u32,
        uOldState : u32,
        uChanged : u32,
        ptAction : POINT,
        lParam : LPARAM,
    }

    // Structs
		LVITEM :: struct {
			mask : u32,
			iItem : i32,
			iSubItem : i32,
			state : u32,
			stateMask : u32,
			pszText : wstring,
			cchTextMax : i32,
			iImage : i32,
			lParam : LPARAM,
			iIndent : i32,
			iGroupId : i32,
			cColumns : u32,
			puColumns : ^u32,
			piColFmt  : ^i32,
			iGroup  : i32,
		}

		LVCOLUMN :: struct {
			mask : u32,
			fmt : i32,
			cx : i32,
			pszText : wstring,
			cchTextMax : i32,
			iSubItem : i32,
			iImage : i32,
			iOrder : i32,
			cxMin : i32,
			cxDefault : i32,
			cxIdeal : i32,
		}

		HDHITTESTINFO :: struct {
			pt : POINT,
			flags : uint,
			iItem : int,
		}

		HD_LAYOUT :: struct {
			prc : ^RECT,
			pwpos : ^WINDOWPOS,
		}

		NMLVCUSTOMDRAW :: struct {
			nmcd : NMCUSTOMDRAW,
			clrText : COLORREF,
			clrTextBk : COLORREF,
			iSubItem : i32,
			dwItemType : DWORD,
			clrFace : COLORREF,
			iIconEffect : i32,
			iIconPhase : i32,
			iPartId : i32,
			iStateId : i32,
			rcText : RECT,
			uAlign : UINT,
		}

	NMDATETIMECHANGE :: struct
    {
        nmhdr : NMHDR,
        dwFlags : DWORD,
        st : SYSTEMTIME,
    }

    NMDATETIMESTRINGW :: struct
    {
        nmhdr :  NMHDR,
        pszUserString : wstring,
        st : SYSTEMTIME,
        dwFlags : DWORD,
    }

	NMUPDOWN :: struct {
		hdr : NMHDR,
		iPos : i32,
		iDelta : i32,
	}

	 PBTM :: enum {
        PP_BAR = 1,
        PP_BARVERT = 2,
        PP_CHUNK = 3,
        PP_CHUNKVERT = 4,
        PP_FILL = 5,
        PP_FILLVERT = 6,
        PP_PULSEOVERLAY = 7,
        PP_MOVEOVERLAY = 8,
        PP_PULSEOVERLAYVERT = 9,
        PP_MOVEOVERLAYVERT = 10,
        PP_TRANSPARENTBAR = 11,
        PP_TRANSPARENTBARVERT = 12,
    }

	TVITEMEXW :: struct
    {
        mask : u32,
        hItem : HTREEITEM,
        state,
        stateMask : u32,
        pszText : wstring,
        cchTextMax,
        iImage,
        iSelectedImage ,
        cChildren : i32,
        lParam : LPARAM,
        iIntegral : i32,
        uStateEx : u32,
        hwnd : HWND,
        iExpandedImage,
        iReserved : i32,
    }

    TVINSERTSTRUCT :: struct
    {
        hParent : HTREEITEM,
        hInsertAfter : HTREEITEM,
        itemEx : TVITEMEXW,
    }

    NMTVDISPINFOEXW :: struct
    {
        hdr : NMHDR,
        item : TVITEMEXW,
    }

    TVITEM :: struct
    {
        mask : u32,
        hItem : HTREEITEM,
        state,
        stateMask : u32,
        pszText : wstring,
        cchTextMax,
        iImage,
        iSelectedImage ,
        cChildren : i32,
        lParam : LPARAM,
    }

    NMTREEVIEW :: struct
    {
        hdr : NMHDR,
        action : u32,
        itemOld : TVITEM,
        itemNew : TVITEM,
        ptDrag : POINT,
    }

    NMTVSTATEIMAGECHANGING :: struct
    {
        hdr : NMHDR,
        hti : HTREEITEM,
        iOldStateImageIndex : i32,
        iNewStateImageIndex : i32,
    }

    TVITEMCHANGE :: struct
    {
        hdr : NMHDR,
        uChanged : u32,
        hItem : HTREEITEM,
        uStateNew : u32,
        uStateOld : u32,
        lParam : LPARAM,
    }

    NMTVCUSTOMDRAW :: struct
    {
        nmcd : NMCUSTOMDRAW,
        clrText : COLORREF,
        clrTextBk : COLORREF,
        iLevel : i32,
    }


// RECT :: struct
// {
// 	left:   i32,
// 	top:    i32,
// 	right:  i32,
// 	bottom: i32,
// }


NMHDR :: struct
{
	hwndFrom : HWND,
	idFrom : UINT_PTR,
	code : UINT,
}

NMCUSTOMDRAW :: struct
{
    hdr : NMHDR,
    dwDrawStage : DWORD,
    hdc : HDC,
    rc : RECT,
    dwItemSpec : DWORD_PTR,
    uItemState : u64,
    lItemParam : LPARAM,
}
LPNMCUSTOMDRAW :: ^NMCUSTOMDRAW

INITCOMMONCONTROLSEX :: struct {
	dwSize : DWORD,
	dwIcc : DWORD,
}

SIZE :: struct {cx : i32, cy : i32,}

DRAWITEMSTRUCT :: struct {
	ctlType : UINT,
	ctlID: UINT,
	itemID, itemAction, itemState : UINT,
	hwndItem : HWND,
	hDC : HDC,
	rcItem : RECT,
	itemData : DWORD_PTR,
}
LPDRAWITEMSTRUCT :: ^DRAWITEMSTRUCT

PAINTSTRUCT :: struct {
	hdc : HDC,
	fErase : b32,
	rcPaint : RECT,
	fRestore : b32,
	fIncUpdate : b32,
	rgbReserved : [32]byte,
}

LOGFONT :: struct {
	lfHeight : LONG,
	lfWidth : LONG,
	lfEscapement : LONG,
	lfOrientation : LONG,
	lfWeight : LONG,
	lfItalic : byte,
	lfUnderline : byte,
	lfStrikeOut : byte,
	lfCharSet : byte,
	lfOutPrecision : byte,
	lfClipPrecision : byte,
	lfQuality : byte,
	lfPitchAndFamily : byte,
	lfFaceName : [32]WCHAR,
}


COMBOBOXINFO :: struct {
	cbSize : DWORD,
	rcItem,
	rcButton : RECT,
	stateButton : DWORD,
	hwndCombo,
	hwndItem,
	hwndList : HWND,
}

FILETIME :: struct {
	dwLowDateTime: DWORD,
	dwHighDateTime: DWORD,
}

SYSTEMTIME :: struct{
	wYear,
	wMonth,
	wDayOfWeek,
	wDay,
	wHour,
	wMinute,
	wSecond,
	wMilliseconds : WORD,
}

DTBGOPTS :: struct {
	dwSize : DWORD,
	dwFlags : DWORD,
	rcClip : RECT,
}

WINDOWPOS :: struct {
	hwnd : HWND,
	hwndInsertAfter : HWND,
	x, y : i32,
	cx, cy : i32,
	flags : u32,
}

MENUITEMINFO :: struct
{
	cbSize : UINT,
	fMask : UINT,
	fType : UINT,
	fState : UINT,
	wID : UINT,
	hSubMenu : HMENU,
	hbmpChecked : HBITMAP,
	hbmpUnchecked : HBITMAP,
	dwItemData : ULONG_PTR,
	dwTypeData : LPWSTR,
	cch : UINT,
	hbmpItem : HBITMAP,
}
LPCMENUITEMINFO :: ^MENUITEMINFO

MEASUREITEMSTRUCT :: struct
{
    CtlType: UINT,
    CtlID: UINT,
    itemID: UINT,
    itemWidth: UINT,
    itemHeight: UINT,
    itemData: ULONG_PTR,
}
LPMEASUREITEMSTRUCT :: ^MEASUREITEMSTRUCT

OPENFILENAMEW :: struct {
	lStructSize: DWORD,
	hwndOwner: HWND,
	hInstance: HINSTANCE,
	lpstrFilter: MYCWSTR,
	lpstrCustomFilter: LPWSTR,
	nMaxCustFilter: DWORD,
	nFilterIndex: DWORD,
	lpstrFile: LPWSTR,
	nMaxFile: DWORD,
	lpstrFileTitle: LPWSTR,
	nMaxFileTitle: DWORD,
	lpstrInitialDir: MYCWSTR,
	lpstrTitle: MYCWSTR,
	Flags: DWORD,
	nFileOffset: WORD,
	nFileExtension: WORD,
	lpstrDefExt: MYCWSTR,
	lCustData: LPARAM,
	lpfnHook: OFNHOOKPROC,
	lpTemplateName: MYCWSTR,
	pvReserved: rawptr,
	dwReserved: DWORD,
	FlagsEx: DWORD,
}
LPOPENFILENAMEW :: ^OPENFILENAMEW

SHITEMID :: struct {
    cb: u16,
    abID: [1]u8
}
LPSHITEMID :: ^SHITEMID

ITEMIDLIST :: struct { mkid: SHITEMID }

ITEMIDLIST_RELATIVE :: ITEMIDLIST
ITEMID_CHILD :: ITEMIDLIST
ITEMIDLIST_ABSOLUTE :: ITEMIDLIST
LPITEMIDLIST :: ^ITEMIDLIST
LPCITEMIDLIST :: ^ITEMIDLIST
PIDLIST_ABSOLUTE :: ^ITEMIDLIST_ABSOLUTE
PCIDLIST_ABSOLUTE :: ^ITEMIDLIST_ABSOLUTE

BROWSEINFOW :: struct {
	hwndOwner: HWND,
	pidlRoot: PCIDLIST_ABSOLUTE,
	pszDisplayName: LPWSTR,
	lpszTitle: LPCWSTR,
	ulFlags: UINT,
	lpfn: BROWSECBPROC,
	lParam: LPARAM,
	iImage: i32
}
LPBROWSEINFOW :: ^BROWSEINFOW

NOTIFYICONDATA :: struct 
{
	cbSize: DWORD,
	hWnd: HWND,
	uID, uFlags, uCallbackMessage: u32,
	hIcon: HICON,
	toolTipText: [128]WCHAR,
	dwState: DWORD,
	dwStateMask: DWORD,
	balloonText: [256]WCHAR,
	uVersionOrTimeout: u32,
	balloonTitle: [64]WCHAR,
	dwInfoFlags: DWORD	
}

NMITEMACTIVATE :: struct {
    hdr       : NMHDR,
    iItem     : i32,
    iSubItem  : i32,
    uNewState : UINT,
    uOldState : UINT,
    uChanged  : UINT,
    ptAction  : POINT,
    lParam    : LPARAM,
    uKeyFlags : UINT,
}
