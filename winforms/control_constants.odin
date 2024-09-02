
// Constants used for diff controls - Created on 31-Aug-2024 20:01

package winforms

// Button constants.
    MOUSE_CLICKED :: 0b1
    MOUSE_OVER :: 0b1000000
    BTN_FOCUSED :: 0b10000
    ROUND_FACTOR : i32 : 5
    txtFlag : UINT= DT_SINGLELINE | DT_VCENTER | DT_CENTER | DT_HIDEPREFIX

// End of Button constants.

// Calendar constants.
    MCM_FIRST :: 0x1000
    MCM_GETMINREQRECT :: (MCM_FIRST + 9)
    MCM_SETCOLOR :: (MCM_FIRST + 10)
    MCM_GETCALENDARGRIDINFO :: (MCM_FIRST + 24)

    MCN_FIRST :: 4294966550
    MCN_GETDAYSTATE :: (MCN_FIRST + 3)
    MCN_SELCHANGE :: (MCN_FIRST - 3)
    MCN_SELECT :: MCN_FIRST
    MCN_VIEWCHANGE :: (MCN_FIRST-4)

    MCMV_MONTH :: 0
    MCMV_YEAR :: 1
    MCMV_DECADE :: 2
    MCMV_CENTURY :: 3
    MCMV_MAX :: MCMV_CENTURY

    MCGIP_CALENDARBODY :: 6
    MCGIP_CALENDAR :: 4
    MCGIF_RECT :: 0x2
// End of Calendar constants.


// ContextMenu constants.
    TPM_RETURNCMD :: 0x0100
    TPM_FLAG : u32: TPM_LEFTBUTTON | TPM_RETURNCMD
    SRCCOPY : DWORD : 0x00CC0020
// End of ContextMenu constants.

// DTP constants.
    ICC_DATE_CLASSES :: 0x100
    DTM_GETIDEALSIZE :: (DTM_FIRST+15)
    DtnFirst :: u64(4294966556)
    DTN_DATETIMECHANGE :: u64(4294966537) //DTN_FIRST2-6
    DTN_DROPDOWN :: u64(4294967280) //u64(18446744073709550862) // DTN_FIRST2 - 1
    DTN_CLOSEUP :: u64(140728898419983) //u64(18446744073709550863) //DTN_FIRST2
    DTN_USERSTRINGW :: u64(18446744073709550871) //(DTN_FIRST-5)
    DTN_WMKEYDOWNW :: u64(18446744073709550872)   //(DTN_FIRST-4)
    DTN_FORMATW :: u64(18446744073709550873) //(DTN_FIRST-3)
    DTN_FORMATQUERYW :: u64(18446744073709550874) //(DTN_FIRST-2)
    DtnUserStr :: DtnFirst - 5

    DTM_FIRST :: 0x1000
    DTM_SETFORMATW :: DTM_FIRST + 50
	DTM_SETFORMATA :: 0x1005
    DTM_GETDATETIMEPICKERINFO :: DTM_FIRST + 14
    DTM_SETMCCOLOR :: DTM_FIRST + 6
    DTM_GETMCSTYLE :: (DTM_FIRST + 12)
    DTM_SETMCSTYLE  :: (DTM_FIRST + 11)
    DTM_SETSYSTEMTIME :: (DTM_FIRST + 2)

    MCSC_BACKGROUND :: 0
    MCSC_TEXT :: 1
    MCSC_TITLEBK :: 2
    CSC_TITLETEXT :: 3
    MCSC_MONTHBK :: 4
    MCSC_TRAILINGTEXT :: 5

    MCS_DAYSTATE :: 0x1
    MCS_MULTISELECT :: 0x2
    MCS_WEEKNUMBERS :: 0x4
    MCS_NOTODAYCIRCLE :: 0x8
    MCS_NOTODAY :: 0x10
    MCS_NOTRAILINGDATES :: 0x40
    MCS_SHORTDAYSOFWEEK :: 0x80
    MCS_NOSELCHANGEONNAV :: 0x100

    subVal : i32 = -1
    myDtnfirst : u64 : 4294966556
    myDtnFirst2 : u64 : 4294966543
    myDtnDropdown : u64 : 4294966542
    myDtnCloseup := myDtnFirst2

    DTS_UPDOWN :: 0x1
    DTS_SHOWNONE :: 0x2
    DTS_SHORTDATEFORMAT :: 0x0
    DTS_LONGDATEFORMAT :: 0x4
    DTS_SHORTDATECENTURYFORMAT :: 0xc
    DTS_TIMEFORMAT :: 0x9
    DTS_APPCANPARSE :: 0x10
    DTS_RIGHTALIGN :: 0x20

// End of DTP constants.

// GroupBox constants.
    gbstyle : DWORD : WS_CHILD | WS_VISIBLE | BS_GROUPBOX
    gbexstyle : DWORD : WS_EX_CONTROLPARENT | WS_EX_LEFT | WS_EX_TRANSPARENT
// End of GroupBox constants.

// Form Constants
    menuTxtFlag :: DT_LEFT | DT_SINGLELINE | DT_VCENTER

// End of Form constants

// ListBox constants.
    LBS_DISABLENOSCROLL :: 4096
    LBS_EXTENDEDSEL :: 0x800
    LBS_HASSTRINGS :: 64
    LBS_MULTICOLUMN :: 512
    LBS_MULTIPLESEL :: 8
    LBS_NODATA :: 0x2000
    LBS_NOINTEGRALHEIGHT :: 256
    LBS_NOREDRAW :: 4
    LBS_NOSEL :: 0x4000
    LBS_NOTIFY :: 1
    LBS_OWNERDRAWFIXED :: 16
    LBS_OWNERDRAWVARIABLE :: 32
    LBS_SORT :: 2
    LBS_STANDARD :: 0xa00003
    LBS_USETABSTOPS :: 128
    LBS_WANTKEYBOARDINPUT :: 0x400

    LB_ADDFILE :: 406
    LB_ADDSTRING :: 384
    LB_DELETESTRING :: 386
    LB_DIR :: 397
    LB_ERR :: -1
    LB_FINDSTRING :: 399
    LB_FINDSTRINGEXACT :: 418
    LB_GETANCHORINDEX :: 413
    LB_GETCARETINDEX :: 415
    LB_GETCOUNT :: 395
    LB_GETCURSEL :: 392
    LB_GETHORIZONTALEXTENT :: 403
    LB_GETITEMDATA :: 409
    LB_GETITEMHEIGHT :: 417
    LB_GETITEMRECT :: 408
    LB_GETLOCALE :: 422
    LB_GETSEL :: 391
    LB_GETSELCOUNT :: 400
    LB_GETSELITEMS :: 401
    LB_GETTEXT :: 393
    LB_GETTEXTLEN :: 394
    LB_GETTOPINDEX :: 398
    LB_INITSTORAGE :: 424
    LB_INSERTSTRING :: 385
    LB_ITEMFROMPOINT :: 425
    LB_RESETCONTENT :: 388
    LB_SELECTSTRING :: 396
    LB_SELITEMRANGE :: 411
    LB_SELITEMRANGEEX :: 387
    LB_SETANCHORINDEX :: 412
    LB_SETCARETINDEX :: 414
    LB_SETCOLUMNWIDTH :: 405
    LB_SETCOUNT :: 423
    LB_SETCURSEL :: 390
    LB_SETHORIZONTALEXTENT :: 404
    LB_SETITEMDATA :: 410
    LB_SETITEMHEIGHT :: 416
    LB_SETLOCALE :: 421
    LB_SETSEL :: 389
    LB_SETTABSTOPS :: 402
    LB_SETTOPINDEX :: 407
    LB_GETLISTBOXINFO :: 434


    LBN_DBLCLK :: 2
    LBN_ERRSPACE :: -2
    LBN_KILLFOCUS :: 5
    LBN_SELCANCEL :: 3
    LBN_SELCHANGE :: 1
    LBN_SETFOCUS :: 4
// End of ListBox constants.

// ListView constants.

// End of ListView constants.

// Menu constants.

// End of Menu constants.

// NumberPicker constants.
    UD_MAXVAL :: 0x7fff
    UD_MINVAL :: (-UD_MAXVAL)
    ICC_UPDOWN_CLASS :: 0x10
    UDS_WRAP :: 0x1
    UDS_SETBUDDYINT :: 0x2
    UDS_ALIGNRIGHT :: 0x4
    UDS_ALIGNLEFT :: 0x8
    UDS_AUTOBUDDY :: 0x10
    UDS_ARROWKEYS :: 0x20
    UDS_HORZ :: 0x40
    UDS_NOTHOUSANDS :: 0x80
    UDS_HOTTRACK :: 0x100
    DCX_WINDOW1 : u32 : 0x00000001
    DCX_INTERSECTRGN1 : u32 : 0x00000080 
    ETO_OPAQUE : u32 :    0x0002
    EN_UPDATE :: 1024
    UDN_FIRST :: (UINT_MAX - 721)
    UDN_DELTAPOS :: (UDN_FIRST - 1)
    swp_flag : DWORD: SWP_SHOWWINDOW | SWP_NOACTIVATE | SWP_NOZORDER

// End of NumberPicker constants.

// ProgressBar Constants
    ICC_PROGRESS_CLASS :: 0x20
    PBS_SMOOTH :: 0x1
    PBS_VERTICAL :: 0x4
    PBS_MARQUEE :: 0x8
    PBM_SETBKCOLOR :: (0x2000 + 1)
    PBM_SETMARQUEE :: (WM_USER + 10)

    TMT_FILLCOLOR :: 3802
    DTT_COLORPROP :: 128
    DTT_SHADOWCOLOR :: 4
// End of ProgressBar Constants

// RadioButton constants.

// End of RadioButton constants.

// CheckBox constants.

// End of CheckBox constants.