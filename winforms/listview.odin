
/*
	Created on : 20-Feb-2022 9:00:25 AM
		Name : ListView type
		*/

package winforms

import "core:runtime"
//import "core:fmt"

// Constants
	IccListViewClass :: 0x1
	WcListViewClassW : wstring
	LVS_ICON :: 0x0
	LVS_REPORT :: 0x1
	LVS_SMALLICON :: 0x2
	LVS_LIST :: 0x3
	LVS_TYPEMASK :: 0x3
	LVS_SINGLESEL :: 0x4
	LVS_SHOWSELALWAYS :: 0x8
	LVS_SORTASCENDING :: 0x10
	LVS_SORTDESCENDING :: 0x20
	LVS_SHAREIMAGELISTS :: 0x40
	LVS_NOLABELWRAP :: 0x80
	LVS_AUTOARRANGE :: 0x100
	LVS_EDITLABELS :: 0x200
	LVS_OWNERDATA :: 0x1000
	LVS_NOSCROLL :: 0x2000
	LVS_ALIGNTOP :: 0x0
	LVS_ALIGNLEFT :: 0x800
	LVS_ALIGNMASK :: 0xc00
	

	LVS_EX_GRIDLINES :: 0x1
	LVS_EX_SUBITEMIMAGES :: 0x2
	LVS_EX_CHECKBOXES :: 0x4
	LVS_EX_TRACKSELECT :: 0x8
	LVS_EX_HEADERDRAGDROP :: 0x10
	LVS_EX_FULLROWSELECT :: 0x20
	LVS_EX_ONECLICKACTIVATE :: 0x40
	LVS_EX_TWOCLICKACTIVATE :: 0x80
	LVS_EX_FLATSB :: 0x100
	LVS_EX_REGIONAL :: 0x200
	LVS_EX_INFOTIP :: 0x400
	LVS_EX_UNDERLINEHOT :: 0x800
	LVS_EX_UNDERLINECOLD :: 0x1000
	LVS_EX_MULTIWORKAREAS :: 0x2000
	LVS_EX_LABELTIP :: 0x4000
	LVS_EX_BORDERSELECT :: 0x8000
	LVS_EX_DOUBLEBUFFER :: 0x10000
	LVS_EX_HIDELABELS :: 0x20000
	LVS_EX_SINGLEROW :: 0x40000
	LVS_EX_SNAPTOGRID :: 0x80000
	LVS_EX_SIMPLESELECT :: 0x100000

	LVCF_FMT :: 0x1
	LVCF_WIDTH :: 0x2
	LVCF_TEXT :: 0x4
	LVCF_SUBITEM :: 0x8
	LVCF_IMAGE :: 0x10
	LVCF_ORDER :: 0x20

	LVCFMT_LEFT :: 0x0
	LVCFMT_RIGHT :: 0x1
	LVCFMT_CENTER :: 0x2
	LVCFMT_JUSTIFYMASK :: 0x3
	LVCFMT_IMAGE :: 0x800
	LVCFMT_BITMAP_ON_RIGHT :: 0x1000
	LVCFMT_COL_HAS_IMAGES :: 0x8000

	LVIF_DI_SETITEM :: 0x1000
	LVIF_TEXT :: 0x1
	LVIF_IMAGE :: 0x2
	LVIF_PARAM :: 0x4
	LVIF_STATE :: 0x8
	LVIF_INDENT :: 0x10
	LVIF_NORECOMPUTE :: 0x800
	LVIF_GROUPID :: 0x100
	LVIF_COLUMNS :: 0x200

	LVM_FIRST :: 0x1000

	LVM_SETEXTENDEDLISTVIEWSTYLE :: (LVM_FIRST+54)
	LVM_INSERTCOLUMNW :: (LVM_FIRST+97)
	LVM_INSERTITEM :: (LVM_FIRST+77)
	LVM_SETITEMTEXT :: (LVM_FIRST+116)
	LVM_SETIMAGELIST :: (LVM_FIRST+3)


	LVITEM :: struct {
		mask : u32,
		iItem : i32,
		iSubItem : i32,
		state : u32,
		stateMask : u32,
		pszText : wstring,
		cchTextMax : i32,
		iImage : i32,
		lParam : Lparam,
		iIndent : i32,
		iGroupId : i32,
		cColumns : u32,
		puColumns : ^u32,
		piColFmt  : ^i32, 
		iGroup  : i32,
	}

	LVCOLUMN :: struct {
		mask : u32,
		fmt : i32,
		cx : i32,
		pszText : wstring,
		cchTextMax : i32,
		iSubItem : i32,
		iImage : i32,
		iOrder : i32,
		cxMin : i32,
		cxDefault : i32,
		cxIdeal : i32,
	}
// Constants End

ListView :: struct {
	using control : Control,
	item_alignment : enum {Left, Top},
	column_alignment : ColumnAlignment,
	view_style : ListViewStyle,
	hide_selection : bool,
	multi_selection : bool,	
	has_checkboxes : bool, 
	full_row_select : bool, 
	show_grid_lines : bool, 
	one_click_activate : bool, 
	hot_track_select : bool, 
	edit_label : bool,
	items : [dynamic]ListViewItem,

	_col_index : i32,
	_index : i32,
	_imgList : ImageList,


}

ListViewItem :: struct {
	index : int,
	text : string,
	back_color : uint,
	fore_color : uint,
	font : Font,
	image_index : int,
	//sub_items : [dynamic]ListViewSubItem,

}
ListViewSubItem :: struct {
	text : string,
	back_color : uint,
	fore_color : uint,
	font : Font,
}



ListViewStyle :: enum {List, Report, }
ColumnAlignment :: enum {left, right, center,}

new_listview :: proc{lv_ctor1, lv_ctor2}

@private lv_ctor :: proc(f : ^Form, x, y, w, h : int) -> ListView {
	if WcListViewClassW == nil {
        WcListViewClassW = to_wstring("SysListView32")
        app.iccx.dwIcc = IccListViewClass
        InitCommonControlsEx(&app.iccx)
    }
	lv : ListView
	lv.kind = .List_View
	lv.parent = f
	lv.font = f.font
	lv.xpos = x
	lv.ypos = y
	lv.width = w
	lv.height = h
	lv.view_style = .Report
	lv.show_grid_lines = true
	lv.multi_selection = true
	lv.full_row_select = true
	lv._style = WS_VISIBLE | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | LVS_ALIGNLEFT | LVS_REPORT | WS_BORDER 
	lv._ex_style = 0
	lv._cls_name = WcListViewClassW
	lv._before_creation = cast(CreateDelegate) lv_before_creation
	lv._after_creation = cast(CreateDelegate) lv_after_creation

	return lv
}

@private lv_ctor1 :: proc(f : ^Form) -> ListView {
	lv := lv_ctor(f, 10, 10, 200, 180)
	return lv
}

@private lv_ctor2 :: proc(f : ^Form, x, y, w, h : int) -> ListView {
	lv := lv_ctor(f, x, y, w, h)
	return lv
}

new_listview_item :: proc{listview_item_ctor1, listview_item_ctor2}

@private lv_item_ctor :: proc(txt : string, bgc : uint, fgc : uint, img : int = -1) -> ListViewItem {
	lvi : ListViewItem
	lvi.back_color = bgc
	lvi.fore_color = fgc
	lvi.text = txt
	lvi.image_index = img
	return lvi
}

@private listview_item_ctor1 :: proc(txt : string) -> ListViewItem {
	lvi := lv_item_ctor(txt, white, black)
	return lvi
}

@private listview_item_ctor2 :: proc(txt : string, bk_clr, fr_clr : uint) -> ListViewItem {
	lvi := lv_item_ctor(txt, bk_clr, fr_clr)
	return lvi
}

@private lv_dtor :: proc(lv : ^ListView) {
	delete(lv.items)
	if lv._imgList.handle != nil do ImageList_Destroy(lv._imgList.handle)
}

@private
lv_get_header :: proc(lvh : Hwnd) -> Hwnd {return cast(Hwnd) cast(uintptr) SendMessage(lvh, LVM_GETHEADER, 0, 0)}

lv_get_coulmn_count :: proc (lv : ^ListView) -> int {
	x:= cast(int) SendMessage(lv_get_header(lv.handle), 0x1200, 0, 0) // I don't what is this 0x1200 means.	
	return x
}

listview_add_column :: proc(lv : ^ListView, txt : string, width : int, img : bool = false, imgOnRight : bool = false) {
	lvc : LVCOLUMN
	lvc.mask = LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM
	lvc.fmt = cast(i32) lv.column_alignment
	lvc.cx = i32(width)
	lvc.pszText = to_wstring(txt)

	if img {
		lvc.mask |= LVCF_IMAGE
		lvc.fmt |= LVCFMT_COL_HAS_IMAGES | LVCFMT_IMAGE
	}

	if imgOnRight do lvc.fmt |= LVCFMT_BITMAP_ON_RIGHT	

	if lv._is_created {
		res := cast(bool) SendMessage(lv.handle, LVM_INSERTCOLUMNW, Wparam(lv._col_index), direct_cast(&lvc, Lparam) )
		if res do lv._col_index += 1
	}
}

listview_add_row :: proc{lv_addrow1, lv_addrow2}

@private
lv_addrow1 :: proc(lv : ^ListView, items : ..any, ) {
	iLen := len(items)
	if iLen > 0 {
		sItems : [dynamic]string
		defer delete(sItems)
		for j in items {
			if value, is_str := j.(string) ; is_str { // Magic -- type assert
				append(&sItems, value)				
			} else {				
				append(&sItems, to_str(j))				
			}
		}

		lvItem := listview_item_ctor1(sItems[0])
		listview_add_item(lv, &lvItem)	

		for i := 1; i < iLen; i += 1 {
			lvi : LVITEM
			lvi.iSubItem = i32(i)
			lvi.pszText = to_wstring(to_str(sItems[i]))
			iIndx := i32(lvItem.index)
			SendMessage(lv.handle, LVM_SETITEMTEXT, Wparam(iIndx), direct_cast(&lvi, Lparam) )

		}		
	}
}

@private
lv_addrow2 :: proc(lv : ^ListView, item_txt : any) {
	sItem : string
	if value, is_str := item_txt.(string) ; is_str { // Magic -- type assert
		sItem = value			
	} else {
		sItem = to_str(item_txt)					
	}
	lvItem := listview_item_ctor1(sItem)
	listview_add_item(lv, &lvItem)
}

listview_add_item :: proc(lv : ^ListView, lvi : ^ListViewItem) {
	item : LVITEM
	using item
		mask = LVIF_TEXT | LVIF_PARAM | LVIF_STATE
		if lvi.image_index > -1 do mask |= LVIF_IMAGE
		state = 0
		stateMask = 0
		iItem = lv._index
		lvi.index = int(lv._index)
		iImage = cast(i32) lvi.image_index
		pszText = to_wstring(lvi.text)
		cchTextMax = i32(len(lvi.text))
		lParam = direct_cast(lvi, Lparam)
	SendMessage(lv.handle, LVM_INSERTITEMW, 0, direct_cast(&item, Lparam))
	lv._index += 1
}




listview_add_subitem :: proc(lv : ^ListView, item_indx : int, sitem : any, sub_indx : int) {
	lvi : LVITEM
	lvi.iSubItem = i32(sub_indx)
	lvi.pszText = to_wstring(to_str(sitem))
	iIndx := i32(item_indx)
	SendMessage(lv.handle, LVM_SETITEMTEXT, Wparam(iIndx), direct_cast(&lvi, Lparam) )
}


listview_add_subitems :: proc(lv : ^ListView, item_indx : int, items : ..any) {
	sItems : [dynamic]string
	defer delete(sItems)
	for j in items {
		if value, is_str := j.(string) ; is_str { // Magic -- type assert
			append(&sItems, value)				
		} else {			
			append(&sItems, to_str(j))				
		}
	}

	sub_indx : i32 = 1
	for txt in sItems {
		lvi : LVITEM
		lvi.iSubItem = sub_indx
		lvi.pszText = to_wstring(txt)
		iIndx := i32(item_indx)
		SendMessage(lv.handle, LVM_SETITEMTEXT, Wparam(iIndx), direct_cast(&lvi, Lparam) )
		sub_indx += 1
	}
	

}

@private lv_adjust_styles :: proc(lv : ^ListView) {	
	if lv.edit_label do lv._style |= LVS_EDITLABELS
	if !lv.hide_selection do lv._style |= LVS_SHOWSELALWAYS
	if lv.view_style == .Report && lv.full_row_select do lv._ex_style |= LVS_EX_FULLROWSELECT
	

}

@private lv_set_extended_styles :: proc(lv : ^ListView) {
	lxs : Dword
	if lv.show_grid_lines do lxs |= LVS_EX_GRIDLINES	
	if lv.has_checkboxes do lxs |= LVS_EX_CHECKBOXES
	if lv.full_row_select do lxs |= LVS_EX_FULLROWSELECT	
	if lv.one_click_activate do lxs |= LVS_EX_ONECLICKACTIVATE
	if lv.hot_track_select do lxs |= LVS_EX_TRACKSELECT

	SendMessage(lv.handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, Lparam(lxs) )
}

@private lv_before_creation :: proc(lv : ^ListView) {print("creating lv - ", lv.control_id)}

@private lv_after_creation :: proc(lv : ^ListView) {	
	set_subclass(lv, lv_wnd_proc) 
    lv_set_extended_styles(lv)
	if lv._imgList.handle != nil {	// We need to set the image list to list view.
		SendMessage(lv.handle, 
					LVM_SETIMAGELIST, 
					cast(Wparam) lv._imgList.image_type, 
					direct_cast(lv._imgList.handle, Lparam))
	}

}

// create_listview :: proc(lv : ^ListView) {
// 	_global_ctl_id += 1
//     lv.control_id = _global_ctl_id 
//    	//lv_adjust_styles(lv)
//     lv.handle = CreateWindowEx(   lv._ex_style,  
//                                     WcListViewClassW, 
//                                     to_wstring(lv.text),
//                                     lv._style, 
//                                     i32(lv.xpos), 
//                                     i32(lv.ypos), 
//                                     i32(lv.width), 
//                                     i32(lv.height),
//                                     lv.parent.handle, 
//                                     direct_cast(lv.control_id, Hmenu), 
//                                     app.h_instance, 
//                                     nil )
    
//     if lv.handle != nil 
//     {
//         lv._is_created = true
//         set_subclass(lv, lv_wnd_proc) 
//         setfont_internal(lv)
//         lv_set_extended_styles(lv)
//     }
// }


@private lv_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
												sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
	context = runtime.default_context()
	lv := control_cast(ListView, ref_data)

		switch msg { 
			case WM_DESTROY :
				lv_dtor(lv)
				remove_subclass(lv)
		}
	return DefSubclassProc(hw, msg, wp, lp)
}