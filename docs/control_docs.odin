// Documentation for Control type
// Form and all other controls are inheriting from Control type.

Control :: struct {
	kind : ControlKind, // Enum - For internal use
	handle : HWND, // HANDLE of the control.
	controlID : UINT,// control ID. Basically no use, but it's a tradition to have one.
	parent : ^Form, // All control had a parent.
	text : string, // Not applicable for all controls
	width, height : int,
    xpos, ypos : int,
    font : Font,
	backColor : UINT, // Not applicable for all controls
	foreColor : UINT, // Not applicable for all controls
	enabled : bool, 		// Enable or disable a control
	visibile : bool,		// SHow or hide a control


    // Events
	paint : PaintEventHandler, // - signature - proc(sender : ^Control, e : ^PaintEventArgs)
	onGotFocus, // when control get key board or mouse focus
	onLostFocus , // when control lost key board or mouse focus
	onMouseEnter, // when mouse entered to control's rect
	onMouseClick, // when mouse is clicked upon control's rect
	onRightClick, // when right mouse is clicked upon control's rect
	onDoubleClick, // when mouse is double clicked upon control's rect
	onMouseLeave, // when right mouse leaved from control's rect
	onSizeChanging, // when control's size is changeing
    // when after controls size changed
	onSizeChanged : EventHandler, // signature - proc(sender : ^Control, ea : ^EventArgs)
    onLeftMouseDown, // when left mouse is down
    onRightMouseDown, // when right mouse is down
    onLeftMouseUp, // when left mouse is up
    onRightMouseUp, // when right mouse is up
    onMouseScroll,	// when mouse wheel scrolled
    onMouseMove, // when mouse moved upon control's rect
	onMouseHover : MouseEventHandler, // signature  - proc(sender : ^Control, e : ^MouseEventArgs)
    onKeyUp, // when a key up
	onKeyDown, // when a key down
    // coming after a key down & up.
	onKeyPress : KeyEventHandler, // signature - proc(sender : ^Control, e : ^KeyEventArgs)

}

// Functions
control_set_position :: proc(ctl : ^Control, x, y : int) // Set the position of a control
control_set_size :: proc(ctl : ^Control, width, height : int) // Set the size of a control
control_set_text :: proc(ctl : ^Control, txt : string) // Set the text of a control. Not all controls support this.
control_get_text :: proc(ctl : Control) -> string // get text from a control. Not all controls support this.
control_get_text_wstr :: proc(ctl : Control) -> []u16 // get text from a control, but returns a wstring instead of odin string.
control_set_back_color :: proc(ctl : ^Control, clr : uint) // set the back color of control. Not all controls support this.
control_set_fore_color1 :: proc(ctl : ^Control, clr : uint) // set the fore color of control. Not all controls support this.

control_enable :: proc(ctl : ^Control, bstate : bool) // Enable or disable a control at runtime

control_visibile :: proc(ctl : ^Control, bstate : bool) // Show or hide a control at runtime.
create_control :: proc(c : ^Control) // To create a any control
create_controls :: proc(ctls : ..^Control) // To create more than one control at once.

