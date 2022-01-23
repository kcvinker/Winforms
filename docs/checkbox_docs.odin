// Docs for CheckBox Control

CheckBox :: struct {
    using control : Control,
    checked : b32, // Checked state of checkbox
    text_alignment : enum {left, right}, // text appear on the left side of checkbox or right side of the checkbox
    // Event
    check_changed : EventHandler, //  When user change the check state of CheckBox.    
}

// Constructors
new_checkbox :: proc(parent : ^Form, txt : string = "") -> CheckBox
new_checkbox ::  proc(parent : ^Form, txt : string, w, h : int, x : int = 50, y : int = 50) -> CheckBox

// Functions
create_checkbox :: proc(cb : ^CheckBox) // Create the handle of check box

