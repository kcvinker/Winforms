
// Documentation for Form type.
Form :: struct {
    using control : Control,  // A Form is inheriting from Control type.
    start_pos : StartPosition, // Values - Top_Left, Top_Mid, Top_Right, Mid_Left, Center, Mid_Right, Bottom_Left, Bottom_Mid, Bottom_Right, Manual
    style : FormStyle, // Values - Default, Fixed_Single, Fixed_3D, Fixed_Dialog, Fixed_Tool, Sizable_Tool
    minimize_box, maximize_box : b32,
    window_state : FormState,    // Values - Normal = 1, Minimized, Maximized

    // events
    load : EventHandler, // Signature - proc(sender : ^Control, ea : ^EventArgs)
    activate,
    de_activate : EventHandler,    
    moving, moved : EventHandler, 
    resizing,resized : SizeEventHandler  // Signature - proc(sender : ^Control, e : ^SizeEventArgs)
        /*
            SizeEventArgs :: struct {
                using base : EventArgs,
                form_rect : ^Rect, // Containsform's current window rect
                sized_on : SizedPosition, // On which side of the window, the resizng happened.
                client_area : Area, // Width & height of client area of form.
            }
        */
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
set_gradient_form :: proc(f : ^Form, clr1, clr2 : uint, style : GradientStyle = .Top_To_Bottom)
/*Info
    Set grdient colors for a form.
    Parameters - clr1 -- color value 1
                clr2 -- color value 2
                GradientStyle - enum - Top_To_Bottom, Left_To_Right
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