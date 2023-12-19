// Doc for ComboBox type

ComboBox :: struct {
    using control : Control,
    combo_style : DropDownStyle, // values - {Tb_Combo, Lb_Combo} 
                                // Tb_Combo = You have a textbox on your combo box and you can type something in that textbox.
                                // Lb_Combo = You have a label on your combo box and you only see the list of items. 
    items : [dynamic]string, // A dynamic array to keep track of all items in combo
    visible_item_count : int, 
                // When you click on combo box's dropdown menu button,...
                // you can control how many items will be displayed in dropdown list.
                // In other words, this value will decide the height of your dropdown list.
    
    // Events
    selection_changed, // When user chang the selection.
    selection_committed, // when user change the selection and dropdown list closed
    selection_cancelled, // when users selection cancelled
    text_changed, // when user type something in text area. Only applicable in tb_combo style
    text_updated, // same as text_changed, but this event will triggered...
                // right after user type a character and before it will be dispayed in combo.
                // Only applicable in tb_combo style
    list_opened, // when the dropdown list appear
    list_closed, // when the dropdown list closed
    tb_click, // when clicking on the text area. Only applicable in tb_combo style
    tb_mouse_leave, // when mouse moving upon the text area. Only applicable in tb_combo style
    tb_mouse_enter : EventHandler, // when enter on the text area. Only applicable in tb_combo style
}

// Constructors
new_combobox :: proc(parent : ^Form) -> ComboBox
new_combobox :: proc(parent : ^Form, w, h : int ) -> ComboBox 

// Functions
create_control :: proc(c : ^Control) // To create a Combo
combo_set_style :: proc(cmb : ^ComboBox, style : DropDownStyle) // Set the style of combo box.
        // style - enum values - {tb_combo, lb_combo} 

combo_add_item :: proc(cmb : ^ComboBox, item : $T ) // Add an item to combo box.
combo_add_items :: proc(cmb : ^ComboBox, items : ..any ) // Add more than one item at once.
combo_add_array :: proc(cmb : ^ComboBox, items : []$T ) // Add an array to combo box
combo_open_list :: proc(cmb : ^ComboBox) // Open dropdown list of combo box
combo_close_list :: proc(cmb : ^ComboBox)  // close dropdown list of combo box
combo_get_selected_index :: proc(cmb : ^ComboBox) -> int // get the selected index of combo box.
combo_set_selected_index :: proc(cmb : ^ComboBox, indx : int) // Set the selected index of combo box
combo_get_selected_item :: proc(cmb : ^ComboBox) -> any // get the selected item from combo box
combo_remove_selected_item :: proc(cmb : ^ComboBox) // remove the selected item from combo box

