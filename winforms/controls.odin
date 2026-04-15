/*
	Major Update on 3rd week of 2023 October.
*/

/*===========================================Control Docs=========================================================
    Control struct
        Constructor: No constructor available. It's an abstract type.
        Properties:
            kind 		: ControlKind - An enum in this file.
			name 		: string
			handle 		: HWND
			controlID 	: UINT
			parent 		: ^Form
			text 		: string
			width		: int
			height 		: int
			xpos		: int
			ypos 		: int
			font 		: Font
			backColor 	: uint
			foreColor 	: uint
			enabled 	: bool
			visible 	: bool
			contextMenu : ^ContextMenu [See contextmenu.odin]
        Functions:
			control_enable	
			cright
			cbottom
			control_visibile
			control_setdisable
			control_set_forecolor
			control_set_font
			control_set_font_name
			control_set_font_size
			control_set_position
			control_set_size
			control_set_text
			control_get_text
			control_set_backcolor
			control_set_forecolor
			control_Setfocus
        Events:
			PaintEventHandler type - proc(^Control, ^PaintEventArgs) [See events.odin]
				onPaint
            EventHandler type - proc(^Control, ^EventArgs) [See events.odin]
                onGotFocus
				onLostFocus 
				onMouseEnter
				onClick
				onRightClick
				onDoubleClick
				onMouseLeave
				onSizeChanging
				onSizeChanged
				onDestroy
			MouseEventHandler type - proc(^Control, ^MouseEventArgs) [See events.odin]
				onMouseDown
				onRightMouseDown
				onMouseUp
				onRightMouseUp
				onMouseScroll
				onMouseMove
				onMouseHover
			KeyEventHandler type - proc(^Control, ^KeyEventArgs) [See events.odin]
				onKeyUp
				onKeyDown
				onKeyPress
==============================================================================================================*/



package winforms

import "base:runtime"
import api "core:sys/windows"
import "core:reflect"

globalSubClassID : int = 2001
globalCtlID : UINT= 100
MOUSE_ENTER_EVENT      :: 1 << 0
MOUSE_HOVER_EVENT      :: 1 << 1
MOUSE_LEAVE_EVENT      :: 1 << 2


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
	contextMenu : ^ContextMenu,

    _style, _exStyle : DWORD,
	_isMouseTracking: BOOL,
	_isCreated : b64,
	_isMouseEntered : bool,
	_isPressed: bool,
	_mDownHappened, _mRDownHappened : bool,
	_SizeIncr : SizeIncrement,
	_clsName : wstring,
	_drawFlag: uint,
	_cachedWidth, _cachedHeight : i32,
	_fp_beforeCreation, _fp_afterCreation : CreateDelegate,
	_fp_size_fix : ControlDelegate,
	_inherit_color: bool,
	_textable: bool,
	_cmenuUsed: bool,
	_hasFont: bool,
	_wtext : ^WideString,
	_fcref : COLORREF,
	_myRect : RECT,
	_mouseEvents: bit_set[SpecialMouseEvents; u8],
	_tmeFlags: DWORD,

	clrChanged : bool,

	// Events
	onPaint : PaintEventHandler,
	onGotFocus,
	onLostFocus ,
	onMouseEnter,
	onMouseHover,
	onClick,
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
    onMouseMove : MouseEventHandler,

    onKeyUp,
	onKeyDown,
	onKeyPress : KeyEventHandler,
	onDestroy : EventHandler,
}





// Create a Control. Use this for all controls.
create_control :: proc(c : ^Control)
{
	if c.handle != nil do return
	// If it's a Combobox, it knows how to manage contril ID.
	if c.kind != ControlKind.Combo_Box {
		globalCtlID += 1
    	c.controlID = globalCtlID
	}

	if c._fp_beforeCreation != nil do c._fp_beforeCreation(c)

	width : i32 = 0
	height : i32 = 0
	c._tmeFlags = 0 
	if c.kind != ControlKind.Number_Picker {
		// NumberPicker needs zero width & height. It can find it's size later.
		width = i32(c.width)
		height = i32(c.height)
	}
	ctrl_txt_ptr : WCPTR = c.text == "" ? nil: to_wstring(c.text)

    c.handle = CreateWindowEx(  c._exStyle,
								c._clsName,
								ctrl_txt_ptr,
								c._style,
								i32(c.xpos),
								i32(c.ypos),
								width,
								height,
								c.parent.handle,
								dir_cast(c.controlID, HMENU),
								app.hInstance,
								nil )
	// ptf("Creation res %d\n", GetLastError())

    if c.handle != nil {
        c._isCreated = true
        if c._hasFont do setfont_internal(c)
		if c._fp_afterCreation != nil do c._fp_afterCreation(c)
		GetClientRect(c.handle, &c._myRect)	
		// if c._mouseEnterProc == nil do common_mouse_enter_handler
		// if c._mouseLeaveProc == nil do c._mouseLeaveProc = common_mouse_leave_handler
	}
	else {
		print("Failed to create control")
		// context = runtime.default_context()
    }

}



common_mouse_leave_handler :: proc(this: ^Control)
{
	this._isMouseEntered = false
	alert2("Common Mouse leave message from %s", this.kind)
}

control_setpos :: #force_inline proc(this: ^Control, flag: UINT) {
    SetWindowPos(this.handle, nil, this.xpos, this.ypos, this.width, this.height, flag)
}

control_setpos2 :: #force_inline proc(hw: HWND, x, y, w, h: int, flag: UINT) {
	SetWindowPos(hw, nil, x, y, w, h, flag)
}

@private ctl_send_msg :: #force_inline proc(hw: HWND, msg: UINT, wp: $T, lp: $U) -> LRESULT
{
	return SendMessage(hw, msg, WPARAM(wp), LPARAM(lp))
}

control_clone_parent_font :: proc(this: ^Control) {
	this.font.name = this.parent.font.name
    this.font.size = this.parent.font.size
    this.font.weight = this.parent.font.weight
    this.font.italics = this.parent.font.italics
    this.font.underline = this.parent.font.underline  
    font_clone_parent_handle(&this.font, nil)
}

// Enable or disable a control or form.
control_enable :: proc(ctl : ^Control, bstate : bool)
{
	ctl.enabled = bstate
	#partial switch ctl.kind {
		case .Number_Picker :
			SendMessage(ctl.handle, WM_ENABLE, WPARAM(bstate), 0)
		case :
			api.EnableWindow(ctl.handle, auto_cast(bstate))
	}
}

// Get the right point of control
cright :: proc(this: ^Control) -> int
{
	return int(map_parent_points(this).right)
}

// Get the bottom point of control
cbottom :: proc(this: ^Control) -> int
{
	return int(map_parent_points(this).bottom)
}

// Hide or show a control.
control_visibile :: proc(ctl : ^Control, bstate : bool)
{
	ctl.enabled = bstate
	flag : i32 = SW_HIDE if !bstate else SW_SHOW
	#partial switch ctl.kind {
		case .Number_Picker :
			np := dir_cast(ctl, ^NumberPicker)
			ShowWindow(np.handle, flag)
			ShowWindow(np._buddyHandle, flag)
		case :
			ShowWindow(ctl.handle, flag)
	}
}

// Enable or disable control
control_setdisable :: proc(this: ^Control, value: b8)
{
	if this._isCreated do api.EnableWindow(this.handle, !value)
}


// To set a user defined font before or after creating the control handle
control_set_font :: proc(ctl : ^Control, fn : string, fsz : int,
							fw : FontWeight = .Normal, fi : bool = false, fu : bool = false)
{
	if ctl._hasFont == false do return
	using ctl.font
	name = fn
	size = fsz
	weight = fw
	italics = fi
	underline = fu
	_defFontChanged = true
	font_create_handle(&ctl.font)
	if ctl.handle != nil do ctl_send_msg(ctl.handle, WM_SETFONT, ctl.font.handle, 1)
	if ctl._fp_size_fix != nil do ctl._fp_size_fix(ctl)
}

// Set control's font name
control_set_font_name :: proc(ctl : ^Control, fn : string)
{
	if ctl._hasFont == false do return
	ctl.font._defFontChanged = true
	ctl.font.name = fn
	if ctl._isCreated do control_set_font(ctl, fn, ctl.font.size)
}

// Set control's font size
 control_set_font_size :: proc(ctl : ^Control, fsz : int, )
{
	if ctl._hasFont == false do return
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

// To set the text of the control or form. Note :- This is not applicable for all controls.
control_set_text :: proc(ctl : ^Control, txt : string)
{
	if ctl._textable {
		ctl.text = txt
		if ctl._isCreated {
			SetWindowText(ctl.handle, to_wstring(txt))
		}
	}
}

// To get the text from the control or form.
// Note :- This is not applicable for all controls.
// IMPORTANT := delete the string after use
control_get_text :: proc(ctl : Control, alloc := context.allocator) -> string
{
	tlen := GetWindowTextLength(ctl.handle)
	wsBuffer := make([]WCHAR, tlen + 1, alloc)
	GetWindowText(ctl.handle, &wsBuffer[0], i32(len(wsBuffer)))
	return utf16_to_utf8(wsBuffer, alloc)
}

// To set the back color of a control or form. Note :- This is not applicable for all controls.
control_set_backcolor :: proc{set_back_color1, set_back_color2}

// To set the fore color of a control or form. Note :- This is not applicable for all controls.
control_set_forecolor :: proc{set_fore_color1, set_fore_color2}

// To set a control's focus, but it seems not working.
control_Setfocus :: proc(ctl : ^Control)
{
	// This is not working as i intented. This will erase the text box's back color.
	// I don't know how to fix this.
	// TODO: Fix the focus issue. Maybe we can set focus to a control's child to avoid the back color issue.
	SetFocus(ctl.handle)
}

//=================================================================Private Functions==========================
@private control_cast :: proc($T : typeid, refd : DWORD_PTR) -> ^T
{
	return cast(^T) (cast(UINT_PTR) refd)
}

@private set_subclass :: proc(ctl : ^Control, fn_ptr : SUBCLASSPROC )
{
	api.SetWindowSubclass(ctl.handle, fn_ptr, UINT_PTR(globalSubClassID), to_dwptr(ctl) )
	globalSubClassID += 1
}

// This is used to set the defualt font right creating the control handle.
@private setfont_internal :: proc(ctl : ^Control)
{
	if ctl._hasFont == false do return
	if ctl.font.handle == nil do font_create_handle(&ctl.font)
	SendMessage(ctl.handle, WM_SETFONT, WPARAM(ctl.font.handle), LPARAM(1))

}

@private redraw :: proc{redraw_ctl1, redraw_ctl2}
@private redraw_ctl1 :: proc(ctl : ^Control) { if ctl._isCreated do InvalidateRect(ctl.handle, nil, false) }
@private redraw_ctl2:: proc(ctl : Control) { if ctl._isCreated do InvalidateRect(ctl.handle, nil, false) }


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


// To get the text from a control or form as a wstring.
// Note :- This is not applicable for all controls. [[[Caller must free the buffer]]]
control_get_text_wstr :: proc(ctl : Control, alloc := context.allocator) -> []u16
{
	tlen := GetWindowTextLength(ctl.handle)
	mem_chunks := make([]WCHAR, tlen + 1, alloc)
	wsBuffer : wstring = &mem_chunks[0]
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

		case .Group_Box:
			gb:= cast(^GroupBox) ctl 
			gbx_set_backcolor(gb, clr)

		case .Track_Bar:
			tkb := cast(^TrackBar) ctl
			trackbar_backcolor_setter(tkb, clr)

		case .Tree_View :
			treeview_set_back_color(ctl, clr)

		case : // For all other controls
			ctl.clrChanged = true
			ctl.backColor = clr
			if (ctl._drawFlag & 2) != 2 do ctl._drawFlag += 2
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
				SendMessage(ctl.handle, TVM_SETTEXTCOLOR, 0, dir_cast(cref, LPARAM))
			}

		case : // for all other controls
			ctl.foreColor = clr
			if (ctl._drawFlag & 1) != 1 do ctl._drawFlag += 1
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


//--------------------------------------------------------------





// set_focus :: proc(hwnd : HWND) {SetFocus(hwnd)}

// Common control message handlers
	@private ctrl_common_msg_handler :: proc(this: ^Control, hw: HWND, msg: UINT,wp: WPARAM, lp: LPARAM) -> MsgHandlerReturn
	{
		switch msg {
		case WM_LBUTTONDOWN:
			this._isPressed = true
			if this.onMouseDown != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				this.onMouseDown(this, &mea)
			}
			return .Call_Def_Proc

		case WM_RBUTTONDOWN:
			this._isPressed = true
			if this.onRightMouseDown != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				this.onRightMouseDown(this, &mea)
			}
			return .Call_Def_Proc

		case WM_LBUTTONUP:				
			if this.onMouseUp != nil	{
				mea := new_mouse_event_args(msg, wp, lp)
				this.onMouseUp(this, &mea)
			}

			if this._isPressed && this.onClick != nil {
				pt := POINT{cast(i32)(cast(i16)LOWORD(lp)), cast(i32)(cast(i16)HIWORD(lp))}		
				if PtInRect(&this._myRect, pt) do this->onClick(&gea)
			}
			this._isPressed = false;		
			return .Call_Def_Proc

		case WM_RBUTTONUP:
			if this.onRightMouseUp != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				this.onRightMouseUp(this, &mea)
			}
			if this._isPressed && this.onRightClick != nil {
				pt := POINT{cast(i32)(cast(i16)LOWORD(lp)), cast(i32)(cast(i16)HIWORD(lp))}		
				if PtInRect(&this._myRect, pt) do this->onRightClick(&gea)
			}
			this._isPressed = false;
			return .Call_Def_Proc

		case WM_MOUSEHWHEEL:
			if this.onMouseScroll != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				this.onMouseScroll(this, &mea)
			}
			return .Call_Def_Proc

		case WM_MOUSEMOVE: // Mouse Enter & Mouse Move is firing from here.
			
			// if this._spMMoveProc == nil {			
			// 	if this.onMouseMove != nil {
			// 		mea := new_mouse_event_args(msg, wp, lp)
			// 		this.onMouseMove(this, &mea)
			// 	}

			// 	// Determine if we need to start/restart tracking
			// 	needsLeave : bool = (this.onMouseEnter != nil || this.onMouseLeave != nil)
			// 	needsHover : bool = (this.onMouseHover != nil)
			// 	if (needsLeave || needsHover) {
			// 		// alert2("Needs Tracking: ", this._isMouseTracking)
			// 		if !this._isMouseTracking {
			// 			flags : DWORD = 0
			// 			if needsLeave do flags |= TME_LEAVE
			// 			if needsHover do flags |= TME_HOVER

			// 			// Start tracking
			// 			track_mouse_move(this.handle, flags)
			// 			this._isMouseTracking = true
			// 			if this.onMouseEnter != nil && !this._isMouseEntered {
			// 				this._isMouseEntered = true
			// 				this.onMouseEnter(this, &gea)
			// 			}
			// 		}
			// 	}
				
			// } else { 
			// 	this._spMMoveProc(this, hw, msg, wp, lp)
			// }	
			if this.kind == .Combo_Box {
				cmb_mouse_move_handler(cast(^ComboBox)this, hw, msg, wp, lp)
			} else if this.kind == .Number_Picker {
				nump_mouse_move_handler(cast(^NumberPicker)this, hw, msg, wp, lp)
			} else {
				ctrl_mousemove_handler(this, hw, msg, wp, lp)
			}
			return .Call_Def_Proc
			
			

		case WM_MOUSEHOVER:
			this._isMouseTracking = false
			if this.onMouseHover != nil do this.onMouseHover(this, &gea)
			return .Call_Def_Proc

		case WM_MOUSELEAVE:
			// // alert2("Mouse leave message received from %s", this.kind)
			// if this._spMLeaveProc == nil {
			// 	this._isMouseTracking = false
			// 	this._isMouseEntered = false
			// 	if this.onMouseLeave != nil do this.onMouseLeave(this, &gea)
			// 	return .Call_Def_Proc
			// } else {
			// 	return this._spMLeaveProc(this)
			// }
			if this.kind == .Combo_Box {
				cmb_mouse_leave_handler(cast(^ComboBox)this)
			} else if this.kind == .Number_Picker {
				nump_mouse_leave_handler(cast(^NumberPicker)this)
			} else {
				ctrl_mouseleave_handler(this)
			}
			return .Call_Def_Proc
		

		case WM_CONTEXTMENU:
			if this.contextMenu != nil do contextmenu_show(this.contextMenu, lp)
			return .Call_Def_Proc
		}
		return .Continue
	}
	
// Left Mouse down, up, click

	ctrl_left_mousedown_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl.onMouseDown != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onMouseDown(ctl, &mea)
		}
	}

	ctrl_left_mouseup_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl.onMouseUp != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onMouseUp(ctl, &mea)
		}
		if ctl.onClick != nil {
			ea := new_event_args()
			ctl.onClick(ctl, &ea)
		}
	}
	
// End section

// Right mouse down, up, click
	ctrl_right_mousedown_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl.onRightMouseDown != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onRightMouseDown(ctl, &mea)
		}
	}

	ctrl_right_mouseup_handler :: proc(ctl: ^Control, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl.onRightMouseUp != nil {
			mea := new_mouse_event_args(msg, wpm, lpm)
			ctl.onRightMouseUp(ctl, &mea)
		}
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

	@private ctrl_mousemove_handler :: proc(ctl: ^Control, hw: HWND, msg: UINT,wpm: WPARAM, lpm: LPARAM)
	{
		if ctl._isMouseEntered {
			if ctl.onMouseMove != nil {
				mea := new_mouse_event_args(msg, wpm, lpm)
				ctl.onMouseMove(ctl, &mea)
			}
		}
		if ctl._tmeFlags > 0 {
			if ctl._isMouseTracking {
				ctl._isMouseTracking = track_mouse_move(ctl.handle, ctl._tmeFlags)
				if SpecialMouseEvents.Mouse_Enter in ctl._mouseEvents && !ctl._isMouseEntered {
					ctl._isMouseEntered = true
					ea := new_event_args()
					ctl.onMouseEnter(ctl, &ea)
				}
			}			
		}		
	}

	@private ctrl_mouseleave_handler :: proc(ctl: ^Control)
	{
		ctl._isMouseEntered = false
		if ctl._isMouseTracking {
			ctl._isMouseTracking = false
			if ctl.onMouseLeave != nil {
				ea := new_event_args()
				ctl.onMouseLeave(ctl, &ea)
			}			
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

@private ctrl_set_font :: proc(this: ^Control, value: $T)
{
	when T == Font { this.font = value } else {print("Type error...")}
	if this.font.handle == nil do font_create_handle(&this.font)
	if this._isCreated do SendMessage(this.handle, WM_SETFONT, WPARAM(this.font.handle), LPARAM(1))
}

// End section

@private control_property_setter :: proc(this: ^Control, prop: CommonProps, value: $T)
{
	switch prop {
		case .Back_Color: set_back_color1(this, uint(value))
		case .Font: ctrl_set_font(this, value)
		case .Fore_Color: set_fore_color1(this, uint(value))
		case .Enabled: control_enable(this, bool(value))
		case .Height: control_set_size(this, this.width, int(value))
		case .Text: control_set_text(this, tostring(value))
		case .Visible: control_visibile(this, bool(value))
		case .Width: control_set_size(this, int(value), this.height)
		case .Xpos: control_set_position(this, int(value), this.ypos)
		case .Ypos: control_set_position(this, this.xpos, int(value))
	}
}



set_property :: proc(ctl: ^$T,  prop: $U, value: $V)
{
	prop_num : int = int(prop)
	switch prop_num {
		case 0..=int(max(CommonProps)):
			control_property_setter(ctl, auto_cast(prop), value)

		case int(min(CalendarProps))..=int(max(CalendarProps)):
			when T == Calendar do calendar_property_setter(ctl, prop, value)

		case int(min(CheckBoxProps))..=int(max(CheckBoxProps)):
				when T == CheckBox do checkbox_property_setter(ctl, prop, value)

		case int(min(ComboProps))..=int(max(ComboProps)):
				when T == ComboBox do combo_property_setter(ctl, prop, value)

		case int(min(DTPProps))..=int(max(DTPProps)):
				when T == DateTimePicker do dtp_property_setter(ctl, prop, value)

		case int(min(FormProps))..=int(max(FormProps)):
				when T == Form do form_property_setter(ctl, prop, value)

		case int(min(GroupBoxProps))..=int(max(GroupBoxProps)):
				when T == GroupBox do gbx_property_setter(ctl, prop, value)

		case int(min(LabelProps))..=int(max(LabelProps)):
				when T == Label do label_property_setter(ctl, LabelProps(prop), value)

		case int(min(ListBoxProps))..=int(max(ListBoxProps)):
				when T == ListBox do listbox_property_setter(ctl, prop, value)

		case int(min(ListViewProps))..=int(max(ListViewProps)):
				when T == ListView do listview_property_setter(ctl, prop, value)

		case int(min(NumberPickerProps))..=int(max(NumberPickerProps)):
				when T == ListView do numberpicker_property_setter(ctl, prop, value)

		case int(min(ProgressBarProps))..=int(max(ProgressBarProps)):
				when T == ListView do progressbar_property_setter(ctl, prop, value)

		case int(min(RadioButtonProps))..=int(max(RadioButtonProps)):
				when T == ListView do radiobutton_property_setter(ctl, prop, value)

		case int(min(TextBoxProps))..=int(max(TextBoxProps)):
				when T == ListView do textbox_property_setter(ctl, prop, value)

		case int(min(TrackBarProps))..=int(max(TrackBarProps)):
				when T == ListView do trackbar_property_setter(ctl, prop, value)

		case int(min(TreeViewProps))..=int(max(TreeViewProps)):
				when T == ListView do treeview_property_setter(ctl, prop, value)
	}
}


// User who wants to use mouse enter event must call this function to set the event handler.
ctrl_set_mouse_enter_handler :: proc(this: ^Control, evtProc: EventHandler,) 
{
	this._mouseEvents += {.Mouse_Enter}
	set_bit_flag(&this._tmeFlags, MouseTrackingFlags.TME_Leave)
	this.onMouseEnter = evtProc	
}

// User who wants to use mouse hover event must call this function to set the event handler.
ctrl_set_mouse_hover_handler :: proc(this: ^Control, evtProc: EventHandler,) 
{
	this._mouseEvents += {.Mouse_Hover}
	set_bit_flag(&this._tmeFlags, MouseTrackingFlags.TME_Hover)
	this.onMouseHover = evtProc	
	if this.kind == .Combo_Box {
		combo_set_hover_timer((^ComboBox)(this))
	} else if this.kind == .Number_Picker {
		nump_set_hover_timer((^NumberPicker)(this))
	}
}

// User who wants to use mouse leave event must call this function to set the event handler.
ctrl_set_mouse_leave_handler :: proc(this: ^Control, evtProc: EventHandler,) 
{
	this._mouseEvents += {.Mouse_Leave}
	set_bit_flag(&this._tmeFlags, MouseTrackingFlags.TME_Leave)
	this.onMouseLeave = evtProc		
}

