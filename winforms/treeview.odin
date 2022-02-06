
/*
    Created on : 06-Feb-2022 7:36:35 PM
    Name : TreeView type
*/

package winforms


// Constants

// Constants End

TreeView :: struct {
    using control : Control,

}

//new_treeview :: proc{new_tv1, new_tv1}
@private tv_ctor :: proc(f : ^Form, x, y, w, h : int) -> TreeView {
    tv : TreeView
    tv.kind = .tree_view
    tv.parent = f
    tv.font = f.font
    tv.xpos = x
    tv.ypos = y
    tv.width = w
    tv.height = h
    tv._style = 0
    tv._ex_style = 0

    return tv
}
