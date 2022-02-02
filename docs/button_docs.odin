
// Documentation for Button Type

Button :: struct {
	using control : Control,	
    // Button supports all common properties that Control type offers.

    // Events
    // Button supports all common events that Control type offers.
}

// Constructors
new_button :: proc(parent : ^Form) -> Button
new_button :: proc(parent : ^Form, txt : string) -> Button 
new_button :: proc(parent : ^Form, txt : string, x, y : int) -> Button
new_button :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> Button

// Functions
create_button :: proc(btn : ^Button) // Creates button handle.
create_buttons :: proc(btns : ..^Button) // Created more than one button handles at once. Easy when you need to create too many buttons.

set_button_gradient :: proc(btn : ^Button, clr1, clr2 : uint, style : GradientStyle = .top_to_bottom) 
/* Info.
    Set gradient colors for a button.
    Parameters :
        btn - Pointer to the button struct
        clr1 - first color for gradient
        clr2 - second color for gradient.
        style - enum 
            Possible values - top_to_bottom, left_to_right
*/

//Exapmle
import ui "winforms"

frm : ui.Form
btn : ui.Button
btn2 : ui.Button
btn3 : ui.Button

main :: proc() {
    using ui
    frm = new_form("My New Odin Form")     
    create_form(&frm)

    btn = new_button(&frm, "Normal Btn", 50, 50) // A normal button
    btn.mouse_click = btn_click
    create_button(&btn)

    btn2 = new_button(&frm, "Gradient Btn", 50, 100, 150) 
    set_button_gradient(&btn2, 0xFF8040, 0x008000) // This button will be painted with gradient brush.
    create_button(&btn2)

    btn3 = new_button(&frm, "Color Btn", 50, 150)
    btn.back_color = 0x8080FF // This button had a flat single color.
    create_button(&btn3)

    start_form() 
}

btn_click :: proc(sender : ^ui.Control, ea : ^ui.EventArgs) {
    ui.msg_box("Hi, I am from winforms !") 
}
