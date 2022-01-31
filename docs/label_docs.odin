/*
Label doumentation
Created on 31-Jan-2022 10:40 PM
*/

Label :: struct {
    using control : Control,
    auto_size : b64, // Label will automatically find its size to fit the text. Default is true.
    border_style : LabelBorder, // enum {no_border, single_line, sunken_border, }. Default is no_border.
    text_alignment : TextAlignment, // enum {top_left, top_center, top_right, mid_left, center, mid_right, bottom_left, bottom_center, bottom_right}. Default is top_left
    multi_line : bool, // Enable text to spread into multi lines. Default is false.
    // Events --- 
    /* There are no special events for a Label. 
    But it has some common events which inherited from Control type.
    Note : There are no keyboard events for label. 
    Please refer to Control type's doc for Label events.
    */
}

// Constructors
new_label :: proc(parent : ^Form) -> Label
new_label :: proc(parent : ^Form, txt : string, w : int = 0, h : int = 0) -> Label

// Functions
create_label :: proc(lb : ^Label) // Create the label handle.