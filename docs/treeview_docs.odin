
/*
	Created on : 19-Feb-2022 15:56 3:56:53 PM
		Name : Treeview Documentation
		*/

TreeView :: struct {
    using control : Control,
    no_lines : bool,
    no_buttons : bool,
    has_checkboxes : bool,
    full_row_select : bool,
    editable : bool,
    show_selection : bool,
    hot_tracking : bool,
    selected_node : ^TreeNode,
    nodes : [dynamic]^TreeNode,
    root_item : TreeNode,
    image_list : HimageList,
    line_color : uint,
    

   // Events

    begin_edit,
    end_edit : EventHandler,
    node_deleted : EventHandler,
    before_checked,
    after_checked,
    before_select,
    after_select,
    before_expand,
    after_expand,
    before_collapse,
    after_collapse : TreeEventHandler,
}