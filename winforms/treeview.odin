

/*
    Created on : 06-Feb-2022 7:36:35 PM
    Name : TreeView type
*/

package winforms

import "core:runtime"
//import "core:slice"
//import "core:fmt"

g_node_id : int = 100
ICC_TREEVIEW_CLASSES :: 0x2
WcTreeViewClassW : wstring
TreeNodeArray :: distinct ^[dynamic]^TreeNode
NodeDisposeHandler :: proc(node : ^TreeNode)
NodeNotifyHandler :: proc(node : ^TreeNode)

// Constants =============================================

    //TreeNodeCollection ::
    TVITEMEXW :: struct {
        mask : u32,
        hItem : HtreeItem,
        state,
        stateMask : u32,
        pszText : wstring,
        cchTextMax,
        iImage,
        iSelectedImage ,
        cChildren : i32,
        lParam : Lparam,
        iIntegral : i32,
        uStateEx : u32,
        hwnd : Hwnd,
        iExpandedImage,
        iReserved : i32,
    }

    TVINSERTSTRUCT :: struct {
        hParent : HtreeItem,
        hInsertAfter : HtreeItem,
        itemEx : TVITEMEXW,
    }

    NMTVDISPINFOEXW :: struct {
        hdr : NMHDR,
        item : TVITEMEXW,
    }

    TVITEM :: struct {
        mask : u32,
        hItem : HtreeItem,
        state,
        stateMask : u32,
        pszText : wstring,
        cchTextMax,
        iImage,
        iSelectedImage ,
        cChildren : i32,
        lParam : Lparam,
    }

    NMTREEVIEW :: struct {
        hdr : NMHDR,
        action : u32,
        itemOld : TVITEM,
        itemNew : TVITEM,
        ptDrag : Point,
    }

    NMTVSTATEIMAGECHANGING :: struct {
        hdr : NMHDR,
        hti : HtreeItem,
        iOldStateImageIndex : i32,
        iNewStateImageIndex : i32,
    }

    TVITEMCHANGE :: struct {
        hdr : NMHDR,
        uChanged : u32,
        hItem : HtreeItem,
        uStateNew : u32,
        uStateOld : u32,
        lParam : Lparam,
    }

    NMTVCUSTOMDRAW :: struct {
        nmcd : NMCUSTOMDRAW,
        clrText : ColorRef,
        clrTextBk : ColorRef,
        iLevel : i32,
    }

// Constants
    TVS_HASBUTTONS :: 0x1
    TVS_HASLINES :: 0x2
    TVS_LINESATROOT :: 0x4
    TVS_EDITLABELS :: 0x8
    TVS_DISABLEDRAGDROP :: 0x10
    TVS_SHOWSELALWAYS :: 0x20
    TVS_RTLREADING :: 0x40
    TVS_NOTOOLTIPS :: 0x80
    TVS_CHECKBOXES :: 0x100
    TVS_TRACKSELECT :: 0x200
    TVS_SINGLEEXPAND :: 0x400
    TVS_INFOTIP :: 0x800
    TVS_FULLROWSELECT :: 0x1000
    TVS_NOSCROLL :: 0x2000
    TVS_NONEVENHEIGHT :: 0x4000
    TVS_NOHSCROLL :: 0x8000
    TVS_EX_NOSINGLECOLLAPSE :: 0x1

    TVIS_STATEIMAGEMASK :: 0xF000
    TVIS_USERMASK :: 0xF000

    TVI_ROOT :: HtreeItem(cast(uintptr)(U64MAX - 0x10000) + 1) // The +1 is needed. So add always +1 to this type of expressions.
    TVI_FIRST :: HtreeItem(cast(uintptr)(U64MAX - 0xffff) + 1)
    TVI_LAST :: HtreeItem(cast(uintptr)(U64MAX - 0xfffe) + 1)
    TVI_SORT :: HtreeItem(cast(uintptr)(U64MAX - 0xfffd) + 1)

    TVIF_CHILDREN :: 0x40
    TVIF_DI_SETITEM :: 0x1000
    TVIF_HANDLE :: 0x10
    TVIF_IMAGE :: 0x2
    TVIF_INTEGRAL :: 0x80
    TVIF_PARAM :: 0x4
    TVIF_SELECTEDIMAGE :: 0x20
    TVIF_STATE :: 0x8
    TVIF_TEXT :: 0x1

    TVE_COLLAPSE      :: 1
    TVE_EXPAND        :: 2
    TVE_TOGGLE        :: 3
    TVE_COLLAPSERESET :: 0x8000

    TVNA_ADD :: 1
    TVNA_ADDFIRST :: 2
    TVNA_ADDCHILD :: 3
    TVNA_ADDCHILDFIRST :: 4
    TVNA_INSERT :: 5

    TVIML_FLAG :: 0x00000020 | 0x00000001

    TV_FIRST :: 0x1100
    TVN_FIRST :: 4294966896
    TVM_DELETEITEM :: (TV_FIRST+1)
    TVM_EXPAND  :: TV_FIRST + 2
    TVM_INSERTITEMW :: (TV_FIRST + 50)
    TVM_SETIMAGELIST :: (TV_FIRST + 9)
    TVM_SETBKCOLOR :: (TV_FIRST + 29)
    TVM_SETTEXTCOLOR :: (TV_FIRST + 30)
    TVM_SETLINECOLOR :: (TV_FIRST + 40)

    TVN_KEYDOWN :: (TVN_FIRST-12)
    TVN_SINGLEEXPAND :: (TVN_FIRST-15)
    TVN_ITEMCHANGINGW ::  (TVN_FIRST-17)
    TVN_ITEMCHANGEDW  :: (TVN_FIRST-19)

    TVN_SELCHANGINGW :: (TVN_FIRST-50)
    TVN_SELCHANGEDW  :: (TVN_FIRST-51)
    TVN_GETDISPINFOW ::(TVN_FIRST-52)
    TVN_ITEMEXPANDINGW :: (TVN_FIRST-54)
    TVN_ITEMEXPANDEDW :: (TVN_FIRST-55)
    TVN_DELETEITEMW :: (TVN_FIRST-58)
    TVN_BEGINLABELEDITW :: (TVN_FIRST-59)
    TVN_ENDLABELEDITW :: (TVN_FIRST-60)

    NM_TVSTATEIMAGECHANGING :: 4294967272 //(NM_FIRST-24) // it is equal to (max(u32) - 24) + 1

    TVC_UNKNOWN  :: 0x0
    TVC_BYMOUSE :: 0x1
    TVC_BYKEYBOARD :: 0x2

// End Constants


    // ItemMask :: enum {
    //     Text = 0x1,
    //     Image = 0x2,
    //     Param = 0x4,
    //     State = 0x8,
    //     Handle = 0x10,
    //     Sel_Image = 0x20,
    //     Children = 0x40,
    //     Di_Set_Item = 0x1000,
    // }

    ChildData :: enum {Child_Auto = -2, Child_Callback = -1, Zero = 0, One = 1,}
    NodeOp :: enum {Add_Node, Insert_Node, Add_Child, Insert_Child,}


// Constants End

TreeView :: struct
{
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
    image_list : HimageList,
    line_color : uint,


    _last_item_hw : HtreeItem,
    _item_count : int,
    _unique_item_id : int,
    _node_checked : bool,
    _node_clr_change : bool,

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

TreeNode :: struct {
    handle : HtreeItem,
    parent_node : ^TreeNode,
    image_index : int,
    sel_image_index : int,
    child_count : int,
    text : string,
    nodes : [dynamic]^TreeNode,
    checked : bool,
    fore_color : uint,
    back_color : uint,
    _dispose : NodeDisposeHandler,
    _is_created : bool,
    _tree_hwnd : Hwnd,
    _index : int,
    _node_id : int,
    _node_count : int,
}

new_treeview :: proc{new_tv1, new_tv2}

@private tv_ctor :: proc(f : ^Form, x, y, w, h : int) -> TreeView
{
    if WcTreeViewClassW == nil {
        WcTreeViewClassW = to_wstring("SysTreeView32")
        app.iccx.dwIcc = ICC_TREEVIEW_CLASSES
        InitCommonControlsEx(&app.iccx)
    }
    tv : TreeView
    tv.kind = .Tree_View
    tv.parent = f
    tv.font = f.font
    tv._unique_item_id = 100
    tv.back_color = app.clr_white
    tv.fore_color = app.clr_black
    tv.line_color = app.clr_black
    tv.xpos = x
    tv.ypos = y
    tv.width = w
    tv.height = h           // By default a treeview has buttons and lines. Every user might need that.
    tv._style = WS_BORDER | WS_CHILD | WS_VISIBLE | TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_DISABLEDRAGDROP
    tv._ex_style = 0
    tv._cls_name = WcTreeViewClassW
    tv._before_creation = cast(CreateDelegate) tv_before_creation
	tv._after_creation = cast(CreateDelegate) tv_after_creation
    return tv
}

@private new_tv1 :: proc(parent : ^Form) -> TreeView
{
    tv := tv_ctor(parent, 10, 10, 200, 250)
    return tv
}

@private new_tv2 :: proc(parent : ^Form, x, y, w, h : int) -> TreeView
{
    tv := tv_ctor(parent, x, y, w, h)
    return tv
}



// Create new tree view node.
new_treenode :: proc{node_ctor1, node_ctor2, node_ctor3, node_ctor4}
@private treenode_ctor :: proc(txt : string, img : int = -1, simg : int = -1, fclr : uint = def_fore_clr, bk_clr : uint = def_back_clr) -> TreeNode
{
    tn : TreeNode
    tn.image_index = img
    tn.sel_image_index = simg
    tn.text = txt
    tn._dispose = dispose_node
    tn.fore_color = fclr
    tn.back_color = bk_clr
    return tn
}

@private node_ctor1 :: proc(txt : string) -> TreeNode { return treenode_ctor(txt)}

@private node_ctor2 :: proc(txt : string, img_indx, sel_img_indx : int) -> TreeNode {
    return treenode_ctor(txt, img_indx, sel_img_indx)
}

@private node_ctor3 :: proc(txt : string, txt_clr : uint, back_clr : uint = def_back_clr) -> TreeNode {
    return treenode_ctor(txt, -1, -1, txt_clr, back_clr)
}

@private node_ctor4 :: proc(txt : string, img_indx : int, sel_img_indx : int,  txt_clr : uint, back_clr : uint = def_back_clr) -> TreeNode {
    return treenode_ctor(txt, img_indx, sel_img_indx, txt_clr, back_clr)
}

// Expand all nodes.
treeview_expand_all :: proc(tv : ^TreeView) {
    for node in tv.nodes {
        SendMessage(tv.handle, CM_TVNODEEXPAND, Wparam(TVE_EXPAND), direct_cast(node, Lparam))
    }
}

// Collapse all nodes
treeview_collapse_all :: proc(tv : ^TreeView) {
    for node in tv.nodes {
        SendMessage(tv.handle, CM_TVNODEEXPAND, Wparam(TVE_COLLAPSE), direct_cast(node, Lparam))
    }
}

treeview_expand_node :: proc(tv : ^TreeView, node : ^TreeNode) {
    SendMessage(tv.handle, CM_TVNODEEXPAND, Wparam(TVE_EXPAND), direct_cast(node, Lparam))
}

treeview_collapse_node :: proc(tv : ^TreeView, node : ^TreeNode) {
    SendMessage(tv.handle, CM_TVNODEEXPAND, Wparam(TVE_COLLAPSE), direct_cast(node, Lparam))
}


// Adds a new root node to tree view.
treeview_add_node :: proc(tv : ^TreeView, node : ^TreeNode) {
    tv_addnode_internal(tv, node, NodeOp.Add_Node)
}

// Adds the given root nodes into treeview.
treeview_add_nodes :: proc(tv : ^TreeView, nodes : ..^TreeNode ) {
    for node in nodes {
        tv_addnode_internal(tv, node, NodeOp.Add_Node)
    }
}

// Inserts given root node to given index.
treeview_insert_node :: proc(tv : ^TreeView, node : ^TreeNode, index : int) {
    tv_addnode_internal(tv, node, NodeOp.Insert_Node, index)
}

// Adds a child node to given parent node.
treeview_add_child_node :: proc(tv : ^TreeView, node : ^TreeNode, parent: ^TreeNode) {
    tv_addnode_internal(tv, node, NodeOp.Add_Child, -1, parent)
}

// Adds given child nodes to given parent node.
treeview_add_child_nodes :: proc(tv : ^TreeView, parent: ^TreeNode, nodes : ..^TreeNode) {
    for node in nodes {
        tv_addnode_internal(tv, node, NodeOp.Add_Child, -1, parent)
    }
}

// Iserts a child node to given parent node at given index
treeview_insert_child_node :: proc(tv : ^TreeView, node : ^TreeNode, parent: ^TreeNode, index: int) {
    tv_addnode_internal(tv, node, NodeOp.Insert_Child, index, parent)
}



@private make_tvitem :: proc(tv: ^TreeView, node: ^TreeNode) -> TVITEMEXW {
    tvi : TVITEMEXW
    tvi.mask = TVIF_TEXT | TVIF_PARAM
    tvi.pszText = to_wstring(node.text)
    tvi.cchTextMax = i32(len(node.text))
    tvi.iImage = i32(node.image_index)
    tvi.iSelectedImage = i32(node.sel_image_index)
    tvi.stateMask = TVIS_USERMASK
    // tvi.lParam = direct_cast(node, Lparam)
    if node.image_index > -1 do tvi.mask |= TVIF_IMAGE
    if node.sel_image_index > -1 do tvi.mask |= TVIF_SELECTEDIMAGE
    if node.fore_color != def_fore_clr do tv._node_clr_change = true
    return tvi
}

// This function handles add or insert nodes & child nodes.
@private tv_addnode_internal :: proc(tv: ^TreeView, node: ^TreeNode, nop: NodeOp, pos: int = -1, pnode: ^TreeNode = nil) {
    if !tv._is_created do return
    node._is_created = true
    // node._notify_handler = self.notify_parent
    node._tree_hwnd = tv.handle
    node._index = tv._item_count
    node._node_id = tv._unique_item_id // We can identify any node with this
    is_main_node := false // A flag var to identify some boolean condition.
    err_msg := "Can't Add Node"
    tvi := make_tvitem(tv, node)
    tis : TVINSERTSTRUCT
    tis.itemEx = tvi
    tis.itemEx.lParam = direct_cast(rawptr(node), Lparam)

    switch nop {
        case .Add_Node:
            tis.hParent = TVI_ROOT
            tis.hInsertAfter = tv.nodes[tv._item_count - 1].handle if tv._item_count > 0 else TVI_FIRST
            is_main_node = true
        case .Insert_Node:
            tis.hParent = TVI_ROOT
            tis.hInsertAfter = TVI_FIRST if pos == 0 else tv.nodes[pos - 1].handle
            is_main_node = true
            err_msg = "Can't Insert Node"
        case .Add_Child:
            tis.hInsertAfter = TVI_LAST
            tis.hParent = pnode.handle
            node.parent_node = pnode
            append(&pnode.nodes, node)
            pnode._node_count += 1
            err_msg = "Can't Add Child Node"
        case .Insert_Child:
            tis.hParent = pnode.handle
            tis.hInsertAfter = TVI_FIRST if pos == 0 else pnode.nodes[pos - 1].handle
            node.parent_node = pnode
            append(&pnode.nodes, node)
            pnode._node_count += 1
            err_msg = "Can't Insert Child Node"
    }

    lres := SendMessage(tv.handle, TVM_INSERTITEMW, 0,  direct_cast(&tis, Lparam) )
    if lres != 0 {
        hItem := direct_cast(lres, HtreeItem)
        node.handle = hItem
        tv._unique_item_id += 1
    } else {
        print(err_msg)
    }

    if is_main_node {
        append(&tv.nodes, node)
        tv._item_count += 1
    }

}

// delete a node from treeview
treeview_delete_node :: proc(tv : ^TreeView, node : ^TreeNode) {
    //indx : int
    if node.parent_node == nil {  // it's a top level node
        SendMessage(tv.handle, TVM_DELETEITEM, 0, direct_cast(node.handle, Lparam))
        indx, _ := find_index(tv.nodes, node.handle )
        node._dispose(node)
        ordered_remove(&tv.nodes, indx) }
    else {   // It's a child node.
        SendMessage(tv.handle, TVM_DELETEITEM, 0, direct_cast(node.handle, Lparam))
        indx, _ := find_index(node.parent_node.nodes, node.handle )
        node._dispose(node)
        ordered_remove(&node.parent_node.nodes, indx)
    }
}

// Sometimes we need to remove a node from it's parent's node list, we need to find the index of that node.
@private find_index :: proc(list : [dynamic]^TreeNode, hti : HtreeItem) ->(idx : int, ok : bool) {
    for node, i in list { if node.handle == hti { return i, true}  }
    return -1, false
}

// Every node must dispose itself and clean the momory it posses.
// This must be get called either at program end or when user delete a node.
@private dispose_node :: proc(n : ^TreeNode) {
    //print("Going to delete nodes of ", n.text)
    for child in n.nodes {child._dispose(child)}
    delete(n.nodes)
}

// Apply colors to TreeNode
treeview_set_node_color :: proc(tv : ^TreeView, node : ^TreeNode) {
    tv._node_clr_change = true
    if tv._is_created do InvalidateRect(tv.handle, nil, true)
}

@private treeview_set_back_color :: proc(tv : ^Control, clr : uint) {
    tv.back_color = clr
    cref := get_color_ref(clr)
    SendMessage(tv.handle, TVM_SETBKCOLOR, 0, direct_cast(cref, Lparam))
}

treeview_set_line_color :: proc(tv : ^TreeView, clr : uint) {
    if tv._is_created {
        tv.line_color = clr
        cref := get_color_ref(tv.line_color)
        SendMessage(tv.handle, TVM_SETLINECOLOR, 0, direct_cast(cref, Lparam) )
    }
}

// Set an image list for tree view
treeview_set_image_list :: proc(tv : ^TreeView, himl : HimageList) {
    SendMessage(tv.handle, TVM_SETIMAGELIST, 0, direct_cast(himl, Lparam))// TVSIL_NORMAL = 0
}

treeview_create_image_list :: proc(tv : ^TreeView, nImg : int, ico_size : int = 16) {
    isize := i32(ico_size)
    tv.image_list = ImageList_Create(isize, isize, TVIML_FLAG, i32(nImg), 0 )
    SendMessage(tv.handle, TVM_SETIMAGELIST, 0, direct_cast(tv.image_list, Lparam))
}


@private treenode_color :: proc( lpm : Lparam) -> Lresult {
    //@static x : int
    pn := direct_cast(lpm, ^NMTVCUSTOMDRAW)
    switch pn.nmcd.dwDrawStage {
        case CDDS_PREPAINT :
            return CDRF_NOTIFYITEMDRAW
        case CDDS_ITEMPREPAINT :
            nd := direct_cast(pn.nmcd.lItemParam, ^TreeNode)
            if nd.fore_color != def_fore_clr {
                pn.clrText = get_color_ref(nd.fore_color)
            }
            if nd.back_color != def_back_clr {
                pn.clrTextBk = get_color_ref(nd.back_color)
            }
            return CDRF_DODEFAULT

    }
    return CDRF_DODEFAULT
}


@private add_style :: proc(tv : ^TreeView, stls : ..Dword) { for i in stls { if (tv._style & i) != i do tv._style |= i } }

@private tv_adjust_styles :: proc(tv : ^TreeView) {
    if tv.no_lines do tv._style ~= TVS_HASLINES
    if tv.no_buttons do tv._style ~= TVS_HASBUTTONS
    if tv.has_checkboxes do add_style(tv, TVS_CHECKBOXES)
    if tv.full_row_select do add_style(tv, TVS_FULLROWSELECT)
    if tv.editable do add_style(tv, TVS_EDITLABELS )
    if tv.show_selection do add_style(tv, TVS_SHOWSELALWAYS)
    if tv.hot_tracking do add_style(tv, TVS_TRACKSELECT )

    if tv.no_buttons && tv.no_lines do tv._style ~= TVS_LINESATROOT
}

@private tv_before_creation :: proc(tv : ^TreeView) {tv_adjust_styles(tv)}

@private tv_after_creation :: proc(tv : ^TreeView) {
	set_subclass(tv, tv_wnd_proc)
    setfont_internal(tv)
    if tv.back_color != app.clr_white {
        cref := get_color_ref(tv.back_color)
        SendMessage(tv.handle, TVM_SETBKCOLOR, 0, direct_cast(cref, Lparam) )
    }
    if tv.fore_color != app.clr_black {
        cref := get_color_ref(tv.fore_color)
        SendMessage(tv.handle, TVM_SETTEXTCOLOR, 0, direct_cast(cref, Lparam) )
    }
    if tv.line_color != app.clr_black  {
        cref := get_color_ref(tv.line_color)
        SendMessage(tv.handle, TVM_SETLINECOLOR, 0, direct_cast(cref, Lparam) )
    }
}

@private tv_finalize :: proc(tv: ^TreeView, scid: UintPtr) {
    for n in tv.nodes { n._dispose(n)} // looping thru the child nodes and delete them.
    delete(tv.nodes)                  // delete all the top level nodes.
    ImageList_Destroy(tv.image_list)
    RemoveWindowSubclass(tv.handle, tv_wnd_proc, scid)
}

@private tv_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {
    context = runtime.default_context()
    tv := control_cast(TreeView, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY :
            if tv.on_destroy != nil {
                ea := new_event_args()
                tv.on_destroy(tv, &ea)
            }
            tv_finalize(tv, sc_id)


        case CM_TVNODEEXPAND :
            node := direct_cast(lp, ^TreeNode)
            SendMessage(tv.handle, TVM_EXPAND, wp, direct_cast(node.handle, Lparam))
            if node.child_count > 0 {
                for n in node.nodes {
                    SendMessage(tv.handle, CM_TVNODEEXPAND, wp, direct_cast(n, Lparam))
                }
            }
           // return 0

        case CM_NOTIFY :
            nm := direct_cast(lp, ^NMHDR)
            switch nm.code
            {
                case TVN_DELETEITEMW :
                    if tv.node_deleted != nil
                    {
                        // nmtv := direct_cast(lp, ^NMTREEVIEW)
                        // tn := direct_cast(nmtv.itemOld.lParam, ^TreeNode)
                        // ptf("%s's array deleted now\n", tn.text)
                        ea := new_event_args()
                        tv.node_deleted(tv, &ea)
                    }
                case TVN_SELCHANGINGW :
                    if tv.before_select != nil {
                        nmtv := direct_cast(lp, ^NMTREEVIEW)
                        tea := new_tree_event_args(nmtv)
                        tv.before_select(tv, &tea)
                    }
                case TVN_SELCHANGEDW :
                    nmtv := direct_cast(lp, ^NMTREEVIEW)
                    tea := new_tree_event_args(nmtv)
                    tv.selected_node = tea.node
                    if tv.after_select != nil { tv.after_select(tv, &tea) }

                case NM_TVSTATEIMAGECHANGING :
                    //print("check NM_TVSTATEIMAGECHANGING")
                    tvsic := direct_cast(lp, ^NMTVSTATEIMAGECHANGING)
                    //tea := new_tree_event_args(tvsic)

                    if tvsic.iOldStateImageIndex == 1 {
                        tv._node_checked = true }
                    else if tvsic.iOldStateImageIndex == 2 {
                        tv._node_checked = false
                    }

                    // print("chk new - ", tvsic.iNewStateImageIndex)
                    //print("chk action - ", tvsic.iNewStateImageIndex)

                case TVN_ITEMCHANGINGW :
                    if tv.before_checked != nil {
                        tvic := direct_cast(lp, ^TVITEMCHANGE)
                        tea := new_tree_event_args(tvic)
                        if tv._node_checked do tea.node.checked = true
                        tv.before_checked(tv, &tea)
                    }

                case TVN_ITEMCHANGEDW :
                    if tv.after_checked != nil {
                        tvic := direct_cast(lp, ^TVITEMCHANGE)
                        tea := new_tree_event_args(tvic)
                        if tv._node_checked do tea.node.checked = true
                        tv.after_checked(tv, &tea)
                    }

                case TVN_ITEMEXPANDINGW :
                    nmtv := direct_cast(lp, ^NMTREEVIEW)
                    switch nmtv.action {
                        case 1 :
                            if tv.before_collapse != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.before_collapse(tv, &tea)
                            }
                        case 2 :
                            if tv.before_expand != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.before_expand(tv, &tea)
                            }
                    }

                case TVN_ITEMEXPANDEDW :
                    nmtv := direct_cast(lp, ^NMTREEVIEW)
                    switch nmtv.action {
                        case 1 :
                            if tv.after_collapse != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.after_collapse(tv, &tea)
                            }
                        case 2 :
                            if tv.after_expand != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.after_expand(tv, &tea)
                            }
                    }

                case NM_CUSTOMDRAW :
                    if tv._node_clr_change {
                        return treenode_color( lp)
                    }



                case :
                    //print("else case - ", nm.code)
               // case 4294966879 :
                 //   print("4294966879 rcvd")
               // case : alert(fmt.tprintf("NMHDR.Code - %d", nm.code)) 4294967279




            }
    }
    return DefSubclassProc(hw, msg, wp, lp)
}


