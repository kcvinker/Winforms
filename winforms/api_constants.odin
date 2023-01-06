package winforms

//import "core:math/bits"

U64MAX :: ~u64(0) // When CPP code shows minus value from an unsigned type, do this. You will get the max value for that type.
U32MAX :: ~u32(0) // Same as above. Remember to add 1 after deduct those negative values.
UINT_MAX :: 1 << 32
U16MAX :: 1 << 16

// Window class Constants
CS_VREDRAW    :: 0x0001
CS_HREDRAW    :: 0x0002
CS_OWNDC      :: 0x0020
CW_USEDEFAULT :: -0x80000000

CCS_TOP           :: 1
CCS_NOMOVEY       :: 2
CCS_BOTTOM        :: 3
CCS_NORESIZE      :: 4
CCS_NOPARENTALIGN :: 8
CCS_ADJUSTABLE    :: 32
CCS_NODIVIDER     :: 64
CCS_VERT    :: 128
CCS_LEFT    :: 129
CCS_NOMOVEX :: 130
CCS_RIGHT   :: 131



//Windoe displaying Constants
SW_HIDE :: 0
SW_SHOWNORMAL :: 1
SW_NORMAL :: 1
SW_SHOWMINIMIZED :: 2
SW_SHOWMAXIMIZED :: 3

SW_SHOW :: 5


// Get window long ptr Constants
GWL_EXSTYLE              :: -20
GWLP_HINSTANCE           :: -6
GWLP_ID                  :: -12
GWL_STYLE                :: -16
GWLP_USERDATA            :: -21
GWLP_WNDPROC             :: -4

// virtual key code mapping
MAPVK_VK_TO_VSC :: 0
MAPVK_VSC_TO_VK :: 1
MAPVK_VK_TO_CHAR :: 2
MAPVK_VSC_TO_VK_EX :: 3
MAPVK_VK_TO_VSC_EX :: 4



// Window Styles Constants
WS_OVERLAPPED       :: 0
WS_MAXIMIZEBOX      :: 0x00010000
WS_MINIMIZEBOX      :: 0x00020000
WS_THICKFRAME       :: 0x00040000
WS_SYSMENU          :: 0x00080000
WS_BORDER           :: 0x00800000
WS_CAPTION          :: 0x00C00000
WS_VISIBLE          :: 0x10000000
WS_POPUP            :: 0x80000000
WS_MAXIMIZE         :: 0x01000000
WS_MINIMIZE         :: 0x20000000
WS_TABSTOP          :: 0x00010000
WS_CLIPCHILDREN     :: 0x02000000
WS_CLIPSIBLINGS     :: 0x04000000
WS_OVERLAPPEDWINDOW :: WS_OVERLAPPED|WS_CAPTION|WS_SYSMENU|WS_THICKFRAME|WS_MINIMIZEBOX|WS_MAXIMIZEBOX
WS_POPUPWINDOW      :: WS_POPUP|WS_BORDER|WS_SYSMENU
WS_CHILD            :: 0x40000000
WS_HSCROLL          :: 0x00100000
WS_VSCROLL          :: 0x00200000


WS_EX_DLGMODALFRAME        :: 0x00000001
WS_EX_NOPARENTNOTIFY       :: 0x00000004
WS_EX_TOPMOST              :: 0x00000008
WS_EX_ACCEPTFILES          :: 0x00000010
WS_EX_TRANSPARENT          :: 0x00000020
WS_EX_MDICHILD             :: 0x00000040
WS_EX_TOOLWINDOW           :: 0x00000080
WS_EX_WINDOWEDGE           :: 0x00000100
WS_EX_CLIENTEDGE           :: 0x00000200
WS_EX_CONTEXTHELP          :: 0x00000400
WS_EX_RIGHT                :: 0x00001000
WS_EX_LEFT                 :: 0x00000000
WS_EX_RTLREADING           :: 0x00002000
WS_EX_LTRREADING           :: 0x00000000
WS_EX_LEFTSCROLLBAR        :: 0x00004000
WS_EX_RIGHTSCROLLBAR       :: 0x00000000
WS_EX_CONTROLPARENT        :: 0x00010000
WS_EX_STATICEDGE           :: 0x00020000
WS_EX_APPWINDOW            :: 0x00040000
WS_EX_OVERLAPPEDWINDOW     :: WS_EX_WINDOWEDGE|WS_EX_CLIENTEDGE
WS_EX_PALETTEWINDOW        :: WS_EX_WINDOWEDGE|WS_EX_TOOLWINDOW|WS_EX_TOPMOST
WS_EX_LAYERED              :: 0x00080000
WS_EX_NOINHERITLAYOUT      :: 0x00100000 // Disable inheritence of mirroring by children
WS_EX_NOREDIRECTIONBITMAP  :: 0x00200000
WS_EX_LAYOUTRTL            :: 0x00400000 // Right to left mirroring
WS_EX_COMPOSITED           :: 0x02000000
WS_EX_NOACTIVATE           :: 0x08000000
WS_GROUP					:: 0x00020000
WS_DLGFRAME 				:: 0x00400000

DCX_WINDOW :: Long(0x00000001)
DCX_INTERSECTRGN :: Long(0x00000080)



// Icon & Cursor Constants
IDC_APPSTARTING := make_int_resource(32650)
IDC_ARROW       := make_int_resource(32512)
IDC_CROSS       := make_int_resource(32515)
IDC_HAND        := make_int_resource(32649)
IDC_HELP        := make_int_resource(32651)
IDC_IBEAM       := make_int_resource(32513)
IDC_ICON        := make_int_resource(32641)
IDC_NO          := make_int_resource(32648)
IDC_SIZE        := make_int_resource(32640)
IDC_SIZEALL     := make_int_resource(32646)
IDC_SIZENESW    := make_int_resource(32643)
IDC_SIZENS      := make_int_resource(32645)
IDC_SIZENWSE    := make_int_resource(32642)
IDC_SIZEWE      := make_int_resource(32644)
IDC_UPARROW     := make_int_resource(32516)
IDC_WAIT        := make_int_resource(32514)


// Cursor Constants
IDI_APPLICATION    := make_int_resource(32512)
IDI_ASTERISK       := make_int_resource(32516)
IDI_ERROR          := make_int_resource(32513)
IDI_EXCLAMATION    := make_int_resource(32515)
IDI_HAND           := make_int_resource(32513)
IDI_INFORMATION    := make_int_resource(32516)
IDI_QUESTION       := make_int_resource(32514)
IDI_SHIELD         := make_int_resource(32518)
IDI_WARNING        := make_int_resource(32515)
IDI_WINLOGO        := make_int_resource(32517)

// DrawEdge function flags
BDR_RAISEDOUTER :: 0x0001
BDR_SUNKENOUTER :: 0x0002
BDR_RAISEDINNER :: 0x0004
BDR_SUNKENINNER :: 0x0008

BDR_OUTER :: (BDR_RAISEDOUTER | BDR_SUNKENOUTER)
BDR_INNER :: (BDR_RAISEDINNER | BDR_SUNKENINNER)
BDR_RAISED :: (BDR_RAISEDOUTER | BDR_RAISEDINNER)
BDR_SUNKEN :: (BDR_SUNKENOUTER | BDR_SUNKENINNER)

EDGE_RAISED :: (BDR_RAISEDOUTER | BDR_RAISEDINNER)
EDGE_SUNKEN :: (BDR_SUNKENOUTER | BDR_SUNKENINNER)
EDGE_ETCHED :: (BDR_SUNKENOUTER | BDR_RAISEDINNER)
EDGE_BUMP :: (BDR_RAISEDOUTER | BDR_SUNKENINNER)

BCM_FIRST :: 0x1600
BCM_GETIDEALSIZE :: BCM_FIRST + 0x0001

BF_LEFT :: 0x0001
BF_TOP :: 0x0002
BF_RIGHT :: 0x0004
BF_BOTTOM :: 0x0008
BF_TOPLEFT :: (BF_TOP | BF_LEFT)
BF_TOPRIGHT :: (BF_TOP | BF_RIGHT)
BF_BOTTOMLEFT :: (BF_BOTTOM | BF_LEFT)
BF_BOTTOMRIGHT :: (BF_BOTTOM | BF_RIGHT)
BF_RECT :: (BF_LEFT | BF_TOP | BF_RIGHT | BF_BOTTOM)
BF_DIAGONAL :: 0x0010
BF_DIAGONAL_ENDTOPRIGHT :: (BF_DIAGONAL | BF_TOP | BF_RIGHT)
BF_DIAGONAL_ENDTOPLEFT :: (BF_DIAGONAL | BF_TOP | BF_LEFT)
BF_DIAGONAL_ENDBOTTOMLEFT :: (BF_DIAGONAL | BF_BOTTOM | BF_LEFT)
BF_DIAGONAL_ENDBOTTOMRIGHT :: (BF_DIAGONAL | BF_BOTTOM | BF_RIGHT)
BF_MIDDLE :: 0x0800
BF_SOFT :: 0x1000
BF_ADJUST :: 0x2000
BF_FLAT :: 0x4000
BF_MONO :: 0x8000




//Color Constants
Color_3D_Face :: 15 // Face color for three-dimensional display elements and for dialog box backgrounds.
Color_Btn_Text :: 18 // Text on push buttons. The associated background color is COLOR_BTNFACE.
Color_Graytext :: 17 // Grayed (disabled) text. This color is set to 0 if the current display driver does not support a solid gray color.
Color_Highlight :: 16 // Item(s) selected in a control. The associated foreground color is COLOR_HIGHLIGHTTEXT.
Color_Highlight_Text :: 14 // Text of item(s) selected in a control. The associated background color is COLOR_HIGHLIGHT.
Color_Hotlight :: 26 // Color for a hyperlink or hot-tracked item. The associated background color is COLOR_WINDOW.
Color_Window :: 5 // Window background. The associated foreground colors are COLOR_WINDOWTEXT and COLOR_HOTLITE.
Color_Window_Text :: 8


//Codepage Constants
CP_ACP        :: 0     // default to ANSI code page
CP_OEMCP      :: 1     // default to OEM  code page
CP_MACCP      :: 2     // default to MAC  code page
CP_THREAD_ACP :: 3     // current thread's ANSI code page
CP_SYMBOL     :: 42    // SYMBOL translations
CP_UTF7       :: 65000 // UTF-7 translation
CP_UTF8       :: 65001 // UTF-8 translation

MB_ERR_INVALID_CHARS :: 8
WC_ERR_INVALID_CHARS :: 128


//Track mouse event constants
TME_CANCEL :: 0x80000000
TME_HOVER :: 0x00000001
TME_LEAVE :: 0x00000002
TME_NONCLIENT :: 0x00000010
TME_QUERY :: 0x40000000
HOVER_DEFAULT :: 0xFFFFFFFF;

// Sys command messages
SC_SIZE :: 0xF000
SC_MOVE :: 0xF010
SC_MINIMIZE :: 0xF020
SC_ICON :: 0xf020
SC_MAXIMIZE :: 0xF030
SC_ZOOM :: 0xF030
SC_NEXTWINDOW :: 0xF040
SC_PREVWINDOW :: 0xF050
SC_CLOSE :: 0xF060
SC_VSCROLL :: 0xF070
SC_HSCROLL :: 0xF080
SC_MOUSEMENU :: 0xF090
SC_KEYMENU :: 0xF100
SC_ARRANGE :: 0xF110
SC_RESTORE :: 0xF120
SC_TASKLIST :: 0xF130
SC_SCREENSAVE :: 0xF140
SC_HOTKEY :: 0xF150
SC_DEFAULT :: 0xF160
SC_MONITORPOWER :: 0xF170
SC_CONTEXTHELP :: 0xF180
SC_SEPARATOR :: 0xF00F


SWP_DRAWFRAME :: 32
SWP_FRAMECHANGED :: 32
SWP_HIDEWINDOW :: 128
SWP_NOACTIVATE :: 16
SWP_NOCOPYBITS :: 256
SWP_NOMOVE :: 2
SWP_NOSIZE :: 1
SWP_NOREDRAW :: 8
SWP_NOZORDER :: 4
SWP_SHOWWINDOW :: 64
SWP_NOOWNERZORDER :: 512
SWP_NOREPOSITION :: 512
SWP_NOSENDCHANGING :: 1024
SWP_DEFERERASE :: 8192
SWP_ASYNCWINDOWPOS :: 16384

Transparent :: 1
Opaque :: 2

DT_BOTTOM ::8
DT_CALCRECT ::1024
DT_CENTER ::1
DT_EDITCONTROL ::8192
DT_END_ELLIPSIS ::32768
DT_PATH_ELLIPSIS ::16384
DT_WORD_ELLIPSIS ::0x40000
DT_EXPANDTABS ::64
DT_EXTERNALLEADING ::512
DT_LEFT ::0
DT_MODIFYSTRING ::65536
DT_NOCLIP ::256
DT_NOPREFIX ::2048
DT_RIGHT ::2
DT_RTLREADING ::131072
DT_SINGLELINE ::32
DT_TABSTOP ::128
DT_TOP ::0
DT_VCENTER ::4
DT_WORDBREAK ::16
DT_INTERNAL ::4096
DT_NOFULLWIDTHCHARBREAK :: 0x00080000
DT_HIDEPREFIX :: 0x00100000
DT_PREFIXONLY :: 0x00200000

CDRF_DODEFAULT         :: 0
CDRF_NEWFONT           :: 2
CDRF_SKIPDEFAULT       :: 4
CDRF_DOERASE            :: 8
CDRF_NOTIFYPOSTPAINT   :: 16
CDRF_NOTIFYITEMDRAW    :: 32
CDRF_NOTIFYSUBITEMDRAW :: 32
CDRF_NOTIFYPOSTERASE   :: 64
CDRF_NOTIFYITEMERASE   :: 128
CDRF_SKIPPOSTPAINT      :: 256

CDDS_PREPAINT      :: 1     // This comes second
CDDS_POSTPAINT     :: 2     // this coms last
CDDS_PREERASE      :: 3  // This comes first
CDDS_POSTERASE     :: 4 // This is 4rth combined ith pre erase
CDDS_ITEM          :: 65536
CDDS_SUBITEM       :: 0x20000
CDDS_ITEMPOSTERASE :: CDDS_ITEM | CDDS_POSTERASE
CDDS_ITEMPOSTPAINT :: CDDS_ITEM | CDDS_POSTPAINT
CDDS_ITEMPREERASE  :: CDDS_ITEM | CDDS_PREERASE
CDDS_ITEMPREPAINT  :: CDDS_ITEM | CDDS_PREPAINT

CDIS_SELECTED           :: 0x1
CDIS_GRAYED             :: 0x2
CDIS_DISABLED           :: 0x4
CDIS_CHECKED            :: 0x8
CDIS_FOCUS              :: 0x10
CDIS_DEFAULT            :: 0x20
CDIS_HOT                :: 0x40
CDIS_MARKED             :: 0x80
CDIS_INDETERMINATE      :: 0x100
CDIS_SHOWKEYBOARDCUES   :: 0x200


U32_NM_FIRST := max(u32)
NM_FIRST  := U32_NM_FIRST + 1 //~u64(0) - 1 // (0U - 0U)

// NM_OUTOFMEMORY :: (NM_FIRST-1)
NM_CLICK :: 4294967294
// NM_DBLCLK :: (NM_FIRST-3)
// NM_RETURN :: (NM_FIRST-4)
// NM_RCLICK :: (NM_FIRST-5)
// NM_RDBLCLK :: (NM_FIRST-6)
// NM_SETFOCUS :: (NM_FIRST-7)
// NM_KILLFOCUS :: (NM_FIRST-8)
NM_CUSTOMDRAW ::  4294967284
NM_HOVER :: 4294967283 // (NM_FIRST-13)
// NM_NCHITTEST :: (NM_FIRST-14)
// NM_KEYDOWN :: (NM_FIRST-15)
NM_RELEASEDCAPTURE :: 4294967284 // (NM_FIRST-16)
// NM_SETCURSOR :: (NM_FIRST-17)
// NM_CHAR :: (NM_FIRST-18)
// NM_TOOLTIPSCREATED :: (NM_FIRST-19)
 NM_LDOWN := (NM_FIRST-20) // 4294967276
// NM_RDOWN :: (NM_FIRST-21)
// NM_THEMECHANGED :: (NM_FIRST-22)


ICC_STANDARD_CLASSES :: 0x00004000

PS_SOLID       :: 0
PS_DASH        :: 1
PS_DOT         :: 2
PS_DASHDOT     :: 3
PS_DASHDOTDOT  :: 4
PS_NULL        :: 5
PS_INSIDEFRAME :: 6
PS_USERSTYLE   :: 7
PS_ALTERNATE   :: 8
PS_STYLE_MASK  :: 15

RDW_INVALIDATE      :: 1
RDW_INTERNALPAINT   :: 2
RDW_ERASE           :: 4
RDW_VALIDATE        :: 8
RDW_NOINTERNALPAINT :: 16
RDW_NOERASE         :: 32
RDW_NOCHILDREN      :: 64
RDW_ALLCHILDREN     :: 128
RDW_UPDATENOW       :: 256
RDW_ERASENOW        :: 512
RDW_FRAME           :: 1024
RDW_NOFRAME         :: 2048



SS_BITMAP ::  14
SS_BLACKFRAME ::  7
SS_BLACKRECT ::  4
SS_CENTER ::  1
SS_CENTERIMAGE ::  512
SS_ENHMETAFILE ::  15
SS_ETCHEDFRAME ::  18
SS_ETCHEDHORZ ::  16
SS_ETCHEDVERT ::  17
SS_GRAYFRAME ::  8
SS_GRAYRECT ::  5
SS_ICON ::  3
SS_LEFT ::  0
SS_LEFTNOWORDWRAP ::  0xc
SS_NOPREFIX ::  128
SS_NOTIFY ::  256
SS_OWNERDRAW ::  0xd
SS_REALSIZEIMAGE ::  0x800
SS_RIGHT ::  2
SS_RIGHTJUST ::  0x400
SS_SIMPLE ::  11
SS_SUNKEN ::  4096
SS_WHITEFRAME ::  9
SS_WHITERECT ::  6
SS_USERITEM ::  10
SS_TYPEMASK ::  0x0000001F
SS_ENDELLIPSIS ::  0x00004000
SS_PATHELLIPSIS ::  0x00008000
SS_WORDELLIPSIS ::  0x0000C000
SS_ELLIPSISMASK ::  0x0000C000

ES_AUTOHSCROLL ::  128
ES_AUTOVSCROLL ::  64
ES_CENTER ::  1
ES_LEFT ::  0
ES_LOWERCASE ::  16
ES_MULTILINE ::  4
ES_NOHIDESEL ::  256
ES_NUMBER ::  0x2000
ES_OEMCONVERT ::  0x400
ES_PASSWORD ::  32
ES_READONLY ::  0x800
ES_RIGHT ::  2
ES_UPPERCASE ::  8
ES_WANTRETURN ::  4096

ECM_FIRST :: 0x1500
EM_SETCUEBANNER :: ECM_FIRST + 1
EM_GETCUEBANNER :: ECM_FIRST + 2
EM_SHOWBALLOONTIP :: ECM_FIRST + 3
EM_HIDEBALLOONTIP :: ECM_FIRST + 4

WHITE_BRUSH :: 0
LTGRAY_BRUSH :: 1
GRAY_BRUSH :: 2
DKGRAY_BRUSH :: 3
BLACK_BRUSH :: 4
HOLLOW_BRUSH :: 5
NULL_BRUSH :: HOLLOW_BRUSH
WHITE_PEN :: 6
BLACK_PEN :: 7
NULL_PEN :: 8

BS_3STATE :: 5
BS_AUTO3STATE :: 6
BS_AUTOCHECKBOX :: 3
BS_AUTORADIOBUTTON :: 9
BS_BITMAP :: 128
BS_BOTTOM :: 0x800
BS_CENTER :: 0x300
BS_CHECKBOX :: 2
BS_DEFPUSHBUTTON :: 1
BS_GROUPBOX :: 7
BS_ICON :: 64
BS_LEFT :: 256
BS_LEFTTEXT :: 32
BS_MULTILINE :: 0x2000
BS_NOTIFY :: 0x4000
BS_OWNERDRAW :: 0xb
BS_PUSHBUTTON :: 0
BS_PUSHLIKE :: 4096
BS_RADIOBUTTON :: 4
BS_RIGHT :: 512
BS_RIGHTBUTTON :: 32
BS_TEXT :: 0
BS_TOP :: 0x400
BS_USERBUTTON :: 8
BS_VCENTER :: 0xc00
BS_FLAT :: 0x8000

CBS_AUTOHSCROLL ::64
CBS_DISABLENOSCROLL ::0x800
CBS_DROPDOWN ::2
CBS_DROPDOWNLIST ::3
CBS_HASSTRINGS ::512
CBS_LOWERCASE ::0x4000
CBS_NOINTEGRALHEIGHT ::0x400
CBS_OEMCONVERT ::128
CBS_OWNERDRAWFIXED ::16
CBS_OWNERDRAWVARIABLE ::32
CBS_SIMPLE ::1
CBS_SORT ::256
CBS_UPPERCASE ::0x2000

CB_ADDSTRING :: 323
CB_DELETESTRING :: 324
CB_DIR :: 325
CB_FINDSTRING :: 332
CB_FINDSTRINGEXACT :: 344
CB_GETCOUNT :: 326
CB_GETCURSEL :: 327
CB_GETDROPPEDCONTROLRECT :: 338
CB_GETDROPPEDSTATE :: 343
CB_GETDROPPEDWIDTH :: 351
CB_GETEDITSEL :: 320
CB_GETEXTENDEDUI :: 342
CB_GETHORIZONTALEXTENT :: 349
CB_GETITEMDATA :: 336
CB_GETITEMHEIGHT :: 340
CB_GETLBTEXT :: 328
CB_GETLBTEXTLEN :: 329
CB_GETLOCALE :: 346
CB_GETTOPINDEX :: 347
CB_INITSTORAGE :: 353
CB_INSERTSTRING :: 330
CB_LIMITTEXT :: 321
CB_RESETCONTENT :: 331
CB_SELECTSTRING :: 333
CB_SETCURSEL :: 334
CB_SETDROPPEDWIDTH :: 352
CB_SETEDITSEL :: 322
CB_SETEXTENDEDUI :: 341
CB_SETHORIZONTALEXTENT :: 350
CB_SETITEMDATA :: 337
CB_SETITEMHEIGHT :: 339
CB_SETLOCALE :: 345
CB_SETTOPINDEX :: 348
CB_SHOWDROPDOWN :: 335
CB_GETCOMBOBOXINFO :: 356

CBM_FIRST :: 0x1700
CB_SETMINVISIBLE :: CBM_FIRST + 1
CB_GETMINVISIBLE :: CBM_FIRST + 2
CB_SETCUEBANNER :: CBM_FIRST + 3
CB_GETCUEBANNER :: CBM_FIRST + 4

CBN_CLOSEUP :: 8
CBN_DBLCLK :: 2
CBN_DROPDOWN :: 7
CBN_EDITCHANGE :: 5
CBN_EDITUPDATE :: 6
CBN_ERRSPACE :: -1
CBN_KILLFOCUS :: 4
CBN_SELCHANGE :: 1
CBN_SELENDCANCEL :: 10
CBN_SELENDOK :: 9
CBN_SETFOCUS :: 3

CB_OKAY :: 0
CB_ERR :: -1
CB_ERRSPACE :: -2








fixed_single_ex_style ::  WS_EX_LEFT |
                            WS_EX_LTRREADING |
                            WS_EX_RIGHTSCROLLBAR |
                            WS_EX_WINDOWEDGE |
                            WS_EX_CONTROLPARENT |
                            WS_EX_APPWINDOW ;

fixed_single_style ::    WS_OVERLAPPED |
                            WS_TABSTOP |
                            WS_MAXIMIZEBOX |
                            WS_MINIMIZEBOX |
                            WS_GROUP |
                            WS_SYSMENU |
                            WS_DLGFRAME |
                            WS_BORDER |
                            WS_CAPTION |
                            WS_CLIPCHILDREN |
                            WS_CLIPSIBLINGS ;

fixed_3d_ex_style ::      WS_EX_LEFT |
                            WS_EX_LTRREADING |
                            WS_EX_RIGHTSCROLLBAR |
                            WS_EX_WINDOWEDGE |
                            WS_EX_CLIENTEDGE |
                            WS_EX_CONTROLPARENT |
                            WS_EX_APPWINDOW |
                            WS_EX_OVERLAPPEDWINDOW ;

fixed_3d_style ::        WS_OVERLAPPED |
                            WS_TABSTOP |
                            WS_MAXIMIZEBOX |
                            WS_MINIMIZEBOX |
                            WS_GROUP |
                            WS_SYSMENU |
                            WS_DLGFRAME |
                            WS_BORDER |
                            WS_CAPTION |
                            WS_CLIPCHILDREN |
                            WS_CLIPSIBLINGS ;

fixed_dialog_ex_style ::  WS_EX_LEFT |
                            WS_EX_LTRREADING |
                            WS_EX_RIGHTSCROLLBAR |
                            WS_EX_DLGMODALFRAME |
                            WS_EX_WINDOWEDGE |
                            WS_EX_CONTROLPARENT |
                            WS_EX_APPWINDOW ;

fixed_dialog_style ::    WS_OVERLAPPED |
                            WS_TABSTOP |
                            WS_MAXIMIZEBOX |
                            WS_MINIMIZEBOX |
                            WS_GROUP |
                            WS_SYSMENU |
                            WS_DLGFRAME |
                            WS_BORDER |
                            WS_CAPTION |
                            WS_CLIPCHILDREN |
                            WS_CLIPSIBLINGS ;

normal_form_ex_style ::    WS_EX_LEFT |
                            WS_EX_LTRREADING |
                            WS_EX_RIGHTSCROLLBAR |
                            WS_EX_WINDOWEDGE |
                            WS_EX_CONTROLPARENT |
                            WS_EX_APPWINDOW

normal_form_style ::      WS_OVERLAPPEDWINDOW |
                            WS_TABSTOP | WS_BORDER |
                            WS_CLIPCHILDREN |
                            WS_CLIPSIBLINGS

fixed_tool_ex_style ::    WS_EX_LEFT |
                            WS_EX_LTRREADING |
                            WS_EX_RIGHTSCROLLBAR |
                            WS_EX_TOOLWINDOW |
                            WS_EX_WINDOWEDGE |
                            WS_EX_CONTROLPARENT |
                            WS_EX_APPWINDOW ;

fixed_tool_style ::      WS_OVERLAPPED |
                            WS_TABSTOP |
                            WS_MAXIMIZEBOX |
                            WS_MINIMIZEBOX |
                            WS_GROUP |
                            WS_SYSMENU |
                            WS_DLGFRAME |
                            WS_BORDER |
                            WS_CAPTION |
                            WS_CLIPCHILDREN |
                            WS_CLIPSIBLINGS ;

sizable_tool_ex_style ::  WS_EX_LEFT |
                            WS_EX_LTRREADING |
                            WS_EX_RIGHTSCROLLBAR |
                            WS_EX_TOOLWINDOW |
                            WS_EX_WINDOWEDGE |
                            WS_EX_CONTROLPARENT |
                            WS_EX_APPWINDOW ;

sizable_tool_style ::    WS_OVERLAPPED |
                            WS_TABSTOP |
                            WS_MAXIMIZEBOX |
                            WS_MINIMIZEBOX |
                            WS_GROUP |
                            WS_THICKFRAME |
                            WS_SYSMENU |
                            WS_DLGFRAME |
                            WS_BORDER |
                            WS_CAPTION |
                            WS_OVERLAPPEDWINDOW |
                            WS_CLIPCHILDREN |
                            WS_CLIPSIBLINGS ;