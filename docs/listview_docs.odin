/*
ListView documentation  - Created on : 25-May-22 09:42:55 AM

*/
ListView :: struct {			
	using control : Control,			// Inheriting from Control
	item_alignment : enum {Left, Top},	// Alignment of the item
	column_alignment : ColumnAlignment,	// Alignment of Columns. - enum {left, right, center,}
	view_style : ListViewStyle,			// Style of list view - enum {Lisst, Report, }
	view_mode : ListViewViews,			// View mode of list view - enum {Icon, Details, Small_Icon, List, Tile, }
	hide_selection : bool,		// If set true, selection will be hidden when lost focus
	multi_selection : bool,		// If set true, multiple items can be seletced
	has_checkboxes : bool, 		// If set true, a check box will be apear at first column. You can re order columns
	full_row_select : bool, 	// If set true, users can select a full row instead of a single cell.
	show_grid_lines : bool, 	// If set true, shows grid lines, but only work in "Details" view mode.
	one_click_activate : bool, 	// If set true, users can activate an item at single click.
	hot_track_select : bool, 	// If set true, items under mouse cursor will be selected
	edit_label : bool,			// If set true, users can edit the text in cells.
	items : [dynamic]ListViewItem,		// Items collection of list view
	columns : [dynamic]^ListViewColumn,	// Columns collection list view
	
}

ListViewColumn :: struct {
	text : string,					// text of column header
	width : int,					// width of column	
	index : int,					// index number of column
	has_image, 						// set true to show an image in header
	image_on_right : bool,			// set true to show the image at right side
	alignment : ColumnAlignment,	// determains the text alignment of the column. - enum {left, right, center,}
}

ListViewItem :: struct {
	index : int,				// index number of the item
	text : string,				// text of the item (Means, first columns text in report mode)
	back_color : uint,			// back color of the item
	fore_color : uint,			// fore color of the item
	font : Font,				// font of the item
	image_index : int,			// index number of an image from image list. 
}

ListViewSubItem :: struct {
	text : string,				// text of the sub item
	back_color : uint,			// back color of the sub item
	fore_color : uint,			// fore color of the sub item
	font : Font,				// font of the sub item
}

// Enums used in ListView
ListViewStyle :: enum {Lisst, Report, }
ListViewViews :: enum {Icon, Details, Small_Icon, List, Tile, }
ColumnAlignment :: enum {left, right, center,}

/*----------------------------------------------------------------------------------------------------
											↓ ListView CTOR ↓
*---------------------------------------------------------------------------------------------------*/
// Create a new ListView struct
new_listview :: proc(f : ^Form, x, y, w, h : int) -> ListView 
new_listview :: proc(f : ^Form) -> ListView


/*------------------------------------------------------------------------------------------------------------
										↓ ListViewColumn CTOR ↓
*-------------------------------------------------------------------------------------------------------------*/
new_listview_column :: proc(txt : string, width : int, pos : int = -1 ) -> ListViewColumn 
new_listview_column :: proc(txt : string, pos : int = -1 ) -> ListViewColumn
new_listview_column :: proc(txt : string, width : int, col_align : ColumnAlignment, pos : int = -1  ) -> ListViewColumn


/*------------------------------------------------------------------------------------------------------------
										↓  ListViewItem CTOR ↓
*-----------------------------------------------------------------------------------------------------------*/
new_listview_item :: proc(txt : string, bgc : uint, fgc : uint, img : int = -1) -> ListViewItem
new_listview_item :: proc(txt : string) -> ListViewItem 
new_listview_item :: proc(txt : string, img : int) -> ListViewItem



/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Coulmn functions ↓
*--------------------------------------------------------------------------------------------------------*/
listview_add_column :: proc(lv : ^ListView, txt : string, width : int, img : bool = false, imgOnRight : bool = false)
listview_add_column :: proc(lv : ^ListView, lvc : ^ListViewColumn)
listview_add_column :: proc(lv : ^ListView, txt : string, width : int, align : ColumnAlignment)


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Row functions ↓
*--------------------------------------------------------------------------------------------------------*/ 
listview_add_row :: proc(lv : ^ListView, items : ..any )
listview_add_row :: proc(lv : ^ListView, item_txt : any)


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Item functions ↓
*--------------------------------------------------------------------------------------------------------*/
listview_add_item :: proc(lv : ^ListView, lvi : ^ListViewItem) 


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add SubItem functions ↓
*--------------------------------------------------------------------------------------------------------*/
listview_add_subitem :: proc(lv : ^ListView, item_indx : int, sitem : any, sub_indx : int) 
listview_add_subitems :: proc(lv : ^ListView, item_indx : int, items : ..any) 


/*-------------------------------------------------------------------------------------------------------
*									↓ General Public functions ↓
*--------------------------------------------------------------------------------------------------------*/

// Set the column order of list view. 
// Example - listview_set_column_order(lv, 2, 1, 0) 
// This will set the column indices in the same order.
listview_set_column_order :: proc(lv : ListView, col_order : ..i32)

// Returns the column count of this list view
listview_get_coulmn_count :: proc (lv : ^ListView) -> int

listview_set_view :: proc (lv : ^ListView, view : ListViewViews) // Set the view mode for list view

listview_begin_update :: proc (lv : ^ListView) 

listview_end_update :: proc (lv : ^ListView)


/*-------------------------------------------------------------------------------------------------------
*											↓ ListView Delete Item functions ↓
*--------------------------------------------------------------------------------------------------------*/
listview_delete_item :: proc (lv : ^ListView, item : ListViewItem)
listview_delete_item :: proc (lv : ^ListView, item_index : int)


listview_delete_selected_item :: proc (lv : ^ListView ) 
listview_clear_items :: proc (lv : ^ListView)
listview_delete_column :: proc (lv : ^ListView) 
listview_get_item :: proc (lv : ^ListView) 
listview_get_row :: proc (lv : ^ListView) -> []string 

