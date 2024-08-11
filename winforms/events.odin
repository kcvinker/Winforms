package winforms
//import "core:fmt"

EventHandler :: proc(sender : ^Control, ea : ^EventArgs) //distinct #type
MouseEventHandler :: proc(sender : ^Control, e : ^MouseEventArgs)
KeyEventHandler :: proc(sender : ^Control, e : ^KeyEventArgs)
DateTimeEventHandler :: proc(sender : ^Control, e : ^DateTimeEvent)
PaintEventHandler :: proc(sender : ^Control, e : ^PaintEventArgs)
SizeEventHandler :: proc(sender : ^Control, e : ^SizeEventArgs)
LBoxEventHandler :: proc(sender : ^Control, e : string)
ThreadMsgHandler :: proc(wpm: WPARAM, lpm: LPARAM)
TreeEventHandler :: proc(sender : ^TreeView, e : ^TreeEventArgs)
MenuEventHandler :: proc(sender: ^MenuItem, e: ^EventArgs)
ContextMenuEventHandler :: proc(sender: ^ContextMenu, e: ^EventArgs)
TrayIconEventHandler :: proc(sender: ^TrayIcon, e: ^EventArgs)

CreateDelegate :: proc(ctl : ^Control)
ControlDelegate :: proc(ctl : ^Control)
PropSetter :: proc(c: ^Control, p: any, v : any)


EventArgs :: struct {handled : b64, cancelled : b64,}
MouseEventArgs :: struct
{
	using base : EventArgs,
	button : MouseButtons,
	clicks, delta : i32,
	shiftKey, ctrlKey : KeyState,
	x, y : int,
}

KeyEventArgs :: struct
{
    using base : EventArgs,
	altPressed : bool,
    ctrlPressed : bool,
    shiftPressed : bool,
    keyCode : KeyEnum,
    keyValue : int,
    suppressKeyPress : bool,
}

DateTimeEvent :: struct
{
    using base : EventArgs,
    dateString : string,
    dateStruct : SYSTEMTIME,
}

PaintEventArgs ::  struct
{
    using base : EventArgs,
    paintInfo : ^PAINTSTRUCT,
}

SizeEventArgs :: struct
{
    using base : EventArgs,
    formRect : ^RECT,
    sizedOn : SizedPosition,
    clientArea : Area,
   // sized_reason : SizedReason,
}

TreeEventArgs :: struct
{
    using base : EventArgs,
    action : TreeViewAction,
    node : ^TreeNode,
    oldNode : ^TreeNode,
}

new_event_args :: proc() -> EventArgs
{
	ea : EventArgs
	ea.handled = false
    ea.cancelled = false
	return ea
}

new_mouse_event_args :: proc(msg : u32, wp : WPARAM, lp : LPARAM) -> MouseEventArgs
{
	mea : MouseEventArgs
	fwKeys := cast(WORD) (wp & 0xffff) //(lo_word(cast(DWORD) wp))
	//fmt.println("fwKeys - ", fwKeys)
	mea.delta = cast(i32) (hi_word(cast(DWORD) wp))
	switch fwKeys {
	case 5 : mea.shiftKey = KeyState.Pressed
	case 9 : mea.ctrlKey = KeyState.Pressed
	case 17 : mea.button = MouseButtons.Middle
	case 33 : mea.button = MouseButtons.XButton1
	}

	switch msg {
	case WM_MOUSEWHEEL, WM_MOUSEMOVE, WM_MOUSEHOVER, WM_NCHITTEST :
		mea.x = cast(int) (lo_word(cast(DWORD) lp))
		mea.y = cast(int) (hi_word(cast(DWORD) lp))
	case WM_LBUTTONDOWN, WM_LBUTTONUP :
        mea.button = MouseButtons.Left
        mea.x = cast(int) (lo_word(cast(DWORD) lp))
        mea.y = cast(int) (hi_word(cast(DWORD) lp))
    case WM_RBUTTONDOWN, WM_RBUTTONUP :
        mea.button = MouseButtons.Right ;
        mea.x = cast(int) (lo_word(cast(DWORD) lp))
        mea.y = cast(int) (hi_word(cast(DWORD) lp))
	}
	return mea
}

new_key_event_args :: proc(wP : WPARAM) -> KeyEventArgs
{
	kea : KeyEventArgs
    kea.keyCode = KeyEnum(wP)
    kea.keyValue = cast(int) kea.keyCode
    #partial switch kea.keyCode {
	case KeyEnum.Shift : kea.shiftPressed = true
	case KeyEnum.Ctrl : kea.ctrlPressed = true
	case KeyEnum.Alt : kea.altPressed = true
    }
    return kea
}

new_paint_event_args :: proc(ps : ^PAINTSTRUCT) -> PaintEventArgs
{
    pea : PaintEventArgs
    pea.paintInfo = ps
    return pea
}

new_size_event_args :: proc(m : u32, wpm : WPARAM, lpm : LPARAM) -> SizeEventArgs
{
    sea : SizeEventArgs
    if m == WM_SIZING { // When resizing happening
        sea.sizedOn = SizedPosition(wpm)
        sea.formRect = direct_cast(lpm, ^RECT)
    }
    else { //After resizing finished
        //sea.sized_reason = SizedReason(wpm)
        sea.clientArea.width = int(loword_lparam(lpm))
        sea.clientArea.height = int(hiword_lparam(lpm))
    }
    return sea
}

new_tree_event_args :: proc{tree_event_args1, tree_event_args2}

tree_event_args1 :: proc(ntv : ^NMTREEVIEW) -> TreeEventArgs
{
    tea : TreeEventArgs
    if ntv.hdr.code == TVN_SELCHANGEDW || ntv.hdr.code == TVN_SELCHANGINGW {
        switch ntv.action {
            case 0 : tea.action = .Unknown
            case 1 : tea.action = .By_Mouse
            case 2 : tea.action = .By_Keyboard
        }
    }
    else if ntv.hdr.code == TVN_ITEMEXPANDEDW || ntv.hdr.code == TVN_ITEMEXPANDINGW {
        switch ntv.action {
            case 0 : tea.action = .Unknown
            case 1 : tea.action = .Collapse
            case 2 : tea.action = .Expand
        }
    }

    tea.node = direct_cast(ntv.itemNew.lParam, ^TreeNode)
    tea.oldNode = direct_cast(ntv.itemOld.lParam, ^TreeNode) if ntv.itemOld.lParam > 0 else nil
    return tea
}

tree_event_args2 :: proc(pic : ^TVITEMCHANGE) -> TreeEventArgs
{
    @static x : int
    tea : TreeEventArgs
    ptf("Printing count ---------[%d]\n", x)
    print("uChanged - ", pic.uChanged)
    print("UStateNew - ", pic.uStateNew)
    print("UStateOld - ", pic.uStateOld)
    print("----------------------------------------")
    x += 1
    return tea
}

//new_datetime_event_args :: proc()

SizedPosition :: enum
{
    Left_Edge = 1,
    Right_Edge,
    Top_Edge,
    Top_Left_Corner,
    Top_Right_Corner,
    Bottom_Edge,
    Bottom_Left_Corner,
    Bottom_Right_Corner,
}

SizedReason :: enum
{ // It is not using now.
    On_Restored,
    On_Minimized,
    On_Maximized,
    Other_Restored,
    Other_Maxmizied,
}

MouseButtons :: enum
{
	None = 0,
    Right = 2097152,
    Middle = 4194304,
    Left = 1048576,
    XButton1 = 8388608,
    XButton2 = 16777216,
}

TreeViewAction :: enum {Unknown, By_Keyboard, By_Mouse, Collapse, Expand,}

KeyState :: enum {Released, Pressed,}

KeyEnum :: enum
{
    Modifier = -65_536,
    None = 0,
    Left_Button, Right_Button, Cancel, Middle_Button, Xbutton1, Xbutton2,
    Back_Space = 8, Tab,
    Clear = 12, Enter,
    Shift = 16, Ctrl, Alt, Pause, Caps_Lock,
    Escape = 27,
    Space = 32, Page_Up, Page_Down, End, Home, Left_Arrow, Up_Arrow, Right_Arrow, Down_Arrow,
    Select, Print, Execute, Print_Screen, Insert, Del, Help,
    D0, D1, D2, D3, D4, D5, D6, D7, D8, D9,
    A = 65,
    B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    Left_Win, Right_Win, Apps,
    Sleep = 95,
    Numpad0, Numpad1, Numpad2, Numpad3, Numpad4, Numpad5, Numpad6, Numpad7, Numpad8, Numpad9,
    Multiply, Add, Seperator, Subtract, Decimal, Divide,
    F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24,
    Num_Lock = 144, Scroll,
    Left_Shift = 160, Right_Shift, Left_Ctrl, Right_Ctrl, Left_Menu, Right_Menu,
    Browser_Back, Browser_Forward, Brower_Refresh, Browser_Stop, Browser_Search, Browser_Favorites, Browser_Home,
    Volume_Mute, Volume_Down, Volume_Up,
    Media_Next_Track, Media_Prev_Track, Media_Stop, Media_Play_Pause, Launch_Mail, Select_Media,
    Launch_App1, Launch_App2,
    Colon = 186, Oem_Plus, Oem_Comma, Oem_Minus, Oem_Period, Oem_Question, Oem_Tilde,
    Oem_Open_Bracket = 219, Oem_Pipe, Oem_Close_Bracket, Oem_Quotes, Oem8,
    Oem_Back_Slash = 226,
    Process = 229,
    Packet = 231,
    Attn = 246, Cr_Sel, Ex_Sel, Erase_Eof, Play, Zoom, No_Name, Pa1, Oem_Clear,  // start from 400
}
