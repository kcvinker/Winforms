/*
    Created on : 02-Feb-2022 10:04:34 PM
    Name : RadioButton documentation
*/

RadioButton :: struct {
    using control : Control,
    text_alignment : enum {Left, Right}, // Determines whether the text of the radio button is left or right.
    checked : bool, // checked state of radio button
    check_on_click : bool, // Determines whether the radio button change the checked state when clicked
    // RadioButton supports all other common properties that Control type offers.

    // Event
    state_changed : EventHandler, // Occurrs when radio button's checked state changes
    // RadioButton supports all other common events that Control type offers.
}

// Constructor
newRadioButton :: proc(parent : ^Form) -> RadioButton
newRadioButton :: proc(parent : ^Form, txt : string) -> RadioButton
newRadioButton :: proc(parent : ^Form, txt : string, x, y : int) -> RadioButton
newRadioButton :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> RadioButton


// Functions
create_control :: proc(c : ^Control) // To create radio button.
radiobutton_set_state :: proc(rb : ^RadioButton, bstate: bool) // Set the checked state of radio button.
radiobutton_set_autocheck :: proc(rb : ^RadioButton, auto_check : bool ) // Set the check-on-click behaviour.