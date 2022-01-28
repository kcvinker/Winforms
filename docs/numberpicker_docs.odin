// Documentation for NumberPicker type
/*
NumberPicker is known as Updown control in win32 sector and in .Net sector, it is known as NumericUpDown.
Since, it is using for picking numbers only, I have decided to give this name.
It is basically a combo of two controls. 
    1. Spin control - Which has two small buttons on it and those buttons have a up & down arrow symbol.
    2. Edit control - Which is associated with the spin control.
You can either click the spin buttons or type directly to the textbox or you can press the up & down arrow keys
Defaults 
    min_range = 0
    max_range = 100
    step = 1
    decimal precision = 0
*/

NumberPicker :: struct {
    using control : Control,
    button_alignment : ButtonAlignment, // enum {right, left} Spin button's position
    text_alignment : SimpleTextAlignment, // enum {left, center, right} 
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
create_numberpicker :: proc(np : ^NumberPicker, )  // Create the handle NumberPicker
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
    np.text_alignment = .center
    np.back_color = 0x8080FF
    np.fore_color = 0xFFFFFF
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
