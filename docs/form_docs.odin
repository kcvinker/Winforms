
// Documentation for Form type.
Form :: struct {
    using control : Control,  // A Form is inheriting from Control type.
    start_pos : StartPosition, // Values - top_left, top_mid, top_right, mid_left, center, mid_right, bottom_left, bottom_mid, bottom_right, manual
    style : FormStyle, // Values - default, fixed_single, fixed_3d, fixed_dialog, fixed_tool, sizable_tool
    minimize_box, maximize_box : b32,
    window_state : FormState,    // Values - normal = 1, minimized, maximized

    // events
    load : EventHandler, // Signature - proc(sender : ^Control, ea : ^EventArgs)
    activate,
    de_activate : EventHandler,
    moving, moved : MoveEventHandler, // Signature - proc(sender : ^Control, e : ^MoveEventArgs)
    minimized, 
    maximized, 
    restored, 
    closing, 
    closed : EventHandler,    
}

// Constructors
new_form :: proc() -> Form
new_form :: proc(txt : string, w : int = 500, h : int = 400) -> Form


// Functions
create_form :: proc(frm : ^Form ) // Create the form handle
start_form :: proc() // Show the form and start the main loop
show_form :: proc(f : Form) // Just show the form - Used for second form
hide_form :: proc(f : Form) // Hide a form
set_form_state :: proc(frm : Form, state : FormState) // Set the window state of a form. Please see the FormState enum.
set_gradient_form :: proc(f : ^Form, clr1, clr2 : uint, style : GradientStyle = .top_to_bottom)
/*Info
    Set grdient colors for a form.
    Parameters - clr1 -- color value 1
                clr2 -- color value 2
                GradientStyle - enum - top_to_bottom, left_to_right
*/

// Example 

import ui "winforms"
frm : ui.Form
main :: proc() {
    using ui
    frm = new_form("My New Odin Form") 
    frm.mouse_click = form_click
    create_form(&frm)

    // You can create other controls here.
    
    start_form() // From now, you can see the form is up & running.

}

form_click :: proc(sender : ^ui.Control, ea : ^ui.EventArgs) {
    ui.msg_box("Hi, I am from winforms !") 
}