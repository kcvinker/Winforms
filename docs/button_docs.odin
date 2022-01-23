
// Documentation for Button Type

Button :: struct {
	using control : Control,	
	style : ButtonStyle,
}

// Constructors
new_button :: proc(parent : ^Form) -> Button
new_button :: proc(parent : ^Form, txt : string, x, y : int, w : int = 120, h : int = 40) -> Button

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


