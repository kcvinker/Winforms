package winforms
//import "core:fmt"

EventHandler :: proc(sender : ^Control, ea : ^EventArgs) //distinct #type
MouseEventHandler :: proc(sender : ^Control, e : ^MouseEventArgs)
KeyEventHandler :: proc(sender : ^Control, e : ^KeyEventArgs)
DateTimeEventHandler :: proc(sender : ^Control, e : ^DateTimeEventArgs)
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

DateTimeEventArgs :: struct
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
	fwKeys := LOWORD(wp) // cast(WORD) (wp & 0xffff) //(lo_word(cast(DWORD) wp))
	//fmt.println("fwKeys - ", fwKeys)
	mea.delta = cast(i32)(HIWORD(wp))
	switch fwKeys {
	case 5 : mea.shiftKey = KeyState.Pressed
	case 9 : mea.ctrlKey = KeyState.Pressed
	case 17 : mea.button = MouseButtons.Middle
	case 33 : mea.button = MouseButtons.XButton1
	}

	switch msg {
	case WM_MOUSEWHEEL, WM_MOUSEMOVE, WM_MOUSEHOVER, WM_NCHITTEST :
		mea.x = int(get_x_lpm(lp)) //cast(int) (lo_word(cast(DWORD) lp))
		mea.y = int(get_y_lpm(lp)) //cast(int) (hi_word(cast(DWORD) lp))
	case WM_LBUTTONDOWN, WM_LBUTTONUP :
        mea.button = MouseButtons.Left
        mea.x = int(get_x_lpm(lp)) //
        mea.y = int(get_y_lpm(lp))
    case WM_RBUTTONDOWN, WM_RBUTTONUP :
        mea.button = MouseButtons.Right ;
        mea.x = int(get_x_lpm(lp)) //
        mea.y = int(get_y_lpm(lp))
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
        sea.formRect = dir_cast(lpm, ^RECT)
    }
    else { //After resizing finished
        //sea.sized_reason = SizedReason(wpm)
        sea.clientArea.width = int(LOWORD(lpm))
        sea.clientArea.height = int(HIWORD(lpm))
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

    tea.node = dir_cast(ntv.itemNew.lParam, ^TreeNode)
    tea.oldNode = dir_cast(ntv.itemOld.lParam, ^TreeNode) if ntv.itemOld.lParam > 0 else nil
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



