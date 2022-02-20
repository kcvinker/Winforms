
/*
	Created on : 19-Feb-2022 15:56 3:56:53 PM
		Name : Treeview Documentation
		*/

TreeView :: struct {
    using control : Control,  // Inheriting from Control type. 
    no_lines : bool,            // Treeview will be drawn without lines. Default is false
    no_buttons : bool,          // Treeview will be drawn without buttons. Default is false
    has_checkboxes : bool,      // Treeview will be drawn with checkboxes. Default is false
    full_row_select : bool,     // TreeNode will be selected as full row instead of text area. Default is false
    editable : bool,            // Treeview will be editable and you can type text in a node. Default is false
    show_selection : bool,      // Selection of a node will be visible after losing focus. Default is false
    hot_tracking : bool,        // Enabling hot tracking of a node. Default is false.
    selected_node : ^TreeNode,  // Selected node. If there is no selection, this will be nil.
    nodes : [dynamic]^TreeNode, // List of pointer to child nodes.   
    image_list : HimageList,    // ImageList for treeview. 
    line_color : uint,          // Line color. Default is black.    

   // Events-- Besides these events, TreeView supports almost all events in Control type.

    begin_edit,                 // When user begin editing an editable node.
    end_edit : EventHandler,    // When user finished editing in an editable node
    node_deleted : EventHandler,    // When deleting a node.
    before_checked,         // Occurres right before a node's check box is being checked or unchecked
    after_checked,          // Occurres right after a node's check box is being checked or unchecked
    before_select,          // Occurres right before a node is being seleted
    after_select,           // Occurres right after a node is being selected 
    before_expand,          // Occurres right before a node is expanded
    after_expand,           // Occurres right after a node is expanded
    before_collapse,        // Occurres right before a node is collapsed
    after_collapse : TreeEventHandler,  // Occurres right before a node is collapsed.
}

// Constructor
new_treeview :: proc(parent : ^Form) -> TreeView 
new_treeview :: proc(parent : ^Form, x, y, w, h : int) -> TreeView 

// Functions
create_treeview :: proc(tv : ^TreeView)  // Create the handle of TreeView control.
treeview_add_node :: proc(tv : ^TreeView, node : ^TreeNode, parent : ^TreeNode = nil) 
    // Adding a new node to tree view. This can be a root node or a child node.
    // Parameters :
        // tv : Pointer to the TreeView
        // node : Pointer to the node which you want to add.
        // parent : Ponter to a parent node, if you want to add a child node.
    // Notes : If there is at least a node in treevview, this node will be added to the last position.

treeview_insert_node :: proc(tv : ^TreeView, node : ^TreeNode, index : int,  parent : ^TreeNode = nil) 
    // Inserting a node to tree view. This can be a root node or a child node.
    // Parameters :
        // tv : Pointer to the TreeView
        // node : Pointer to the node which you want to add.
        // index : A position where the node will be inserted.
        // parent : Ponter to a parent node, if you want to add a child node.

treeview_delete_node :: proc(tv : ^TreeView, node : ^TreeNode) // Delete a node from tree view.

treeview_set_node_color :: proc(tv : ^TreeView, node : ^TreeNode) 
    // Set back ground & fore goround colors of a node.
    // This function is used to change colors at run time.
    // To set the node colors before creating a tree view,...
    // just set the back_color & fore_color properties.

treeview_set_line_color :: proc(tv : ^TreeView, clr : uint)
    /* Set the lin color of TreeView 
        Parameters : 
            tv : Pointer to TreeView struct
            clr : A hex value of color. */

treeview_set_image_list :: proc(tv : ^TreeView, himl : HimageList) 
    /* Set the image list for this TreeView.*/

treeview_create_image_list :: proc(tv : ^TreeView, nImg : int, ico_size : int = 16)
    /* Create an image list and set it to the TreeView.
    Parameters :
        tv : Pointer to TreeView
        nImg : Number of images you want to have in the list.
        ico_size : Size of your image or icon. Default is 16 X 16 */

treeview_expand_all :: proc(tv : ^TreeView)  // Expand all nodes.
treeview_collapse_all :: proc(tv : ^TreeView) // Collapse all nodes
treeview_expand_node :: proc(tv : ^TreeView, node : ^TreeNode) // Expand only given node
treeview_collapse_node :: proc(tv : ^TreeView, node : ^TreeNode) // Collapse only given node.


//==================================================================TreeNode==================================================

TreeNode :: struct {   
    handle : HtreeItem,             // Handle of the tree view item. Mostly for internal use. 
    parent_node : ^TreeNode,        // Pointer to the parent node. If it's root item, parent_node is nil.
    image_index : int,              // Index of image list.
    sel_image_index : int,          // Index of selected image.
    child_count : int,              // Count of child nodes.
    text : string,                  // Text of the node.
    nodes : [dynamic]^TreeNode,     // List of child nodes.
    checked : bool,                 // If it's a node with check box, whether it is checked or not.
    fore_color : uint,              // Text color of node.
    back_color : uint,              // Back color of the text area of node.
} 

// Costructors
new_treenode :: proc(txt : string) -> TreeNode 
    // Parameter : txt = node's text

new_treenode :: proc(txt : string, img_indx, sel_img_indx : int) -> TreeNode
    /* Parameters :
        txt = node's text
        img_indx = index number of image list
        sel_img_indx = selected index number of image list */

new_treenode :: proc(txt : string, txt_clr : uint, back_clr : uint = def_back_clr) -> TreeNode
    /* Parameters :
        txt = node's text
        txt_clr = text color of this node
        back_clr = back ground color of this node */

new_treenode :: proc(txt : string, img_indx : int, sel_img_indx : int,  txt_clr : uint, back_clr : uint = def_back_clr) -> TreeNode
    /* Parameters :
        txt = node's text
        img_indx = index number of image list
        sel_img_indx = selected index number of image list 
        txt_clr = text color of this node
        back_clr = back ground color of this node */
        

// Example code------------------------------------------------

import ui "winforms"
MakeWindow :: proc() {       
    using ui
    
    frm = new_form(txt = "TreeView Example")    
    frm.font = new_font("Tahoma", 13)         
    frm.width = 700         
    create_form(&frm)

    tv = new_treeview(&frm)
    tv.has_checkboxes = true
    tv.back_color = 0xC6C6FF
    tv.fore_color = 0x008000
    tv.line_color = red
    create_treeview(&tv)
   
    // Let us create some tree nodes
    n1 := new_treenode("Asia", 0x0000FF) // Indentation will helps us to understand the parent child connection.
        n1_1 := new_treenode("India")
        n1_2 := new_treenode("China")
    n2 = new_treenode("Africa")
        n2_1 = new_treenode("South Africa")
        n2_2 := new_treenode("Sudan")

    treeview_add_node(&tv, &n1)                 // Adding n1 as the first root node.
        treeview_add_node(&tv, &n1_1, &n1)      // Adding n1_1 as the first child of n1
        treeview_add_node(&tv, &n1_2, &n1)
    treeview_add_node(&tv, &n2)
        treeview_add_node(&tv, &n2_1, &n2)
        treeview_add_node(&tv, &n2_2, &n2)     
  
    start_form()     
}







