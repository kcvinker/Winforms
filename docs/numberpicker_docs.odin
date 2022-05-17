// Documentation for NumberPicker type
/*
NumberPicker is known as Updown control in win32 sector and in .Net sector, it is known as NumericUpDown.
Since, it is using for picking numbers only, I have decided to give this name.
It is basically a combo of two controls. 
    1. Spin control - Which has two small buttons on it and those buttons have a up & down arrow symbol.
    2. Edit control - Which is associated with the spin control.
You can either click the spin buttons or type directly to the textbox or you can press the up & down arrow keys. 
Note :- If you type some numbers in text area, you need to press Enter or Tab key to make that 
change updated in NumberPicker. A mouse click on the spin button also cause the updation.
Otherwise, you lost the entered input and control will display the last updated value.
Defaults 
    min_range = 0
    max_range = 100
    step = 1
    decimal precision = 0
*/

NumberPicker :: struct {
    using control : Control,
    button_alignment : ButtonAlignment, // enum {Right, Left} Spin button's position
    text_alignment : SimpleTextAlignment, // enum {Left, Center, Right} 
    min_range, max_range : f32, // Min & max range for value in NumberPicker
    has_separator : bool, // Displays a thousand separator. True by default.
    auto_rotate : bool, // If enabled, if you add next step after max_range, it will automatically go to min_range
    value : f32,        // Value of NumberPicker
    format_string : string, // You can set a format string for the look of the value. Please refer Odin's core documentation page for format strings.
    decimal_precision : int, // You can set the decimal precition, Zero is default. If you set the format_string, this value will not work
    hide_selection : bool, // You can hide the selection of text area. On by default.    
    step : f32,     // Set this value for increment & decrement. 1 is default.    

    // Events
    button_paint,   // Spin button's paint
    text_paint : PaintEventHandler, // Textbox's paint
    value_changed : EventHandler,   // When user change value with (1) keyboard or (2) mouse
}
// Constructor
new_numberpicker :: proc(parent : ^Form) -> NumberPicker
new_numberpicker :: proc(parent : ^Form, x, y, w, h : int) -> NumberPicker 

// Functions
create_control :: proc(c : ^Control) // To create NumberPicker
numberpicker_set_range :: proc(np : ^NumberPicker, max_val, min_val : int) // Set the max & min range for NumberPicker. This is used when you want to set the range after you create the control. Before creation, you can use min_range & max_range fields.

// Example
import ui "winforms"  

frm : ui.Form
np : ui.NumberPicker

main :: proc() {
    frm = new_form(txt = "NumberPicker Example")
    create_form(&frm)

    np = new_numberpicker(&frm, 190, 145, 100, 25)
    np.font = new_font("Hack", 14, true) 
    np.text_alignment = .Center
    np.back_color = def_back_clr
    np.fore_color = def_fore_clr
    np.step = 0.25
    np.auto_rotate = true
    np.format_string = "%.3f"
    //np.decimal_precision = 2 // This won't work when format_string enabled
    //np.mouse_enter = gen_events  // there are lots of events
    // np.mouse_leave = gen_events
    np.value_changed = on_np_value_changed
    create_numberpicker(&np)

    start_form()
}

on_np_value_changed :: proc(c : ^Control, e : ^EventArgs) {
    ui.msg_box(np.value)
}

/*NumericUpdown in .NET has an interesting bug.
When you set the MouseLeave event, if you move the mouse pointer towards the spin button area,
You will get a mouse leave event. Which I am sure anyone wants to get.
Reason for this problem is obvious. NumericUpdown is a combo of two controls.
So the mouse leave event will be triggered when pointer reaches the edge of textbox or spin button.
So the event will be fired. But this is not a big issue. We can solve it easily.
I don't know why MS is leaving this bug as it is.
In this NumberPicker, I solved this issue and the mouse_leave event will be fired only when you move the 
pointer out of it's actual rect. So each time when your NumberPicker get a WM_MOUSELEAVE message,
it will check the current mouse position. Then it will check if that position is it's buddy control.
If that mouse points are inside it's buddy's rect, the message will be suppressed. Otherwise, it will fire a
mouse_leave event. 


