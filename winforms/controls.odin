
package winforms

_global_subclass_id : int = 2001
_global_ctl_id : Uint = 100


ControlKind :: enum {
	form, 
	button, 
	calendar,		
	check_box, 
	combo_box,
	date_time_picker, 
	group_box, 
	label, 
	list_box,
	list_view,
	number_picker,
	panel, 
	progress_bar,
	radio_button, 
	text_box, 
	tree_view,
	
}

// A base class for all controls & Form.
Control :: struct {
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
	_is_created : bool,
	_is_mouse_tracking, _is_mouse_entered : bool,
	_mdown_happened, _mrdown_happened : bool,
	_subclass_id : int,
	_wndproc_ptr : SUBCLASSPROC,
	_size_incr : SizeIncrement,
	
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
}

@private control_cast :: proc($T : typeid, refd : DwordPtr) -> ^T { return cast(^T) (cast(uintptr) refd) }

@private set_subclass :: proc(ctl : ^Control, fn_ptr : SUBCLASSPROC ) {
	SetWindowSubclass(ctl.handle, fn_ptr, UintPtr(_global_subclass_id), to_dwptr(ctl) )
	ctl._subclass_id = _global_subclass_id
	ctl._wndproc_ptr = fn_ptr
	_global_subclass_id += 1
}



@private remove_subclass :: proc(ctl : ^Control) { // This will get called when control's wndproc receive wm_destroy message.
	RemoveWindowSubclass(ctl.handle, ctl._wndproc_ptr, UintPtr(ctl._subclass_id) )
	//ptf("Removed control - %s\n", ctl.kind)
}

// This is used to set the defualt font right creating the control handle.
@private setfont_internal :: proc(ctl : ^Control) {
	if ctl.font.handle != ctl.parent.font.handle do CreateFont_handle(&ctl.font, ctl.handle)
	SendMessage(ctl.handle, WM_SETFONT, Wparam(ctl.font.handle), Lparam(1))
}

// Enable or disable a control or form.
control_enable :: proc(ctl : ^Control, bstate : bool) {
	ctl.enabled = bstate
	#partial switch ctl.kind {
		case .number_picker :			
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
		case .number_picker :			
			np := direct_cast(ctl, ^NumberPicker)		
			ShowWindow(np.handle, flag)	
			ShowWindow(np._buddy_handle, flag)
		case :
			ShowWindow(ctl.handle, flag)
	} 
}


// To set a user defined font before or after creating the control handle
control_set_font :: proc(ctl : ^Control, fn : string, fsz : int, fb : bool = false, fi : bool = false, fu : bool = false) {
	using ctl.font
	name = fn
	size = fsz
	bold = fb
	italics = fi
	underline = fu
	_def_font_changed = true	
	if ctl.handle != nil { // Only set the font if control handle is created.
		CreateFont_handle(&ctl.font, ctl.handle) 
		SendMessage(ctl.handle, WM_SETFONT, Wparam(ctl.font.handle), Lparam(1))
		if ctl.kind == .label { // Label need special care only because of the autosize property
			lb := cast(^Label) ctl
			if lb.auto_size do calculate_ctl_size(lb)
		}		
	}
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
			case .label : // Label need special care only because of the autosize property
				lb := cast(^Label) ctl
				if lb.auto_size do calculate_ctl_size(lb)
			case .check_box :
				cb := cast(^CheckBox) ctl
				if cb.auto_size do calculate_ctl_size(cb)
			case .radio_button :
				rb := cast(^RadioButton) ctl
				if rb.auto_size do calculate_ctl_size(rb)
		}
		SetWindowText(ctl.handle, to_wstring(txt))
	}
}
		 

// To get the text from the control or form. 
// Note :- This is not applicable for all controls.
control_get_text :: proc(ctl : Control, alloc := context.allocator) -> string {	 
	tlen := GetWindowTextLength(ctl.handle) 	
	mem_chunks := make([]Wchar, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	defer delete(mem_chunks)	
	GetWindowText(ctl.handle, wsBuffer, i32(len(mem_chunks)))
	return wstring_to_utf8(wsBuffer, -1)	
}

// To get the text from a control or form as a wstring.
// Note :- This is not applicable for all controls.
control_get_text_wstr :: proc(ctl : Control, alloc := context.allocator) -> []u16 {	 
	tlen := GetWindowTextLength(ctl.handle) 	
	mem_chunks := make([]Wchar, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
	defer delete(mem_chunks)	
	GetWindowText(ctl.handle, wsBuffer, i32(len(mem_chunks)))	
	return wsBuffer[:tlen]	
}


@private set_back_color1 :: proc(ctl : ^Control, clr : uint) {
	//print("not implemented")
	#partial switch ctl.kind {
		case .button:
			btn := cast(^Button) ctl
			set_button_backcolor(btn, clr)		

		case : // For all other controls
			ctl.clr_changed = true
			ctl.back_color = clr
			if ctl._is_created do InvalidateRect(ctl.handle, nil, true)
	}
}

@private set_back_color2 :: proc(ctl : ^Control, clr : RgbColor) {
	uclr := rgb_to_uint(clr)
	#partial switch ctl.kind {
		case .button:
			btn := cast(^Button) ctl
			set_button_backcolor(btn, uclr)
	}
}

// To set the back color of a control or form.
// Note :- This is not applicable for all controls.
control_set_back_color :: proc{set_back_color1, set_back_color2}
//-------------------------------------------------------------

@private set_fore_color1 :: proc(ctl : ^Control, clr : uint) {
	#partial switch ctl.kind {
		case .button :
			btn := cast(^Button) ctl
			set_button_forecolor(btn, clr)
		

		case : // for all other controls
			ctl.fore_color = clr
			if ctl._is_created do InvalidateRect(ctl.handle, nil, true)
			
	}
}

@private set_fore_color2 :: proc(ctl : ^Control, clr : RgbColor) {
	uclr := rgb_to_uint(clr)
	#partial switch ctl.kind {
		case .button :
			btn := cast(^Button) ctl
			set_button_forecolor(btn, uclr)
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




