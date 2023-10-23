/*
	Updated on 3rd week of 2023 October.
	Reason : In first version, controls are merely structs. They are lived in stack. After doing some nice projects in
	non-GCed languages like C3, I gained some knowledge and courage to work with heap objects.
	So, I decided to re-write entire Winforms library & now controls are structs which living in heap.
	So, we can handle them like classes. Besides that, I wrote some nice constructors for controls like
	ListView. Now, you don't need to manually call the create_handle function for every control. Just pass a
	boolean parameter to the constructor and it wil call the function for you.
	IMPORTANT: Improved the memory leak scanning via passing the context to wndproc functions of all controls.
	Now, you can see the memory leaks & bad frees by calling 'show_memory_report' function.
*/
package winforms

import "core:runtime"

globalSubClassID : int = 2001
globalCtlID : UINT= 100

ControlKind :: enum
{
	Form,
	Button,
	Calendar,
	Check_Box,
	Combo_Box,
	Date_Time_Picker,
	Group_Box,
	Label,
	List_Box,
	List_View,
	Number_Picker,
	Panel,
	Progress_Bar,
	Radio_Button,
	Text_Box,
	Track_Bar,
	Tree_View,
}

// A base class for all controls & Form.
Control :: struct
{
	kind : ControlKind,
	name : string,
	handle : HWND,
	controlID : UINT,
	parent : ^Form,
	text : string,
	width, height : int,
    xpos, ypos : int,
    font : Font,
	backColor : uint,
	foreColor : uint,
	enabled : bool,
	visible : bool,

    _style, _exStyle : DWORD,
	_isCreated : b64,
	_isMouseTracking, _isMouseEntered : bool,
	_mDownHappened, _mRDownHappened : bool,
	_SizeIncr : SizeIncrement,
	_clsName : wstring,
	_drawFlag: uint,
	_fp_beforeCreation, _fp_afterCreation : CreateDelegate,
	_fp_size_fix : ControlDelegate,


	clrChanged : bool,

	paint : PaintEventHandler,
	onGotFocus,
	onLostFocus ,
	onMouseEnter,
	onMouseClick,
	onRightClick,
	onDoubleClick,
	onMouseLeave,
	onSizeChanging,
	onSizeChanged : EventHandler,

    onMouseDown,
    onRightMouseDown,
    onMouseUp,
    onRightMouseUp,
    onMouseScroll,
    onMouseMove,
	onMouseHover : MouseEventHandler,

    onKeyUp,
	onKeyDown,
	onKeyPress : KeyEventHandler,
	onDestroy : EventHandler,
}

@private control_cast :: proc($T : typeid, refd : DWORD_PTR) -> ^T
{
	return cast(^T) (cast(UINT_PTR) refd)
}

@private set_subclass :: proc(ctl : ^Control, fn_ptr : SUBCLASSPROC )
{
	SetWindowSubclass(ctl.handle, fn_ptr, UINT_PTR(globalSubClassID), to_dwptr(ctl) )
	globalSubClassID += 1
}

// This is used to set the defualt font right creating the control handle.
@private setfont_internal :: proc(ctl : ^Control)
{
	isOkay : bool
	if ctl.font.handle != ctl.parent.font.handle do isOkay = true
	if ctl.font._defFontChanged do isOkay = true
	if isOkay {
		CreateFont_handle(&ctl.font, ctl.handle)
		SendMessage(ctl.handle, WM_SETFONT, WPARAM(ctl.font.handle), LPARAM(1))
	}
}

redraw :: proc{redraw_ctl1, redraw_ctl2}
@private
redraw_ctl1 :: proc(ctl : ^Control) { if ctl._isCreated do InvalidateRect(ctl.handle, nil, false) }
@private
redraw_ctl2:: proc(ctl : Control) { if ctl._isCreated do InvalidateRect(ctl.handle, nil, false) }

// Enable or disable a control or form.
control_enable :: proc(ctl : ^Control, bstate : bool)
{
	ctl.enabled = bstate
	#partial switch ctl.kind {
		case .Number_Picker :
			SendMessage(ctl.handle, WM_ENABLE, WPARAM(bstate), 0)
		case :
			EnableWindow(ctl.handle, bstate)
	}
}

@private map_parent_points :: proc(this: ^Control) -> RECT
{
    rc : RECT
    firstHwnd : HWND
    if this._isCreated
	{
        GetClientRect(this.handle, &rc)
        firstHwnd = this.handle
	} else {
        firstHwnd = this.parent.handle
        rc = RECT{i32(this.xpos), i32(this.ypos),
					i32(this.xpos + this.width), i32(this.ypos + this.height )}
	}
    MapWindowPoints(firstHwnd, this.parent.handle, cast(^POINT)&rc, 2)
    return rc
}

cright :: proc(this: ^Control) -> int
{
	// rc : RECT
	// GetClientRect(this.handle, &rc)
	// MapWindowPoints(this.handle, this.parent.handle, cast(^POINT)&rc, 2);
	// return int(rc.right)
	return int(map_parent_points(this).right)
}

cbottom :: proc(this: ^Control) -> int
{
	// rc : RECT
	// GetClientRect(this.handle, &rc)
	// MapWindowPoints(this.handle, this.parent.handle, cast(^POINT)&rc, 2);
	// return int(rc.bottom)
	return int(map_parent_points(this).bottom)
}

// Hide or show a control.
control_visibile :: proc(ctl : ^Control, bstate : bool)
{
	ctl.enabled = bstate
	flag : i32 = SW_HIDE if !bstate else SW_SHOW
	// #partial switch ctl.kind {
	// 	case .Number_Picker :
	// 		np := direct_cast(ctl, ^NumberPicker)
	// 		ShowWindow(np.handle, flag)
	// 		ShowWindow(np._buddyHandle, flag)
	// 	case :
	// 		ShowWindow(ctl.handle, flag)
	// }
}

control_setdisable :: proc(this: ^Control, value: b8)
{
	if this._isCreated do EnableWindow(this.handle, !value)
}

control_set_foreground :: proc(this: ^Control)
{
	if this._isCreated do SetForegroundWindow(this.handle)
}

// control_isdisable :: proc(this: ^Control) -> b8
// {
// 	if this._isCreated do EnableWindow(this.handle, !value)
// }

// To set a user defined font before or after creating the control handle
control_set_font :: proc(ctl : ^Control, fn : string, fsz : int,
							fw : FontWeight = .Normal, fi : bool = false, fu : bool = false)
{
	using ctl.font
	name = fn
	size = fsz
	weight = fw
	italics = fi
	underline = fu
	_defFontChanged = true
	if ctl.handle != nil { // Only set the font if control handle is created.
		CreateFont_handle(&ctl.font, ctl.handle)
		SendMessage(ctl.handle, WM_SETFONT, WPARAM(ctl.font.handle), LPARAM(1))
		// if ctl.kind == .Label { // Label need special care only because of the autosize property
		// 	lb := cast(^Label) ctl
		// 	if lb.autoSize do calculate_ctl_size(lb)
		// }
	}
	if ctl._fp_size_fix != nil do ctl._fp_size_fix(ctl)
}

control_set_font_name :: proc(ctl : ^Control, fn : string)
{
	ctl.font._defFontChanged = true
	ctl.font.name = fn
	if ctl._isCreated do control_set_font(ctl, fn, ctl.font.size)
}

 control_set_font_size :: proc(ctl : ^Control, fsz : int, )
{
	ctl.font._defFontChanged = true
	ctl.font.size = fsz
	if ctl._isCreated do control_set_font(ctl, ctl.font.name, fsz)
}


// To set the position of a control or form
control_set_position :: proc(ctl : ^Control, x, y : int)
{
	mx : int = ctl.xpos if x == 0 else x
	my : int = ctl.ypos if y == 0 else y
	SetWindowPos(ctl.handle, nil, i32(mx), i32(my), 0, 0, SWP_NOSIZE | SWP_NOZORDER)
}

// To set the size of the control or form
control_set_size :: proc(ctl : ^Control, width, height : int)
{
	mw : int = ctl.width if width == 0 else width
	mh : int = ctl.height if height == 0 else height
	SetWindowPos(ctl.handle, nil, 0, 0, i32(mw), i32(mh),SWP_NOMOVE | SWP_NOZORDER)
}

// To set the text of the control or form.
// Note :- This is not applicable for all controls.
control_set_text :: proc(ctl : ^Control, txt : string)
{
	ctl.text = txt
	if ctl._isCreated {
		// #partial switch ctl.kind {
		// 	case .Label : // Label need special care only because of the autosize property
		// 		lb := cast(^Label) ctl
		// 		if lb.autoSize do calculate_ctl_size(lb)
		// 	case .Check_Box :
		// 		cb := cast(^CheckBox) ctl
		// 		if cb.autoSize do calculate_ctl_size(cb)
		// 	case .Radio_Button :
		// 		rb := cast(^RadioButton) ctl
		// 		if rb.autoSize do calculate_ctl_size(rb)
		// }
		SetWindowText(ctl.handle, to_wstring(txt))
	}
}

// To get the text from the control or form.
// Note :- This is not applicable for all controls.
// IMPORTANT := delete the string after use
control_get_text :: proc(ctl : Control, alloc := context.allocator) -> string
{
	tlen := GetWindowTextLength(ctl.handle)
	mem_chunks := make([]WCHAR, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	//defer delete(mem_chunks)
	GetWindowText(ctl.handle, wsBuffer, i32(len(mem_chunks)))
	return wstring_to_utf8(wsBuffer, -1)
}

// To get the text from a control or form as a wstring.
// Note :- This is not applicable for all controls.
control_get_text_wstr :: proc(ctl : Control, alloc := context.allocator) -> []u16
{
	tlen := GetWindowTextLength(ctl.handle)
	mem_chunks := make([]WCHAR, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	//defer delete(mem_chunks)
	GetWindowText(ctl.handle, wsBuffer, i32(len(mem_chunks)))
	return wsBuffer[:tlen]
}

@private set_back_color1 :: proc(ctl : ^Control, clr : uint)
{
	// print("not implemented")
	#partial switch ctl.kind {
		case .Button:
			btn := cast(^Button) ctl
			btn_backcolor_control(btn, clr)
		case .Tree_View :
			treeview_set_back_color(ctl, clr)

		case : // For all other controls
			ctl.clrChanged = true
			ctl.backColor = clr
			redraw(ctl)
			//if ctl._isCreated do InvalidateRect(ctl.handle, nil, true)
	}
}

@private set_back_color2 :: proc(ctl : ^Control, clr : Color)
{
	uclr := rgb_to_uint(clr)
	#partial switch ctl.kind {
		case .Button:
			btn := cast(^Button) ctl
			btn_backcolor_control(btn, uclr)
	}
}

// To set the back color of a control or form.
// Note :- This is not applicable for all controls.
control_set_backcolor :: proc{set_back_color1, set_back_color2}
//-------------------------------------------------------------

@private set_fore_color1 :: proc(ctl : ^Control, clr : uint)
{
	#partial switch ctl.kind
	{
		case .Button :
			btn := cast(^Button) ctl
			btn_forecolor_control(btn, clr)
		case .Tree_View :
			//tv := cast(^Tree_View) ctl
			ctl.backColor = clr
			if ctl._isCreated
			{
				cref := get_color_ref(clr)
				SendMessage(ctl.handle, TVM_SETTEXTCOLOR, 0, direct_cast(cref, LPARAM))
			}

		case : // for all other controls
			ctl.foreColor = clr
			if ctl._isCreated do InvalidateRect(ctl.handle, nil, false)
	}
}

@private set_fore_color2 :: proc(ctl : ^Control, clr : Color)
{
	uclr := rgb_to_uint(clr)
	#partial switch ctl.kind {
		case .Button :
			btn := cast(^Button) ctl
			btn_forecolor_control(btn, uclr)
	}
}

// To set the fore color of a control or form.
// Note :- This is not applicable for all controls.
control_set_forecolor :: proc{set_fore_color1, set_fore_color2}
//--------------------------------------------------------------

// Writen to set a control's focus, but it seems not working.
control_Setfocus :: proc(ctl : ^Control)
{
	// This is not working as i intented. This will erase the text box's back color.
	// I don't know how to fix this.
	//curr_hw := GetFocus()
	SetFocus(ctl.handle)
	//SendMessage(hw, WM_UPDATEUISTATE, WPARAM(0x10002), 0)
	//SendMessage(ctl.handle, WM_SETFOCUS, direct_cast(0, WPARAM), 0)
	// mdw := WPARAM(make_dword(2, 0x1))
    // SendMessage(ctl.handle, WM_UPDATEUISTATE, mdw, 0)
	//  mdw := WPARAM(make_dword(1, 0x4 | 0x1))
    //          SendMessage(ctl.handle, WM_CHANGEUISTATE, mdw, 0)
    //         ptf("low word - %d, hi word - %d\n", loword_wparam(mdw), hiword_wparam(mdw))

}

// set_focus :: proc(hwnd : HWND) {SetFocus(hwnd)}

// Common control message handlers

// Left Mouse down, up, click
	ctrl_left_mousedown_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		ctl._mDownHappened = true
		if ctl.onMouseDown != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onMouseDown(ctl, &mea)
		}
	}

	ctrl_left_mouseup_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl._mDownHappened {
			ctl._mDownHappened = false
			PostMessage(ctl.handle, CM_LMOUSECLICK, 0, 0)
		}
		if ctl.onMouseUp != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onMouseUp(ctl, &mea)
		}
	}

	ctrl_left_mouseclick_handler :: proc(ctl: ^Control)
	{
		if ctl.onMouseClick != nil {
			ea := new_event_args()
			ctl.onMouseClick(ctl, &ea)
		}
	}
// End section

// Right mouse down, up, click
	ctrl_right_mousedown_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		ctl._mDownHappened = true
		if ctl.onRightMouseDown != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onRightMouseDown(ctl, &mea)
		}
	}

	ctrl_right_mouseup_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl._mDownHappened {
			ctl._mDownHappened = false
			PostMessage(ctl.handle, CM_RMOUSECLICK, 0, 0)
		}
		if ctl.onRightMouseUp != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onRightMouseUp(ctl, &mea)
		}
	}

	ctrl_right_mouseclick_handler :: proc(ctl: ^Control)
	{
		if ctl.onRightClick != nil {
			ea := new_event_args()
			ctl.onRightClick(ctl, &ea)
		}
	}
// End section

// Mouse wheel, enter, move, leave
	ctrl_mousewheel_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl.onMouseScroll != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onMouseScroll(ctl, &mea)
		}
	}

	ctrl_mousemove_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl._isMouseEntered {
			if ctl.onMouseMove != nil {
				mea := new_mouse_event_args(msg, wpm, lpm)
				ctl.onMouseMove(ctl, &mea)
			}
		}
		else {
			ctl._isMouseEntered = true
			if ctl.onMouseEnter != nil  {
				ea := new_event_args()
				ctl.onMouseEnter(ctl, &ea)
			}
		}
	}

	ctrl_mouseleave_handler :: proc(ctl: ^Control)
	{
		ctl._isMouseEntered = false
		if ctl.onMouseLeave != nil {
			ea := new_event_args()
			ctl.onMouseLeave(ctl, &ea)
		}
	}

ctrl_setfocus_handler :: proc(ctl: ^Control)
{
	if ctl.onGotFocus != nil {
		ea := new_event_args()
		ctl.onGotFocus(ctl, &ea)
	}
}

ctrl_killfocus_handler :: proc(ctl: ^Control)
{
	if ctl.onLostFocus != nil {
		ea := new_event_args()
		ctl.onLostFocus(ctl, &ea)
	}
}

// ctrl_destructor :: proc(ctl: ^Control, ctx: runtime.Context) {
// 	context = ctx
// 	// free(ctl.font)
// 	print("font freed in control ", ctx.user_index)
// }

// End section

