
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
