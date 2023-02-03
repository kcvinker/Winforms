
/*
	Created on : 20-Feb-2022 9:00:25 AM
		Name : ListView type
		*/

package winforms

import "core:runtime"
//import "core:fmt"

// Constants

	// Const1
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
		LVS_NOCOLUMNHEADER  :: 0x4000
		LVS_NOSORTHEADER    :: 0x8000

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
	// Const1

	// U64_MAX := max(u64)
		LVN_FIRST :: 4294967196 //(U64_MAX - 100) + 1

		LV_WM_SETREDRAW :: 0x000B
		LVN_COLUMNCLICK ::      (LVN_FIRST-8)

		DEF_HDR_TXT_FLAG : Uint : DT_SINGLELINE | DT_VCENTER | DT_CENTER | DT_NOPREFIX

		HDM_FIRST ::0x1200
		HDM_LAYOUT :: (HDM_FIRST + 5)
		HDM_HITTEST ::(HDM_FIRST + 6)
		HDM_GETITEMRECT :: (HDM_FIRST + 7)
	//

	// Structs
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

		HDHITTESTINFO :: struct {
			pt : Point,
			flags : uint,
			iItem : int,
		}

		HD_LAYOUT :: struct {
			prc : ^Rect,
			pwpos : ^WINDOWPOS,
		}

		NMLVCUSTOMDRAW :: struct {
			nmcd : NMCUSTOMDRAW,
			clrText : ColorRef,
			clrTextBk : ColorRef,
			iSubItem : i32,
			dwItemType : Dword,
			clrFace : ColorRef,
			iIconEffect : i32,
			iIconPhase : i32,
			iPartId : i32,
			iStateId : i32,
			rcText : Rect,
			uAlign : Uint,
		}
	// Structs


// Constants End

ListView :: struct {			// IMPORTANT - use this -> LVS_EX_COLUMNSNAPPOINTS - as a property
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
	no_header : bool,
	hdr_back_color, hdr_fore_color : uint,
	hdr_height : int,

	hdr_clickable : bool,
	items : [dynamic]ListViewItem,
	columns : [dynamic]ListViewColumn,

	_col_index : i32,
	_index : i32,
	_imgList : ImageList,
	_hdr_hwnd : Hwnd,
	_hdr_index : i32,
	_hdr_bkbrush, _hdr_hotbrush : Hbrush,
	_bgc_ref, _fgc_ref : ColorRef,
	_bgc_draw : bool,
	_div_pen : Hpen,
	_lvc_list : [dynamic]LVCOLUMN,


}

ListViewColumn :: struct {
	text : string,
	width : int,
	pLvc : ^LVCOLUMN,
	index : int,
	image_index : int,
	has_image, image_on_right : bool,
	alignment : ColumnAlignment,
	hdr_align : SimpleTextAlignment,
	_hdr_text_flag : Uint, // For header text alignment

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




//ListViewStyle :: enum {Normal, Report, }
ListViewStyle :: enum {Large_Icon, Report, Small_Icon, List, Tile, }
ColumnAlignment :: enum {left, right, center,}

/*----------------------------------------------------------------------------------------------------
											↓ ListView CTOR ↓
*---------------------------------------------------------------------------------------------------*/
// Create a new ListView struct
new_listview :: proc{lv_ctor1, lv_ctor2}

@private
lv_ctor :: proc(f : ^Form, x, y, w, h : int) -> ListView {
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
	//lv.multi_selection = true
	lv.full_row_select = true
	lv._style = WS_VISIBLE | WS_CHILD | LVS_REPORT | WS_BORDER | LVS_ALIGNLEFT | LVS_SINGLESEL
	lv._ex_style = 0
	lv.hdr_clickable = true
	lv.hdr_back_color = 0xb3cccc
	lv.hdr_fore_color = 0x000000
	lv.back_color = app.clr_white
	lv.fore_color = app.clr_black

	lv._hdr_index = -1
	lv.hdr_height = 25

	lv._cls_name = WcListViewClassW
	lv._before_creation = cast(CreateDelegate) lv_before_creation
	lv._after_creation = cast(CreateDelegate) lv_after_creation

	return lv
}

@private
lv_ctor1 :: proc(f : ^Form) -> ListView {
	lv := lv_ctor(f, 10, 10, 200, 180)
	return lv
}

@private
lv_ctor2 :: proc(f : ^Form, x, y, w, h : int) -> ListView {
	lv := lv_ctor(f, x, y, w, h)
	return lv
}




/*------------------------------------------------------------------------------------------------------------
										↓ ListViewColumn CTOR ↓
*-------------------------------------------------------------------------------------------------------------*/

new_listview_column :: proc{lv_col_ctor1, lv_col_ctor2, lv_col_ctor3}

@private
lv_col_ctor1 :: proc(txt : string, width : int ) -> ListViewColumn {
	lvc : ListViewColumn
	lvc.text = txt
	lvc.width = width
	lvc.has_image = false
	lvc.image_on_right =false
	lvc.image_index = -1
	lvc.alignment = .left
	lvc._hdr_text_flag = DEF_HDR_TXT_FLAG
	//lvc.position = pos
	return lvc
}

@private
lv_col_ctor2 :: proc(txt : string ) -> ListViewColumn {
	lvc : ListViewColumn
	lvc.text = txt
	lvc.width = 100
	lvc.has_image = false
	lvc.image_on_right =false
	lvc.image_index = -1
	lvc.alignment = .left
	lvc._hdr_text_flag = DEF_HDR_TXT_FLAG
	//lvc.position = pos
	return lvc
}

@private
lv_col_ctor3 :: proc(txt : string, width : int, col_align : ColumnAlignment  ) -> ListViewColumn {
	lvc : ListViewColumn
	lvc.text = txt
	lvc.width = width
	lvc.has_image = false
	lvc.image_on_right =false
	lvc.image_index = -1
	lvc.alignment = col_align
	lvc._hdr_text_flag = DEF_HDR_TXT_FLAG
	//lvc.position = pos
	return lvc
}

/*------------------------------------------------------------------------------------------------------------
										↓  ListViewItem CTOR ↓
*-----------------------------------------------------------------------------------------------------------*/

// Create new list view item.
new_listview_item :: proc{listview_item_ctor1, listview_item_ctor2, listview_item_ctor3}

@private
lv_item_ctor :: proc(txt : string, bgc : uint, fgc : uint, img : int = -1) -> ListViewItem {
	lvi : ListViewItem
	lvi.back_color = bgc
	lvi.fore_color = fgc
	lvi.text = txt
	lvi.image_index = img
	return lvi
}

@private
listview_item_ctor1 :: proc(txt : string) -> ListViewItem {
	lvi := lv_item_ctor(txt, white, black)
	return lvi
}

@private
listview_item_ctor2 :: proc(txt : string, bk_clr, fr_clr : uint) -> ListViewItem {
	lvi := lv_item_ctor(txt, bk_clr, fr_clr)
	return lvi
}

@private
listview_item_ctor3 :: proc(txt : string, img : int) -> ListViewItem {
	lvi := lv_item_ctor(txt, white, black, img)
	return lvi
}


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Coulmn functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add a column to list view
listview_add_column :: proc{lv_addCol1, lv_addCol2, lv_addCol3}

@private
lv_addCol1 :: proc(lv : ^ListView, txt : string, width : int, img : bool = false, imgOnRight : bool = false) {
	lvc : ListViewColumn
	lvc.text = txt
	lvc.width = width
	lvc.has_image = img
	lvc.image_on_right =imgOnRight
	lvc.image_index = -1
	lvc.index = int(lv._col_index)
	lv._col_index += 1
	lvc._hdr_text_flag = DEF_HDR_TXT_FLAG

	lv_add_column(lv, &lvc)
}

@private
lv_addCol2 :: proc(lv : ^ListView, lvc : ^ListViewColumn) {
	lvc.index = int(lv._col_index)
	if lvc.hdr_align != .Center do set_hdr_text_flag(lvc)
	lv._col_index += 1
	lv_add_column(lv, lvc)
}

@private
lv_addCol3 :: proc(lv : ^ListView, txt : string, width : int, align : ColumnAlignment) {
	lvc : ListViewColumn
	lvc.text = txt
	lvc.width = width
	lvc.has_image = false
	lvc.image_on_right = false
	lvc.index = int(lv._col_index)
	lvc.image_index = -1
	lvc.alignment = align
	lv._col_index += 1
	lvc._hdr_text_flag = DEF_HDR_TXT_FLAG

	lv_add_column(lv, &lvc)
}

// Here is the actual add column work happening.
@private //----------------------------------------
lv_add_column :: proc(lv : ^ListView, lvCol : ^ListViewColumn) {
	lvc : LVCOLUMN
	lvc.mask = LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM
	lvc.fmt = cast(i32) lvCol.alignment
	lvc.cx = i32((lvCol^).width)
	lvc.pszText = to_wstring(lvCol.text)

	if lvCol.has_image {
		lvc.mask |= LVCF_IMAGE
		lvc.fmt |= LVCFMT_COL_HAS_IMAGES | LVCFMT_IMAGE
		lvc.iImage = i32(lvCol.image_index)
	}

	if lvCol.image_on_right do lvc.fmt |= LVCFMT_BITMAP_ON_RIGHT

	if lv._is_created {
		SendMessage(lv.handle,
					LVM_INSERTCOLUMNW,
					Wparam(lvCol.index),
					direct_cast(&lvc, Lparam) )

		// print("LVM_INSERTCOLUMNW res ", res, lvCol.text)
	} else {
		append(&lv._lvc_list, lvc)
		// print("append success")
	}
	append(&lv.columns, lvCol^) // We need to add columns if lv is not created now.
}


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Row functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add an item and sub items(if any) to list view.
listview_add_row :: proc{lv_addrow1, lv_addrow2}

@private
lv_addrow1 :: proc(lv : ^ListView, items : ..any, ) {
	if lv.view_style != ListViewStyle.Report do return
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


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Item functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add an item to list view
listview_add_item :: proc(lv : ^ListView, lvi : ^ListViewItem) {
	item : LVITEM
	using item
		mask = LVIF_TEXT | LVIF_PARAM | LVIF_STATE
		if lvi.image_index > -1 do mask |= LVIF_IMAGE
		state = 0
		stateMask = 0
		iItem = lv._index
		iSubItem = 0
		lvi.index = int(lv._index)
		iImage = cast(i32) lvi.image_index
		pszText = to_wstring(lvi.text)
		cchTextMax = i32(len(lvi.text))
		lParam = direct_cast(lvi, Lparam)
	SendMessage(lv.handle, LVM_INSERTITEMW, 0, direct_cast(&item, Lparam))
	append(&lv.items, lvi^)
	lv._index += 1
}


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add SubItem functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add a sub item to list view
listview_add_subitem :: proc(lv : ^ListView, item_indx : int, sitem : any, sub_indx : int) {
	lvi : LVITEM
	lvi.iSubItem = i32(sub_indx)
	lvi.pszText = to_wstring(to_str(sitem))
	iIndx := i32(item_indx)
	SendMessage(lv.handle, LVM_SETITEMTEXT, Wparam(iIndx), direct_cast(&lvi, Lparam) )
}

// Add a list of sub items to an item in list view
listview_add_subitems :: proc(lv : ^ListView, item_indx : int, items : ..any) {
	if lv.view_style != ListViewStyle.Report do return
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


/*---------------------------------------------------------------------------------------------------------\
 *									↓ General Public functions ↓
\*--------------------------------------------------------------------------------------------------------*/

// Set the column order of list view.
// Example - listview_set_column_order(lv, 2, 1, 0)
// This will set the column indices in the same order.
listview_set_column_order :: proc(lv : ListView, col_order : ..i32) {
	// print("set col order")
	if lv._is_created {
		SendMessage(lv.handle,
					 LVM_SETCOLUMNORDERARRAY,
					 cast(Wparam) len(col_order),
					 direct_cast(raw_data(col_order), Lparam))
	}

}

// Returns the column count of this list view
listview_get_coulmn_count :: proc (lv : ^ListView) -> int {
	x:= cast(int) SendMessage(lv_get_header(lv.handle), 0x1200, 0, 0) // I don't know what is this 0x1200 means.
	return x
}

listview_set_style :: proc (lv : ^ListView, view : ListViewStyle) {
	lv.view_style = view
	if lv._is_created {
		SendMessage(lv.handle, LVM_SETVIEW, Wparam(lv.view_style), 0)
	}
}

listview_begin_update :: proc (lv : ^ListView) {
	wp_value : bool = false
	SendMessage(lv.handle, LV_WM_SETREDRAW, Wparam(wp_value), 0)
}

listview_end_update :: proc (lv : ^ListView) {
	wp_value : bool = true
	SendMessage(lv.handle, LV_WM_SETREDRAW, Wparam(wp_value), 0)
}

/*-------------------------------------------------------------------------------------------------------
*											↓ ListView Delete Item functions ↓
*--------------------------------------------------------------------------------------------------------*/
listview_delete_item :: proc{lv_del_item1, lv_del_item2}

lv_del_item1 :: proc (lv : ^ListView, item : ListViewItem) {
	if lv._is_created {
		SendMessage(lv.handle, LVM_DELETEITEM, Wparam(i32(item.index)), 0)

	}
}

lv_del_item2 :: proc (lv : ^ListView, item_index : int) {
	if lv._is_created {
		SendMessage(lv.handle, LVM_DELETEITEM, Wparam(i32(item_index)), 0)

	}
}

listview_delete_selected_item :: proc (lv : ^ListView ) {

}

listview_clear_items :: proc (lv : ^ListView) {

}

listview_delete_column :: proc (lv : ^ListView) {
	//LVM_DELETECOLUMN
}

listview_get_item :: proc (lv : ^ListView) {

}

listview_get_row :: proc (lv : ^ListView) -> []string {
	 return nil
}


/*-------------------------------------------------------------------------------------------------------
*											↓ Private Helper functions ↓
*--------------------------------------------------------------------------------------------------------*/



@private
lv_get_header :: proc(lvh : Hwnd) -> Hwnd {return cast(Hwnd) cast(uintptr) SendMessage(lvh, LVM_GETHEADER, 0, 0)}



@private
lv_adjust_styles :: proc(lv : ^ListView) {
	#partial switch lv.view_style {
		case .Large_Icon :
			lv._style |= LVS_ICON
		case .Report :
			lv._style |= LVS_REPORT
		case .Small_Icon :
			lv._style |= LVS_SMALLICON
		case .List :
			lv._style |= LVS_LIST
	}

	if lv.edit_label do lv._style |= LVS_EDITLABELS
	if !lv.hide_selection do lv._style |= LVS_SHOWSELALWAYS
	if lv.no_header do lv._style |= LVS_NOCOLUMNHEADER



}

@private
lv_set_extended_styles :: proc(lv : ^ListView) {
	lxs : Dword
	if lv.show_grid_lines do lxs |= LVS_EX_GRIDLINES
	if lv.has_checkboxes do lxs |= LVS_EX_CHECKBOXES
	if lv.full_row_select do lxs |= LVS_EX_FULLROWSELECT
	if lv.one_click_activate do lxs |= LVS_EX_ONECLICKACTIVATE
	if lv.hot_track_select do lxs |= LVS_EX_TRACKSELECT

	SendMessage(lv.handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, Lparam(lxs) )
}

@private
set_hdr_text_flag :: proc(lvc: ^ListViewColumn) {
	// print("worked")
	if lvc.hdr_align == .Left {
		lvc._hdr_text_flag = DT_SINGLELINE | DT_VCENTER | DT_LEFT | DT_NOPREFIX
	} else if lvc.hdr_align == .Right {
		lvc._hdr_text_flag = DT_SINGLELINE | DT_VCENTER | DT_RIGHT | DT_NOPREFIX
	}
}

@private
draw_divider :: proc(pen: Hpen, hdc: Hdc, xp, yp, y2: i32) {
	SelectObject(hdc, Hgdiobj(pen))
	MoveToEx(hdc, xp, yp, nil)
	LineTo(hdc, xp, y2)
}

@private
draw_header :: proc(lv : ^ListView, nmcd: ^NMCUSTOMDRAW) -> Lresult {


	if len(lv.columns) > 0 {
		hd_index := cast(i32) cast(uintptr) nmcd.dwItemSpec
		col := lv.columns[hd_index]
		// print("hdr drawing started ", col.width, hd_index)

		if col.index > 0 do nmcd.rc.left += 1
		if lv.hdr_clickable {

			if (nmcd.uItemState & CDIS_SELECTED) == CDIS_SELECTED {
				// Header is clicked. So we will change the back color.
				FillRect(nmcd.hdc, &nmcd.rc, lv._hdr_bkbrush)
			} else {
				if hd_index == lv._hdr_index {
					// Mouse pointer is on header. So we will change the back color.
					FillRect(nmcd.hdc, &nmcd.rc, lv._hdr_hotbrush)
				} else {
					FillRect(nmcd.hdc, &nmcd.rc, lv._hdr_bkbrush)
				}
			}

			if (nmcd.uItemState & CDIS_SELECTED) == CDIS_SELECTED {
				/* Here we are mimicing dot net's same technique.
					* We will change the rect's left and top a little bit when header got clicked.
					* So user will feel the header is pressed. */
				nmcd.rc.left += 2;
				nmcd.rc.top += 2;
			}
		} else {
			FillRect(nmcd.hdc, &nmcd.rc, lv._hdr_bkbrush);
		}

		// SelectObject(nmcd.hdc, this.mHdrFont.handle);
		// SetTextColor(nmcd.hdc, get_color_ref(lv.hdr_fore_color))
		// coltxt := to_wstring(col.text)
		draw_divider(lv._div_pen, nmcd.hdc, nmcd.rc.right, nmcd.rc.top, nmcd.rc.bottom)
		SetBkMode(nmcd.hdc, 1) // TRANSPARENT
		DrawText(nmcd.hdc, to_wstring(col.text), -1, &nmcd.rc, col._hdr_text_flag)
		// print("draw text res ", col._hdr_text_flag, col.text)
		return CDRF_SKIPDEFAULT
	}
	else {
		FillRect(nmcd.hdc, &nmcd.rc, lv._hdr_bkbrush);
	}
	return CDRF_DODEFAULT

	// print("hdr drawing finished")

}



@private // This will executed right before a list view is created
lv_before_creation :: proc(lv : ^ListView) {
	lv_adjust_styles(lv)
	lv._hdr_bkbrush = create_hbrush(lv.hdr_back_color)
	lv._hdr_hotbrush = CreateSolidBrush(change_color(lv.hdr_back_color, 1.12))
	lv._bgc_ref = get_color_ref(lv.back_color)
	lv._fgc_ref = get_color_ref(lv.fore_color)
	lv._div_pen = CreatePen(PS_SOLID, 1, 0x00FFFFFF)


}

@private // This will executed right after a list view is created
lv_after_creation :: proc(lv : ^ListView) {
	// print("alloc data ", (transmute(^int) alloc.data)^)
	set_subclass(lv, lv_wnd_proc)
    lv_set_extended_styles(lv)
	if lv.view_style == .Tile do SendMessage(lv.handle, LVM_SETVIEW, Wparam(0x0004), 0)
	if lv._imgList.handle != nil {	// We need to set the image list to list view.
		SendMessage(lv.handle,
					LVM_SETIMAGELIST,
					cast(Wparam) lv._imgList.image_type,
					direct_cast(lv._imgList.handle, Lparam))
	}

	if len(lv._lvc_list) > 0 {
		res : i32
		for col in &lv._lvc_list {
			res = i32(SendMessage(lv.handle, LVM_INSERTCOLUMNW, Wparam(res), direct_cast(&col, Lparam)))
			res += 1
		}
		delete(lv._lvc_list) // We don't want this list anymore
	}

	// Let's collect the header handle and subclass it.
	lv._hdr_hwnd = Hwnd(cast(uintptr) SendMessage(lv.handle, LVM_GETHEADER, 0, 0))
	SetWindowSubclass(lv._hdr_hwnd, SUBCLASSPROC(hdr_wnd_proc), UintPtr(_global_subclass_id), to_dwptr(lv))
	_global_subclass_id += 1

	// if lv.back_color != 0xFFFFFF do SendMessage(lv.handle, LVM_SETBKCOLOR, 0, Lparam(lv._bgc_ref))

	// print("hdr drawing coooo ")
}


@private lv_finalize :: proc(lv: ^ListView, scid: UintPtr) {
	delete(lv.items)
	delete(lv.columns)
	delete_gdi_object(lv._div_pen)
	if lv._imgList.handle != nil do ImageList_Destroy(lv._imgList.handle)
	if lv._hdr_bkbrush != nil do delete_gdi_object(lv._hdr_bkbrush)
	if lv._hdr_hotbrush != nil do delete_gdi_object(lv._hdr_hotbrush)
    RemoveWindowSubclass(lv.handle, lv_wnd_proc, scid)
}


@private
lv_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam,
												sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
	context = runtime.default_context()
	// print("user_index ", (cast(^int) context.user_ptr)^)
	lv := control_cast(ListView, ref_data)
	//display_msg(msg)
	switch msg {
	case WM_DESTROY : lv_finalize(lv, sc_id)

	case WM_SETFOCUS: ctrl_setfocus_handler(lv)
	case WM_KILLFOCUS: ctrl_killfocus_handler(lv)

	case CM_NOTIFY :
		nmh := direct_cast(lp, ^NMHDR)
		switch nmh.code {
		case NM_CUSTOMDRAW:
			lvcd := direct_cast(lp, ^NMLVCUSTOMDRAW)
			switch lvcd.nmcd.dwDrawStage {
			case CDDS_PREPAINT:
				return CDRF_NOTIFYITEMDRAW
			case CDDS_ITEMPREPAINT:
				lvcd.clrTextBk = lv._bgc_ref
				lvcd.clrText = lv._fgc_ref
				// print("iSubItem ", lvcd.nmcd.dwItemSpec)
				return CDRF_NEWFONT | CDRF_DODEFAULT
			}
			return CDRF_DODEFAULT

		}



	case WM_NOTIFY:
		// Message from header.
		nmh := direct_cast(lp, ^NMHDR)
		switch nmh.code {
		case NM_CUSTOMDRAW :  // Let's draw header back & fore colors
			nmcd := direct_cast(lp, ^NMCUSTOMDRAW)
			switch nmcd.dwDrawStage {
			case CDDS_PREPAINT:
				return CDRF_NOTIFYITEMDRAW
			case CDDS_ITEMPREPAINT:
				// print("hdr item prepaint ")
				return draw_header(lv, nmcd)
				// return CDRF_SKIPDEFAULT
			}

		}



	}
	return DefSubclassProc(hw, msg, wp, lp)
}

@private
hdr_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam,
												sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
	context = runtime.default_context()
	lv := control_cast(ListView, ref_data)
	// display_msg(msg)
		switch msg {
			case WM_DESTROY :
				RemoveWindowSubclass(hw, hdr_wnd_proc, UintPtr(sc_id) )
				// print("Removed header subclassing result ", res)

			case WM_MOUSEMOVE:
				hti : HDHITTESTINFO
				hti.pt = get_mouse_points(lp)
				lv._hdr_index = i32(SendMessage(hw, HDM_HITTEST, 0, direct_cast(&hti, Lparam)))

			case WM_MOUSELEAVE:
				lv._hdr_index = -1

			case HDM_LAYOUT:
				phl := direct_cast(lp, ^HD_LAYOUT)
				res := DefSubclassProc(hw, msg, wp, lp)
				phl.pwpos.cy = i32(lv.hdr_height)
				return res

			case WM_PAINT:
				DefSubclassProc(hw, msg, wp, lp)
				hrc : Rect
                SendMessage(hw, HDM_GETITEMRECT, Wparam(len(lv.columns) - 1), direct_cast(&hrc, Lparam))
                rc : Rect = {hrc.right + 1, hrc.top, i32(lv.width), hrc.bottom}
                hdc : Hdc = GetDC(hw)
                FillRect(hdc, &rc, lv._hdr_bkbrush)
                ReleaseDC(hw, hdc)
                return 0





		}
	return DefSubclassProc(hw, msg, wp, lp)
}