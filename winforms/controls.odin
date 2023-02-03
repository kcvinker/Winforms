
package winforms

import "core:runtime"

_global_subclass_id : int = 2001
_global_ctl_id : Uint = 100


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
	handle : Hwnd,
	control_id : Uint,
	parent : ^Form,
	text : string,
	width, height : int,
    xpos, ypos : int,
    font : Font,
	back_color : uint,
	fore_color : uint,
	enabled : bool,
	visible : bool,

    _style, _ex_style : Dword,
	_is_created : b64,
	_is_mouse_tracking, _is_mouse_entered : bool,
	_mdown_happened, _mrdown_happened : bool,
	_size_incr : SizeIncrement,
	_cls_name : wstring,
	_before_creation, _after_creation : CreateDelegate,
	_draw_flag: uint,


	clr_changed : bool,

	paint : PaintEventHandler,
	got_focus,
	lost_focus ,
	mouse_enter,
	mouse_click,
	right_click,
	double_click,
	mouse_leave,
	size_changing,
	size_changed : EventHandler,

    left_mouse_down,
    right_mouse_down,
    left_mouse_up,
    right_mouse_up,
    mouse_scroll,
    mouse_move,
	mouse_hover : MouseEventHandler,

    key_up,
	key_down,
	key_press : KeyEventHandler,
	on_destroy : EventHandler,
}

@private
control_cast :: proc($T : typeid, refd : DwordPtr) -> ^T { return cast(^T) (cast(uintptr) refd) }

@private
set_subclass :: proc(ctl : ^Control, fn_ptr : SUBCLASSPROC ) {
	SetWindowSubclass(ctl.handle, fn_ptr, UintPtr(_global_subclass_id), to_dwptr(ctl) )
	_global_subclass_id += 1
}




// This is used to set the defualt font right creating the control handle.
@private
setfont_internal :: proc(ctl : ^Control) {
	isOkay : bool
	if ctl.font.handle != ctl.parent.font.handle do isOkay = true
	if ctl.font._def_font_changed do isOkay = true
	if isOkay {
		CreateFont_handle(&ctl.font, ctl.handle)
		SendMessage(ctl.handle, WM_SETFONT, Wparam(ctl.font.handle), Lparam(1))
	}
}

redraw :: proc{redraw_ctl1, redraw_ctl2}
@private
redraw_ctl1 :: proc(ctl : ^Control) { if ctl._is_created do InvalidateRect(ctl.handle, nil, false) }
@private
redraw_ctl2:: proc(ctl : Control) { if ctl._is_created do InvalidateRect(ctl.handle, nil, false) }

// Enable or disable a control or form.
control_enable :: proc(ctl : ^Control, bstate : bool) {
	ctl.enabled = bstate
	#partial switch ctl.kind {
		case .Number_Picker :
			SendMessage(ctl.handle, WM_ENABLE, Wparam(bstate), 0)
		case :
			EnableWindow(ctl.handle, bstate)
	}
}

// Hide or show a control.
control_visibile :: proc(ctl : ^Control, bstate : bool) {
	ctl.enabled = bstate
	flag : i32 = SW_HIDE if !bstate else SW_SHOW
	#partial switch ctl.kind {
		case .Number_Picker :
			np := direct_cast(ctl, ^NumberPicker)
			ShowWindow(np.handle, flag)
			ShowWindow(np._buddy_handle, flag)
		case :
			ShowWindow(ctl.handle, flag)
	}
}


// To set a user defined font before or after creating the control handle
control_set_font :: proc(ctl : ^Control, fn : string, fsz : int, fw : FontWeight = .Normal, fi : bool = false, fu : bool = false) {
	using ctl.font
	name = fn
	size = fsz
	weight = fw
	italics = fi
	underline = fu
	_def_font_changed = true
	if ctl.handle != nil { // Only set the font if control handle is created.
		CreateFont_handle(&ctl.font, ctl.handle)
		SendMessage(ctl.handle, WM_SETFONT, Wparam(ctl.font.handle), Lparam(1))
		if ctl.kind == .Label { // Label need special care only because of the autosize property
			lb := cast(^Label) ctl
			if lb.auto_size do calculate_ctl_size(lb)
		}
	}
}

control_set_font_name :: proc(ctl : ^Control, fn : string) {
	ctl.font._def_font_changed = true
	ctl.font.name = fn
	if ctl._is_created do control_set_font(ctl, fn, ctl.font.size)
}

 control_set_font_size :: proc(ctl : ^Control, fsz : int, ) {
	ctl.font._def_font_changed = true
	ctl.font.size = fsz
	if ctl._is_created do control_set_font(ctl, ctl.font.name, fsz)
}


// To set the position of a control or form
control_set_position :: proc(ctl : ^Control, x, y : int) {
	mx : int = ctl.xpos if x == 0 else x
	my : int = ctl.ypos if y == 0 else y
	SetWindowPos(ctl.handle, nil, i32(mx), i32(my), 0, 0, SWP_NOSIZE | SWP_NOZORDER)
}

// To set the size of the control or form
control_set_size :: proc(ctl : ^Control, width, height : int) {
	mw : int = ctl.width if width == 0 else width
	mh : int = ctl.height if height == 0 else height
	SetWindowPos(ctl.handle, nil, 0, 0, i32(mw), i32(mh),SWP_NOMOVE | SWP_NOZORDER)
}

// To set the text of the control or form.
// Note :- This is not applicable for all controls.
control_set_text :: proc(ctl : ^Control, txt : string) {
	ctl.text = txt
	if ctl._is_created {
		#partial switch ctl.kind {
			case .Label : // Label need special care only because of the autosize property
				lb := cast(^Label) ctl
				if lb.auto_size do calculate_ctl_size(lb)
			case .Check_Box :
				cb := cast(^CheckBox) ctl
				if cb.auto_size do calculate_ctl_size(cb)
			case .Radio_Button :
				rb := cast(^RadioButton) ctl
				if rb.auto_size do calculate_ctl_size(rb)
		}
		SetWindowText(ctl.handle, to_wstring(txt))
	}
}


// To get the text from the control or form.
// Note :- This is not applicable for all controls.
// IMPORTANT := delete the string after use
control_get_text :: proc(ctl : Control, alloc := context.allocator) -> string {
	tlen := GetWindowTextLength(ctl.handle)
	mem_chunks := make([]Wchar, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	//defer delete(mem_chunks)
	GetWindowText(ctl.handle, wsBuffer, i32(len(mem_chunks)))
	return wstring_to_utf8(wsBuffer, -1)
}

// To get the text from a control or form as a wstring.
// Note :- This is not applicable for all controls.
control_get_text_wstr :: proc(ctl : Control, alloc := context.allocator) -> []u16 {
	tlen := GetWindowTextLength(ctl.handle)
	mem_chunks := make([]Wchar, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	//defer delete(mem_chunks)
	GetWindowText(ctl.handle, wsBuffer, i32(len(mem_chunks)))
	return wsBuffer[:tlen]
}




@private
set_back_color1 :: proc(ctl : ^Control, clr : uint) {
	//print("not implemented")
	#partial switch ctl.kind {
		case .Button:
			btn := cast(^Button) ctl
			btn_backcolor_control(btn, clr)
		case .Tree_View :
			treeview_set_back_color(ctl, clr)

		case : // For all other controls
			ctl.clr_changed = true
			ctl.back_color = clr
			redraw(ctl)
			//if ctl._is_created do InvalidateRect(ctl.handle, nil, true)
	}
}

@private
set_back_color2 :: proc(ctl : ^Control, clr : Color) {
	uclr := rgb_to_uint(clr)
	#partial switch ctl.kind {
		case .Button:
			btn := cast(^Button) ctl
			// btn_backcolor_control(btn, uclr)
	}
}

// To set the back color of a control or form.
// Note :- This is not applicable for all controls.
control_set_back_color :: proc{set_back_color1, set_back_color2}
//-------------------------------------------------------------

@private
set_fore_color1 :: proc(ctl : ^Control, clr : uint) {
	#partial switch ctl.kind {
		case .Button :
			btn := cast(^Button) ctl
			btn_forecolor_control(btn, clr)
		case .Tree_View :
			//tv := cast(^Tree_View) ctl
			ctl.back_color = clr
			if ctl._is_created {
				cref := get_color_ref(clr)
				SendMessage(ctl.handle, TVM_SETTEXTCOLOR, 0, direct_cast(cref, Lparam))
			}

		case : // for all other controls
			ctl.fore_color = clr
			if ctl._is_created do InvalidateRect(ctl.handle, nil, false)
	}
}

@private
set_fore_color2 :: proc(ctl : ^Control, clr : Color) {
	uclr := rgb_to_uint(clr)
	#partial switch ctl.kind {
		case .Button :
			btn := cast(^Button) ctl
			// set_button_forecolor(btn, uclr)
	}
}

// To set the fore color of a control or form.
// Note :- This is not applicable for all controls.
control_set_fore_color :: proc{set_fore_color1, set_fore_color2}
//--------------------------------------------------------------

// Writen to set a control's focus, but it seems not working.
control_SetFocus :: proc(ctl : Control) {
	// This is not working as i intented. This will erase the text box's back color.
	// I don't know how to fix this.
	//curr_hw := GetFocus()
	SetFocus(ctl.handle)
	//SendMessage(hw, WM_UPDATEUISTATE, Wparam(0x10002), 0)
	//SendMessage(ctl.handle, WM_SETFOCUS, direct_cast(0, Wparam), 0)
	// mdw := Wparam(make_dword(2, 0x1))
    // SendMessage(ctl.handle, WM_UPDATEUISTATE, mdw, 0)
	//  mdw := Wparam(make_dword(1, 0x4 | 0x1))
    //          SendMessage(ctl.handle, WM_CHANGEUISTATE, mdw, 0)
    //         ptf("low word - %d, hi word - %d\n", loword_wparam(mdw), hiword_wparam(mdw))

}

set_focus :: proc(hwnd : Hwnd) {SetFocus(hwnd)}


// Common control message handlers

// Left Mouse down, up, click
	ctrl_left_mousedown_handler :: proc(ctl: ^Control, msg: Uint, wpm: Wparam, lpm: Lparam) {
		ctl._mdown_happened = true
		if ctl.left_mouse_down != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.left_mouse_down(ctl, &mea)
		}
	}

	ctrl_left_mouseup_handler :: proc(ctl: ^Control, msg: Uint, wpm: Wparam, lpm: Lparam) {
		if ctl._mdown_happened {
			ctl._mdown_happened = false
			PostMessage(ctl.handle, CM_LMOUSECLICK, 0, 0)
		}
		if ctl.left_mouse_up != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.left_mouse_up(ctl, &mea)
		}
	}

	ctrl_left_mouseclick_handler :: proc(ctl: ^Control) {
		if ctl.mouse_click != nil {
			ea := new_event_args()
			ctl.mouse_click(ctl, &ea)
		}
	}
// End section

// Right mouse down, up, click
	ctrl_right_mousedown_handler :: proc(ctl: ^Control, msg: Uint, wpm: Wparam, lpm: Lparam) {
		ctl._mdown_happened = true
		if ctl.right_mouse_down != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.right_mouse_down(ctl, &mea)
		}
	}

	ctrl_right_mouseup_handler :: proc(ctl: ^Control, msg: Uint, wpm: Wparam, lpm: Lparam) {
		if ctl._mdown_happened {
			ctl._mdown_happened = false
			PostMessage(ctl.handle, CM_RMOUSECLICK, 0, 0)
		}
		if ctl.right_mouse_up != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.right_mouse_up(ctl, &mea)
		}
	}

	ctrl_right_mouseclick_handler :: proc(ctl: ^Control) {
		if ctl.right_click != nil {
			ea := new_event_args()
			ctl.right_click(ctl, &ea)
		}
	}
// End section

// Mouse wheel, enter, move, leave
	ctrl_mousewheel_handler :: proc(ctl: ^Control, msg: Uint, wpm: Wparam, lpm: Lparam) {
		if ctl.mouse_scroll != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.mouse_scroll(ctl, &mea)
		}
	}

	ctrl_mousemove_handler :: proc(ctl: ^Control, msg: Uint, wpm: Wparam, lpm: Lparam) {
		if ctl._is_mouse_entered {
			if ctl.mouse_move != nil {
				mea := new_mouse_event_args(msg, wpm, lpm)
				ctl.mouse_move(ctl, &mea)
			}
		}
		else {
			ctl._is_mouse_entered = true
			if ctl.mouse_enter != nil  {
				ea := new_event_args()
				ctl.mouse_enter(ctl, &ea)
			}
		}
	}

	ctrl_mouseleave_handler :: proc(ctl: ^Control) {
		ctl._is_mouse_entered = false
		if ctl.mouse_leave != nil {
			ea := new_event_args()
			ctl.mouse_leave(ctl, &ea)
		}
	}

ctrl_setfocus_handler :: proc(ctl: ^Control) {
	if ctl.got_focus != nil {
		ea := new_event_args()
		ctl.got_focus(ctl, &ea)
	}
}

ctrl_killfocus_handler :: proc(ctl: ^Control) {
	if ctl.lost_focus != nil {
		ea := new_event_args()
		ctl.lost_focus(ctl, &ea)
	}
}


// End section









