

/*
    Created on : 06-Feb-2022 7:36:35 PM
    Name : TreeView type
*/

package winforms

import "base:runtime"
//import "core:slice"
//import "core:fmt"

g_node_id : int = 100
ICC_TREEVIEW_CLASSES :: 0x2
WcTreeViewClassW : wstring = L("SysTreeView32")
tvcount : int = 0
TreeNodeArray :: distinct ^[dynamic]^TreeNode
NodeDisposeHandler :: proc(node : ^TreeNode)
NodeNotifyHandler :: proc(node : ^TreeNode)

// Constants =============================================

    //TreeNodeCollection ::
    TVITEMEXW :: struct
    {
        mask : u32,
        hItem : HTREEITEM,
        state,
        stateMask : u32,
        pszText : wstring,
        cchTextMax,
        iImage,
        iSelectedImage ,
        cChildren : i32,
        lParam : LPARAM,
        iIntegral : i32,
        uStateEx : u32,
        hwnd : HWND,
        iExpandedImage,
        iReserved : i32,
    }

    TVINSERTSTRUCT :: struct
    {
        hParent : HTREEITEM,
        hInsertAfter : HTREEITEM,
        itemEx : TVITEMEXW,
    }

    NMTVDISPINFOEXW :: struct
    {
        hdr : NMHDR,
        item : TVITEMEXW,
    }

    TVITEM :: struct
    {
        mask : u32,
        hItem : HTREEITEM,
        state,
        stateMask : u32,
        pszText : wstring,
        cchTextMax,
        iImage,
        iSelectedImage ,
        cChildren : i32,
        lParam : LPARAM,
    }

    NMTREEVIEW :: struct
    {
        hdr : NMHDR,
        action : u32,
        itemOld : TVITEM,
        itemNew : TVITEM,
        ptDrag : POINT,
    }

    NMTVSTATEIMAGECHANGING :: struct
    {
        hdr : NMHDR,
        hti : HTREEITEM,
        iOldStateImageIndex : i32,
        iNewStateImageIndex : i32,
    }

    TVITEMCHANGE :: struct
    {
        hdr : NMHDR,
        uChanged : u32,
        hItem : HTREEITEM,
        uStateNew : u32,
        uStateOld : u32,
        lParam : LPARAM,
    }

    NMTVCUSTOMDRAW :: struct
    {
        nmcd : NMCUSTOMDRAW,
        clrText : COLORREF,
        clrTextBk : COLORREF,
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

    // The +1 is needed. Add always +1 to this type of expressions.
    TVI_ROOT :: HTREEITEM(cast(UINT_PTR)(U64MAX - 0x10000) + 1) 
    TVI_FIRST :: HTREEITEM(cast(UINT_PTR)(U64MAX - 0xffff) + 1)
    TVI_LAST :: HTREEITEM(cast(UINT_PTR)(U64MAX - 0xfffe) + 1)
    TVI_SORT :: HTREEITEM(cast(UINT_PTR)(U64MAX - 0xfffd) + 1)

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
    //     HANDLE = 0x10,
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
    noLines : bool,
    noButtons : bool,
    hasCheckBoxes : bool,
    fullRowSelect : bool,
    editable : bool,
    showSelection : bool,
    hotTracking : bool,
    selectedNode : ^TreeNode,
    nodes : [dynamic]^TreeNode,
    imageList : HIMAGELIST,
    lineColor : uint,

    _lastItemHwnd : HTREEITEM,
    _itemCount : int,
    _uniqItemID : int,
    _nodeChecked : bool,
    _nodeClrChange : bool,

    onBeginEdit,
    onEndEdit : EventHandler,
    onNodeDeleted : EventHandler,
    onBeforeChecked,
    onAfterChecked,
    onBeforeSelect,
    onAfterSelect,
    onBeforeExpand,
    onAfterExpand,
    onBeforeCollapse,
    onAfterCollapse : TreeEventHandler,
}

TreeNode :: struct
{
    handle : HTREEITEM,
    parentNode : ^TreeNode,
    imageIndex : int,
    selImageIndex : int,
    childCount : int,
    text : string,
    nodes : [dynamic]^TreeNode,
    checked : bool,
    foreColor : uint,
    backColor : uint,
    _dispose : NodeDisposeHandler,
    _isCreated : bool,
    _treeHwnd : HWND,
    _index : int,
    _nodeID : int,
    _nodeCount : int,
}

new_treeview :: proc{new_tv1, new_tv2, new_tv3}

@private tv_ctor :: proc(f : ^Form, x, y, w, h : int) -> ^TreeView
{
    if tvcount == 0 {
        app.iccx.dwIcc = ICC_TREEVIEW_CLASSES
        InitCommonControlsEx(&app.iccx)
    }
    this := new(TreeView)
    tvcount += 1
    this.kind = .Tree_View
    this.parent = f
    this.font = f.font
    this._uniqItemID = 100
    this.backColor = app.clrWhite
    this.foreColor = app.clrBlack
    this.lineColor = app.clrBlack
    this.xpos = x
    this.ypos = y
    this.width = w
    this.height = h           // By default a treeview has buttons and lines. Every user might need that.
    this._style = WS_BORDER | WS_CHILD | WS_VISIBLE | TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_DISABLEDRAGDROP
    this._exStyle = 0
    this._clsName = WcTreeViewClassW
    this._fp_beforeCreation = cast(CreateDelegate) tv_before_creation
	this._fp_afterCreation = cast(CreateDelegate) tv_after_creation
    append(&f._controls, this)
    return this
}

@private new_tv1 :: proc(parent : ^Form, autoc: b8 = false) -> ^TreeView
{
    tv := tv_ctor(parent, 10, 10, 200, 250)
    if autoc do create_control(tv)
    return tv
}

@private new_tv2 :: proc(parent : ^Form, x, y : int, autoc: b8 = false) -> ^TreeView
{
    tv := tv_ctor(parent, x, y, 200, 250)
    if autoc do create_control(tv)
    return tv
}

@private new_tv3 :: proc(parent : ^Form, x, y, w, h : int, autoc: b8 = false) -> ^TreeView
{
    tv := tv_ctor(parent, x, y, w, h)
    if autoc do create_control(tv)
    return tv
}

// Create new tree view node.
new_treenode :: proc{node_ctor1, node_ctor2, node_ctor3, node_ctor4}

@private treenode_ctor :: proc(txt : string, img : int = -1, simg : int = -1,
                                 fclr : uint = def_fore_clr, bk_clr : uint = def_back_clr) -> ^TreeNode
{
    tn := new(TreeNode)
    tn.imageIndex = img
    tn.selImageIndex = simg
    tn.text = txt
    tn._dispose = dispose_node
    tn.foreColor = fclr
    tn.backColor = bk_clr
    return tn
}

@private node_ctor1 :: proc(txt : string) -> ^TreeNode { return treenode_ctor(txt)}

@private node_ctor2 :: proc(txt : string, img_indx, sel_img_indx : int) -> ^TreeNode
{
    return treenode_ctor(txt, img_indx, sel_img_indx)
}

@private node_ctor3 :: proc(txt : string, txt_clr : uint, back_clr : uint = def_back_clr) -> ^TreeNode
{
    return treenode_ctor(txt, -1, -1, txt_clr, back_clr)
}

@private node_ctor4 :: proc(txt : string, img_indx : int, sel_img_indx : int,
                            txt_clr : uint, back_clr : uint = def_back_clr) -> ^TreeNode
{
    return treenode_ctor(txt, img_indx, sel_img_indx, txt_clr, back_clr)
}

// Expand all nodes.
treeview_expand_all :: proc(tv : ^TreeView)
{
    for node in tv.nodes {
        SendMessage(tv.handle, CM_TVNODEEXPAND, WPARAM(TVE_EXPAND), dir_cast(node, LPARAM))
    }
}

// Collapse all nodes
treeview_collapse_all :: proc(tv : ^TreeView)
{
    for node in tv.nodes {
        SendMessage(tv.handle, CM_TVNODEEXPAND, WPARAM(TVE_COLLAPSE), dir_cast(node, LPARAM))
    }
}

treeview_expand_node :: proc(tv : ^TreeView, node : ^TreeNode)
{
    SendMessage(tv.handle, CM_TVNODEEXPAND, WPARAM(TVE_EXPAND), dir_cast(node, LPARAM))
}

treeview_collapse_node :: proc(tv : ^TreeView, node : ^TreeNode)
{
    SendMessage(tv.handle, CM_TVNODEEXPAND, WPARAM(TVE_COLLAPSE), dir_cast(node, LPARAM))
}


// Adds a new root node to tree view.
treeview_add_node :: proc(tv : ^TreeView, node : ^TreeNode)
{
    tv_addnode_internal(tv, node, NodeOp.Add_Node)
}

// Adds the given root nodes into treeview.
treeview_add_nodes :: proc{treeview_add_nodes1, treeview_add_nodes2}

treeview_add_nodes1 :: proc(tv : ^TreeView, nodes : ..^TreeNode )
{
    for node in nodes {
        tv_addnode_internal(tv, node, NodeOp.Add_Node)
    }
}

treeview_add_nodes2 :: proc(tv : ^TreeView, nodetexts : ..string )
{
    for txt in nodetexts {
        node:= new_treenode(txt)
        tv_addnode_internal(tv, node, NodeOp.Add_Node)
    }
}

// Inserts given root node to given index.
treeview_insert_node :: proc(tv : ^TreeView, node : ^TreeNode, index : int)
{
    tv_addnode_internal(tv, node, NodeOp.Insert_Node, index)
}

// Adds a child node to given parent node.
treeview_add_child_node :: proc(tv : ^TreeView, node : ^TreeNode, parent: ^TreeNode)
{
    tv_addnode_internal(tv, node, NodeOp.Add_Child, -1, parent)
}

// Adds given child nodes to given parent node.
treeview_add_childnodes :: proc{treeview_add_child_nodes1,
                                treeview_add_child_nodes2,
                                treeview_add_child_nodes3}

treeview_add_child_nodes1 :: proc(tv : ^TreeView, parent: ^TreeNode, nodes : ..^TreeNode)
{
    for node in nodes {
        tv_addnode_internal(tv, node, NodeOp.Add_Child, -1, parent)
    }
}

treeview_add_child_nodes2 :: proc(tv : ^TreeView, parent: ^TreeNode, nodetexts : ..string)
{
    for txt in nodetexts {
        node:= new_treenode(txt)
        tv_addnode_internal(tv, node, NodeOp.Add_Child, -1, parent)
    }
}

treeview_add_child_nodes3 :: proc(tv : ^TreeView, parentIndex: int, nodetexts : ..string)
{
    if parentIndex < len(tv.nodes)
    {
       parent := tv.nodes[parentIndex]
        for txt in nodetexts
        {
            node:= new_treenode(txt)
            tv_addnode_internal(tv, node, NodeOp.Add_Child, -1, parent)
        }
    }
    else {
        print("Error: Parent index is bigger that node count")
    }
}

// Iserts a child node to given parent node at given index
treeview_insert_child_node :: proc(tv : ^TreeView, node : ^TreeNode, parent: ^TreeNode, index: int)
{
    tv_addnode_internal(tv, node, NodeOp.Insert_Child, index, parent)
}

@private make_tvitem :: proc(tv: ^TreeView, node: ^TreeNode) -> TVITEMEXW
{
    tvi : TVITEMEXW
    tvi.mask = TVIF_TEXT | TVIF_PARAM
    tvi.pszText = to_wstring(node.text, context.allocator)
    tvi.cchTextMax = i32(len(node.text))
    tvi.iImage = i32(node.imageIndex)
    tvi.iSelectedImage = i32(node.selImageIndex)
    tvi.stateMask = TVIS_USERMASK
    // tvi.lParam = dir_cast(node, LPARAM)
    if node.imageIndex > -1 do tvi.mask |= TVIF_IMAGE
    if node.selImageIndex > -1 do tvi.mask |= TVIF_SELECTEDIMAGE
    if node.foreColor != def_fore_clr do tv._nodeClrChange = true
    return tvi
}

// This function handles add or insert nodes & child nodes.
@private tv_addnode_internal :: proc(tv: ^TreeView, node: ^TreeNode, nop: NodeOp,
                                        pos: int = -1, pnode: ^TreeNode = nil)
{
    if !tv._isCreated do return
    node._isCreated = true
    // node._notify_handler = self.notify_parent
    node._treeHwnd = tv.handle
    node._index = tv._itemCount
    node._nodeID = tv._uniqItemID // We can identify any node with this
    is_main_node := false // A flag var to identify some boolean condition.
    err_msg := "Can't Add Node"
    tvi := make_tvitem(tv, node)
    tis : TVINSERTSTRUCT
    tis.itemEx = tvi
    tis.itemEx.lParam = dir_cast(rawptr(node), LPARAM)

    switch nop {
        case .Add_Node:
            tis.hParent = TVI_ROOT
            tis.hInsertAfter = tv.nodes[tv._itemCount - 1].handle if tv._itemCount > 0 else TVI_FIRST
            is_main_node = true
        case .Insert_Node:
            tis.hParent = TVI_ROOT
            tis.hInsertAfter = TVI_FIRST if pos == 0 else tv.nodes[pos - 1].handle
            is_main_node = true
            err_msg = "Can't Insert Node"
        case .Add_Child:
            tis.hInsertAfter = TVI_LAST
            tis.hParent = pnode.handle
            node.parentNode = pnode
            append(&pnode.nodes, node)
            pnode._nodeCount += 1
            err_msg = "Can't Add Child Node"
        case .Insert_Child:
            tis.hParent = pnode.handle
            tis.hInsertAfter = TVI_FIRST if pos == 0 else pnode.nodes[pos - 1].handle
            node.parentNode = pnode
            append(&pnode.nodes, node)
            pnode._nodeCount += 1
            err_msg = "Can't Insert Child Node"
    }

    lres := SendMessage(tv.handle, TVM_INSERTITEMW, 0,  dir_cast(&tis, LPARAM) )
    free(tvi.pszText)
    if lres != 0 {
        hItem := dir_cast(lres, HTREEITEM)
        node.handle = hItem
        tv._uniqItemID += 1
    } else {
        print(err_msg)
    }

    if is_main_node {
        append(&tv.nodes, node)
        tv._itemCount += 1
    }
}

// delete a node from treeview
treeview_delete_node :: proc(tv : ^TreeView, node : ^TreeNode)
{
    //indx : int
    if node.parentNode == nil {  // it's a top level node
        SendMessage(tv.handle, TVM_DELETEITEM, 0, dir_cast(node.handle, LPARAM))
        indx, _ := find_index(tv.nodes, node.handle )
        node._dispose(node)
        ordered_remove(&tv.nodes, indx) }
    else {   // It's a child node.
        SendMessage(tv.handle, TVM_DELETEITEM, 0, dir_cast(node.handle, LPARAM))
        indx, _ := find_index(node.parentNode.nodes, node.handle )
        node._dispose(node)
        ordered_remove(&node.parentNode.nodes, indx)
    }
}

// Sometimes we need to remove a node from it's parent's node list, we need to find the index of that node.
@private find_index :: proc(list : [dynamic]^TreeNode, hti : HTREEITEM) ->(idx : int, ok : bool)
{
    for node, i in list { if node.handle == hti { return i, true}  }
    return -1, false
}

// Every node must dispose itself and clean the momory it posses.
// This must be get called either at program end or when user delete a node.
@private dispose_node :: proc(n : ^TreeNode)
{
    //print("Going to delete nodes of ", n.text)
    for child in n.nodes {child._dispose(child)}
    delete(n.nodes)
    free(n)
}

// Apply colors to TreeNode
treeview_set_node_color :: proc(tv : ^TreeView, node : ^TreeNode)
{
    tv._nodeClrChange = true
    if tv._isCreated do InvalidateRect(tv.handle, nil, true)
}

@private treeview_set_back_color :: proc(tv : ^Control, clr : uint)
{
    tv.backColor = clr
    cref := get_color_ref(clr)
    SendMessage(tv.handle, TVM_SETBKCOLOR, 0, dir_cast(cref, LPARAM))
}

treeview_set_line_color :: proc(tv : ^TreeView, clr : uint)
{
    if tv._isCreated {
        tv.lineColor = clr
        cref := get_color_ref(tv.lineColor)
        SendMessage(tv.handle, TVM_SETLINECOLOR, 0, dir_cast(cref, LPARAM) )
    }
}

// Set an image list for tree view
treeview_set_image_list :: proc(tv : ^TreeView, himl : HIMAGELIST)
{
    SendMessage(tv.handle, TVM_SETIMAGELIST, 0, dir_cast(himl, LPARAM))// TVSIL_NORMAL = 0
}

treeview_create_image_list :: proc(tv : ^TreeView, nImg : int, ico_size : int = 16)
{
    isize := i32(ico_size)
    tv.imageList = ImageList_Create(isize, isize, TVIML_FLAG, i32(nImg), 0 )
    SendMessage(tv.handle, TVM_SETIMAGELIST, 0, dir_cast(tv.imageList, LPARAM))
}

@private treenode_color :: proc( lpm : LPARAM) -> LRESULT
{
    //@static x : int
    pn := dir_cast(lpm, ^NMTVCUSTOMDRAW)
    switch pn.nmcd.dwDrawStage {
        case CDDS_PREPAINT :
            return CDRF_NOTIFYITEMDRAW
        case CDDS_ITEMPREPAINT :
            nd := dir_cast(pn.nmcd.lItemParam, ^TreeNode)
            if nd.foreColor != def_fore_clr {
                pn.clrText = get_color_ref(nd.foreColor)
            }
            if nd.backColor != def_back_clr {
                pn.clrTextBk = get_color_ref(nd.backColor)
            }
            return CDRF_DODEFAULT

    }
    return CDRF_DODEFAULT
}

@private add_style :: proc(tv : ^TreeView, stls : ..DWORD)
{
    for i in stls { if (tv._style & i) != i do tv._style |= i }
}

@private tv_adjust_styles :: proc(tv : ^TreeView)
{
    if tv.noLines do tv._style ~= TVS_HASLINES
    if tv.noButtons do tv._style ~= TVS_HASBUTTONS
    if tv.hasCheckBoxes do add_style(tv, TVS_CHECKBOXES)
    if tv.fullRowSelect do add_style(tv, TVS_FULLROWSELECT)
    if tv.editable do add_style(tv, TVS_EDITLABELS )
    if tv.showSelection do add_style(tv, TVS_SHOWSELALWAYS)
    if tv.hotTracking do add_style(tv, TVS_TRACKSELECT )

    if tv.noButtons && tv.noLines do tv._style ~= TVS_LINESATROOT
}

@private tv_before_creation :: proc(tv : ^TreeView) {tv_adjust_styles(tv)}

@private tv_after_creation :: proc(tv : ^TreeView)
{
	set_subclass(tv, tv_wnd_proc)
    setfont_internal(tv)
    if tv.backColor != app.clrWhite {
        cref := get_color_ref(tv.backColor)
        SendMessage(tv.handle, TVM_SETBKCOLOR, 0, dir_cast(cref, LPARAM) )
    }
    if tv.foreColor != app.clrBlack {
        cref := get_color_ref(tv.foreColor)
        SendMessage(tv.handle, TVM_SETTEXTCOLOR, 0, dir_cast(cref, LPARAM) )
    }
    if tv.lineColor != app.clrBlack  {
        cref := get_color_ref(tv.lineColor)
        SendMessage(tv.handle, TVM_SETLINECOLOR, 0, dir_cast(cref, LPARAM) )
    }
}

@private treeview_property_setter :: proc(this: ^TreeView, prop: TreeViewProps, value: $T)
{
	switch prop {
        case .No_Lines: break
        case .No_Buttons: break
        case .Has_Check_Boxes: break
        case .Full_Row_Select: break
        case .Editable: break
        case .Show_Selection: break
        case .Hot_Tracking: break
        case .Selected_Node: break
        case .Image_List: break
        case .Line_Color: break
	}
}


@private tv_finalize :: proc(tv: ^TreeView, scid: UINT_PTR)
{
    for n in tv.nodes { n._dispose(n)} // looping thru the child nodes and delete them.
    delete(tv.nodes)                  // delete all the top level nodes.
    ImageList_Destroy(tv.imageList)
    RemoveWindowSubclass(tv.handle, tv_wnd_proc, scid)
    free(tv)
}

@private tv_wnd_proc :: proc "fast" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                    sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context //runtime.default_context()
    tv := control_cast(TreeView, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY :
            if tv.onDestroy != nil {
                ea := new_event_args()
                tv.onDestroy(tv, &ea)
            }
            tv_finalize(tv, sc_id)

        case WM_CONTEXTMENU:
		    if tv.contextMenu != nil do contextmenu_show(tv.contextMenu, lp)

        case CM_TVNODEEXPAND :
            node := dir_cast(lp, ^TreeNode)
            SendMessage(tv.handle, TVM_EXPAND, wp, dir_cast(node.handle, LPARAM))
            if node.childCount > 0 {
                for n in node.nodes {
                    SendMessage(tv.handle, CM_TVNODEEXPAND, wp, dir_cast(n, LPARAM))
                }
            }
           // return 0

        case CM_NOTIFY :
            nm := dir_cast(lp, ^NMHDR)
            switch nm.code
            {
                case TVN_DELETEITEMW :
                    if tv.onNodeDeleted != nil
                    {
                        // nmtv := dir_cast(lp, ^NMTREEVIEW)
                        // tn := dir_cast(nmtv.itemOld.lParam, ^TreeNode)
                        // ptf("%s's array deleted now\n", tn.text)
                        ea := new_event_args()
                        tv.onNodeDeleted(tv, &ea)
                    }
                case TVN_SELCHANGINGW :
                    if tv.onBeforeSelect != nil {
                        nmtv := dir_cast(lp, ^NMTREEVIEW)
                        tea := new_tree_event_args(nmtv)
                        tv.onBeforeSelect(tv, &tea)
                    }
                case TVN_SELCHANGEDW :
                    nmtv := dir_cast(lp, ^NMTREEVIEW)
                    tea := new_tree_event_args(nmtv)
                    tv.selectedNode = tea.node
                    if tv.onAfterSelect != nil { tv.onAfterSelect(tv, &tea) }

                case NM_TVSTATEIMAGECHANGING :
                    //print("check NM_TVSTATEIMAGECHANGING")
                    tvsic := dir_cast(lp, ^NMTVSTATEIMAGECHANGING)
                    //tea := new_tree_event_args(tvsic)

                    if tvsic.iOldStateImageIndex == 1 {
                        tv._nodeChecked = true }
                    else if tvsic.iOldStateImageIndex == 2 {
                        tv._nodeChecked = false
                    }

                    // print("chk new - ", tvsic.iNewStateImageIndex)
                    //print("chk action - ", tvsic.iNewStateImageIndex)

                case TVN_ITEMCHANGINGW :
                    if tv.onBeforeChecked != nil {
                        tvic := dir_cast(lp, ^TVITEMCHANGE)
                        tea := new_tree_event_args(tvic)
                        if tv._nodeChecked do tea.node.checked = true
                        tv.onBeforeChecked(tv, &tea)
                    }

                case TVN_ITEMCHANGEDW :
                    if tv.onAfterChecked != nil {
                        tvic := dir_cast(lp, ^TVITEMCHANGE)
                        tea := new_tree_event_args(tvic)
                        if tv._nodeChecked do tea.node.checked = true
                        tv.onAfterChecked(tv, &tea)
                    }

                case TVN_ITEMEXPANDINGW :
                    nmtv := dir_cast(lp, ^NMTREEVIEW)
                    switch nmtv.action {
                        case 1 :
                            if tv.onBeforeCollapse != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.onBeforeCollapse(tv, &tea)
                            }
                        case 2 :
                            if tv.onBeforeExpand != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.onBeforeExpand(tv, &tea)
                            }
                    }

                case TVN_ITEMEXPANDEDW :
                    nmtv := dir_cast(lp, ^NMTREEVIEW)
                    switch nmtv.action {
                        case 1 :
                            if tv.onAfterCollapse != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.onAfterCollapse(tv, &tea)
                            }
                        case 2 :
                            if tv.onAfterExpand != nil {
                                tea := new_tree_event_args(nmtv)
                                tv.onAfterExpand(tv, &tea)
                            }
                    }

                case NM_CUSTOMDRAW :
                    if tv._nodeClrChange {
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


