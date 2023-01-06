// Docs for listbox type

ListBox :: struct {
    using control : Control,
    items : [dynamic]string, // Hold the items 
    has_sort : b64,         // If enabeled, item will be sorted. Default = false    
    no_selection : b64,     // If enabled, user can't select an item
    multi_selection : b64,  // If enabled, user can select multiple items.
    multi_column : b64,     // If enabled, multiple columns will be visible in listbox
    key_preview : b64,      // If enabled, keyboard focus will be received in listbox.

    // Event - Occures when user change a selection.
    selection_changed : LBoxEventHandler, // Signature - proc(sender : ^Control, e : string)
}

// Construtors----------------------------------
new_listbox :: proc(parent : ^Form) -> ListBox 

// Functions------------------------------------------
create_control :: proc(c : ^Control) // To create ListBox

listbox_add_item :: proc(lbx : ^ListBox, item : $T) // Add an item to listbox

listbox_add_items :: proc(lbx : ^ListBox, items : ..any) // Add multiple items to listbox

listbox_get_selected_index :: proc(lbx : ^ListBox) -> int // Get the selected index from listbox

listbox_get_selected_indices :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]i32 // Get selected idices from a multi selection listbox.

listbox_get_item :: proc(lbx : ^ListBox, indx : i32, alloc := context.allocator) -> string  // Get an item from listbox

listbox_get_item :: proc(lbx : ^ListBox, indx : int, alloc := context.allocator) -> string // Get an item from listbox

listbox_get_selected_item :: proc(lbx : ^ListBox) -> string // Get selected item from listbox

listbox_get_selected_items :: proc(lbx : ^ListBox, alloc := context.allocator) -> [dynamic]string // Get selected item from listbox

listbox_set_item_selected :: proc(lbx : ^ListBox, indx : int) // Set item at given index become selected

listbox_clear_selection :: proc(lbx : ^ListBox) // Clear all selections from listbox

listbox_delete_item :: proc(lbx : ^ListBox, indx : int) // Delete an item from listbox

listbox_insert_item :: proc(lbx : ^ListBox, indx : int, item : any) // Insert an item at given index

listbox_find_index :: proc(lbx : ^ListBox, item : any) -> int // find the index of an item

listbox_get_hot_index :: proc(lbx : ^ListBox) -> int // get the index of the item under mouse point.

listbox_get_hot_item :: proc(lbx : ^ListBox) -> string // get item under mouse pointer

listbox_clear_items :: proc(lbx : ^ListBox) // Delete all items in listbox




