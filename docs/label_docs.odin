/*
Label doumentation
Created on 31-Jan-2022 10:40 PM
*/

Label :: struct {
    using control : Control,
    auto_size : b64, // Label will automatically find its size to fit the text. Default is true.
    border_style : LabelBorder, // enum {No_Border, Single_Line, Sunken_Border, }. Default is No_Border.
    text_alignment : TextAlignment, // enum {Top_Left, Top_Center, Top_Right, Mid_Left, center, Mid_Right, Bottom_Left, Bottom_Center, Bottom_Right}. Default is Top_Left
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
create_control :: proc(c : ^Control) // To create Label