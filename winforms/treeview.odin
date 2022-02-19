
/*
    Created on : 06-Feb-2022 7:36:35 PM
    Name : TreeView type
*/

package winforms

import "core:runtime"
//import "core:slice"
//import "core:fmt"


ICC_TREEVIEW_CLASSES :: 0x2
WcTreeViewClassW : wstring

NodeDisposeHandler :: proc(node : ^TreeNode)

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

    TVNA_ADD :: 1
    TVNA_ADDFIRST :: 2
    TVNA_ADDCHILD :: 3
    TVNA_ADDCHILDFIRST :: 4
    TVNA_INSERT :: 5

    TVIML_FLAG :: 0x00000020 | 0x00000001

    TV_FIRST :: 0x1100
    TVN_FIRST :: 4294966896
    TVM_DELETEITEM :: (TV_FIRST+1)
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

    ChildData :: enum {Child_Auto = -2, Child_Callback = -1, Zero = 0, One = 1,} 


// Constants End

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
} 

new_treeview :: proc{new_tv1, new_tv2}

@private tv_ctor :: proc(f : ^Form, x, y, w, h : int) -> TreeView {
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
    tv.back_color = 0xFFFFFF
    tv.fore_color = def_fore_clr
    tv.line_color = def_fore_clr
    tv.xpos = x
    tv.ypos = y
    tv.width = w
    tv.height = h           // By default a treeview has buttons and lines. Every user might need that.
    tv._style = WS_BORDER | WS_CHILD | WS_VISIBLE | TVS_HASLINES | TVS_HASBUTTONS | TVS_LINESATROOT | TVS_DISABLEDRAGDROP
    tv._ex_style = 0
   
    return tv
}

@private new_tv1 :: proc(parent : ^Form) -> TreeView {
    tv := tv_ctor(parent, 10, 10, 200, 250)
    return tv
}

@private new_tv2 :: proc(parent : ^Form, x, y, w, h : int) -> TreeView {
    tv := tv_ctor(parent, x, y, w, h)
    return tv
}

// a comment
@private tv_dtor :: proc(tv : ^TreeView) {      
    for n in tv.nodes { n._dispose(n)} // looping thru the child nodes and delete them.
    delete(tv.nodes)                  // delete all the top level nodes. 
    ImageList_Destroy(tv.image_list)    
}

// Create new tree view node. a new code
new_treenode :: proc(txt : string, img : int = -1, simg : int = -1, 
                    fclr : uint = def_fore_clr, bk_clr : uint = def_back_clr) -> TreeNode {
    tn : TreeNode      
    tn.image_index = img
    tn.sel_image_index = simg
    tn.text = txt
    tn._dispose = dispose_node
    tn.fore_color = fclr
    tn.back_color = bk_clr
    return tn
}

// Add a new node to tree view. It can be a parent or a child.
treeview_add_node :: proc(tv : ^TreeView, node : ^TreeNode, parent : ^TreeNode = nil) {
    tv_add_node_internal(tv, node, parent )
}

// We can insert a node in a specific position.
treeview_insert_node :: proc(tv : ^TreeView, node : ^TreeNode, index : int,  parent : ^TreeNode = nil) {
    tv_add_node_internal(tv, node, parent, index )
}

// This function serves 3 jobs. Add main node, add child node & insert node(both main & child)
@private tv_add_node_internal :: proc(tv : ^TreeView, node : ^TreeNode, parent : ^TreeNode = nil, indx : int = -1 )  {
    tx : TVITEMEXW
    tx.mask = TVIF_TEXT | TVIF_PARAM 
    tx.pszText = to_wstring(node.text)
    tx.cchTextMax = i32(len(node.text))
    tx.iImage = i32(node.image_index)
    tx.iSelectedImage = i32(node.sel_image_index)
    tx.stateMask = TVIS_USERMASK
    tx.lParam = direct_cast(node, Lparam) 

    if node.image_index > -1 do tx.mask |= TVIF_IMAGE
    if node.sel_image_index > -1 do tx.mask |= TVIF_SELECTEDIMAGE
    if node.fore_color != def_fore_clr do tv._node_clr_change = true

    tins : TVINSERTSTRUCT
    tins.itemEx = tx
    if parent == nil { // It is top level node.
        if tv._item_count > 0 { 
            if indx > -1 { // user wants to insert this node in a specific index.
                if indx == 0 { 
                    tins.hInsertAfter = TVI_FIRST } 
                else {
                    top_node := tv.nodes[indx - 1]
                    tins.hInsertAfter = top_node.handle 
                } 
            } 
            else {
                tins.hInsertAfter = tv._last_item_hw } }
        else {
            tins.hInsertAfter = TVI_FIRST }

        tins.hParent = nil
        append(&tv.nodes, node)
    }
    else {   // It is a child node.
        if indx > -1 { // user wants to put this item in a specific index.
            if indx == 0 { 
                tins.hInsertAfter = TVI_FIRST } 
            else {
                top_node := parent.nodes[indx - 1]
                tins.hInsertAfter = top_node.handle
            }
            
        } else { // put the item at the end of tree view
            node.parent_node = parent
            tins.hInsertAfter = TVI_LAST
            tins.hParent = parent.handle
            node.parent_node.handle = parent.handle
            parent.child_count += 1
            append(&parent.nodes, node)
        }        
    }    
    tins.itemEx.lParam = direct_cast(rawptr(node), Lparam)
    lres := SendMessage(tv.handle, TVM_INSERTITEMW, 0,  direct_cast(&tins, Lparam) ) 
    if lres != 0 {        
        hItem := direct_cast(lres, HtreeItem)
        node.handle = hItem   
        tv._unique_item_id += 1
        if parent == nil {
            tv._last_item_hw = hItem
            tv._item_count += 1
        }                
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

// Create the handle of a tree view
create_treeview :: proc(tv : ^TreeView) {
    _global_ctl_id += 1
    tv.control_id = _global_ctl_id 
    tv_adjust_styles(tv)
    tv.handle = CreateWindowEx(   tv._ex_style,  
                                    WcTreeViewClassW, 
                                    to_wstring(tv.text),
                                    tv._style, 
                                    i32(tv.xpos), 
                                    i32(tv.ypos), 
                                    i32(tv.width), 
                                    i32(tv.height),
                                    tv.parent.handle, 
                                    direct_cast(tv.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if tv.handle != nil 
    {
        tv._is_created = true
        set_subclass(tv, tv_wnd_proc) 
        setfont_internal(tv)
        if tv.back_color != 0xFFFFFF {
            cref := get_color_ref(tv.back_color)
            SendMessage(tv.handle, TVM_SETBKCOLOR, 0, direct_cast(cref, Lparam) ) 
        }
        if tv.fore_color != def_fore_clr {
            cref := get_color_ref(tv.fore_color)
            SendMessage(tv.handle, TVM_SETTEXTCOLOR, 0, direct_cast(cref, Lparam) ) 
        }
        if tv.line_color != def_fore_clr  {
            cref := get_color_ref(tv.line_color)
            SendMessage(tv.handle, TVM_SETLINECOLOR, 0, direct_cast(cref, Lparam) ) 
        }      
    }
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
            tv_dtor(tv)
            remove_subclass(tv) 
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

