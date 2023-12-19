// Docs for CheckBox Control

CheckBox :: struct {
    using control : Control,
    checked : b32, // Checked state of checkbox
    text_alignment : enum {Left, Right}, // text appear on the left side of checkbox or right side of the checkbox
    // Event
    check_changed : EventHandler, //  When user change the check state of CheckBox.
}

// Constructors
newCheckBox :: proc(parent : ^Form, txt : string = "") -> CheckBox
newCheckBox ::  proc(parent : ^Form, txt : string, x, y : int) -> CheckBox
newCheckBox ::  proc(parent : ^Form, txt : string, x, y, w, h : int) -> CheckBox

// Functions
create_control :: proc(c : ^Control) // To create a Checkbox
