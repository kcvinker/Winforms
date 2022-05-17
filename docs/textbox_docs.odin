/*
TextBox doumentation

*/

TextBox :: struct {
    using control : Control, // It's inheriting from Control.
    text_alignment : TbTextAlign, // Alignment of the text
    multi_line : bool, // default is false. True to create a multi line text box
    text_type : TextType, // Choose plain text or number only or passwords. 
        // TextType :: enum {Default, Number_Only, Password_Char}
    text_case : TextCase, // Upper case or lower case letters.
        // TextCase :: enum {Default, Lower_Case, Upper_Case}
    hide_selection : bool, // If set to true, selection will be hidden when control lost focus. Default is false
    read_only : bool, // If set to true, control will work as read only. Default is false
    cue_banner : string, // You can set cue banner text to text box. If you click on it, it will dissappear.
    
    // Events --
    // Since text box is inheritting from Control, it has almost all the events of Control

    text_changed : EventHandler, // Occurrs when use changes the text
}

// Constructors
new_textbox :: proc(parent : ^Form) -> TextBox 
new_textbox :: proc(parent : ^Form, w, h : int, x : int = 50, y : int = 50) -> TextBox

// Functions
textbox_set_selection :: proc(tb : ^TextBox, value : bool) // Set the text selected or un selected as per value
textbox_set_readonly :: proc(tb : ^TextBox, bstate : bool) // Set the text box's read only state after it created
textbox_clear_all :: proc(tb : ^TextBox) // Delete all the text in text box

