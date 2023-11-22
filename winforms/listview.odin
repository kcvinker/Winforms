
/*
	Created on : 20-Feb-2022 9:00:25 AM
		Name : ListView type
		*/

package winforms
import "core:runtime"
import api "core:sys/windows"
//import "core:fmt"

// Constants
	// Const1
		IccListViewClass :: 0x1
		WcListViewClassW : wstring = L("SysListView32")
		lvcount : int = 0
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

		DEF_HDR_TXT_FLAG : UINT: DT_SINGLELINE | DT_VCENTER | DT_CENTER | DT_NOPREFIX

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
			lParam : LPARAM,
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
			pt : POINT,
			flags : uint,
			iItem : int,
		}

		HD_LAYOUT :: struct {
			prc : ^RECT,
			pwpos : ^WINDOWPOS,
		}

		NMLVCUSTOMDRAW :: struct {
			nmcd : NMCUSTOMDRAW,
			clrText : COLORREF,
			clrTextBk : COLORREF,
			iSubItem : i32,
			dwItemType : DWORD,
			clrFace : COLORREF,
			iIconEffect : i32,
			iIconPhase : i32,
			iPartId : i32,
			iStateId : i32,
			rcText : RECT,
			uAlign : UINT,
		}
	// Structs


// Constants End

ListView :: struct
{			// IMPORTANT - use this -> LVS_EX_COLUMNSNAPPOINTS - as a property
	using control : Control,
	itemAlignment : enum {Left, Top},
	columnAlignment : ColumnAlignment,

	viewStyle : ListViewStyle,
	hideSelection : bool,
	multiSelection : bool,
	hasCheckBoxes : bool,
	fullRowSelect : bool,
	showGridLines : bool,
	oneClickActivate : bool,
	hotTrackSelect : bool,
	editLabel : bool,
	noHeader : bool,
	headerBackColor, headerForeColor : uint,
	headerHeight : int,

	headerClickable : bool,
	items : [dynamic]^ListViewItem,
	columns : [dynamic]^ListViewColumn,

	_colIndex : i32,
	_index : i32,
	_imgList : ImageList,
	_hdrHwnd : HWND,
	_hdrIndex : i32,
	_hdrBkBrush, _hdrHotBrush : HBRUSH,
	_bgcRef, _fgcRef : COLORREF,
	_bgcDraw : bool,
	_divPen : HPEN,
	_lvcList : [dynamic]LVCOLUMN,
}

ListViewColumn :: struct
{
	text : string,
	width : int,
	pLvc : ^LVCOLUMN,
	index : int,
	imageIndex : int,
	hasImage, imageOnRight : bool,
	alignment : ColumnAlignment,
	headerAlign : HeaderAlignment,
	_hdrTxtFlag : UINT,// For header text alignment

}

ListViewItem :: struct
{
	index : int,
	text : string,
	backColor : uint,
	foreColor : uint,
	font : Font,
	imageIndex : int,
}

ListViewSubItem :: struct
{
	text : string,
	backColor : uint,
	foreColor : uint,
	font : Font,
}

//ListViewStyle :: enum {Normal, Report, }
ListViewStyle :: enum {Large_Icon, Report, Small_Icon, List, Tile, }
ColumnAlignment :: enum {Left, Right, Center,}
HeaderAlignment :: enum {Left, Right, Center,}

/*----------------------------------------------------------------------------------------------------
											↓ ListView constructor ↓
*---------------------------------------------------------------------------------------------------*/
// Create a new ListView struct
new_listview :: proc{lv_constructor1, lv_constructor2, lv_constructor3, lv_constructor4, lv_constructor5, lv_constructor6, lv_constructor7}

@private lv_constructor :: proc(f : ^Form, x, y, w, h : int) -> ^ListView
{
	if lvcount == 0
	{
        app.iccx.dwIcc = IccListViewClass
        InitCommonControlsEx(&app.iccx)
    }
	this := new(ListView)
	lvcount += 1
	this.kind = .List_View
	this.parent = f
	this.font = f.font
	this.xpos = x
	this.ypos = y
	this.width = w
	this.height = h
	this.viewStyle = .Report
	this.showGridLines = true
	//this.multiSelection = true
	this.fullRowSelect = true
	this._style = WS_VISIBLE | WS_CHILD | LVS_REPORT | WS_BORDER | LVS_ALIGNLEFT | LVS_SINGLESEL
	this._exStyle = 0
	this.headerClickable = true
	this.headerBackColor = 0xb3cccc
	this.headerForeColor = 0x000000
	this.backColor = app.clrWhite
	this.foreColor = app.clrBlack

	this._hdrIndex = -1
	this.headerHeight = 25

	this._clsName = WcListViewClassW
	this._fp_beforeCreation = cast(CreateDelegate) lv_before_creation
	this._fp_afterCreation = cast(CreateDelegate) lv_after_creation
	append(&f._controls, this)
	return this
}

@private lv_constructor1 :: proc(f : ^Form, autoc: b8 = false) -> ^ListView
{
	lv := lv_constructor(f, 10, 10, 200, 180)
	if autoc do create_control(lv)
	return lv
}

@private lv_constructor2 :: proc(f : ^Form, x, y : int, autoc: b8 = false) -> ^ListView {
	lv := lv_constructor(f, x, y, 200, 180)
	if autoc do create_control(lv)
	return lv
}

@private lv_constructor3 :: proc(f : ^Form, x, y, w, h : int, autoc: b8 = false) -> ^ListView
{
	lv := lv_constructor(f, x, y, w, h)
	if autoc do create_control(lv)
	return lv
}

@private lv_constructor4 :: proc(f : ^Form, x, y, w, h : int, colnames: ..string) -> ^ListView
{
	lv := lv_constructor(f, x, y, w, h)
	for col in colnames
	{
		pCol := new_listview_column(col, set_coloumn_autosize(lv, col))
		listview_add_column(lv, pCol)
	}
	create_control(lv)
	return lv
}

@private lv_constructor5 :: proc(f : ^Form, x, y, w, h : int, colnames: []string, widths: []int) -> ^ListView
{
	lv := lv_constructor(f, x, y, w, h)
	if len(colnames) == len(widths)
	{
		for col, width in colnames
		{
			pCol := new_listview_column(col, widths[width])
			listview_add_column(lv, pCol)
		}
	}

	create_control(lv)
	return lv
}

@private lv_constructor6 :: proc(f : ^Form, x, y, w, h : int, coldata: ..any) -> ^ListView
{
	lv := lv_constructor(f, x, y, w, h)
	colnames : [dynamic]string
	colwidths : [dynamic]int
	defer delete(colnames)
	defer delete(colwidths)
	// Extracting column names and widths
	for item in coldata
	{
        if value, is_str := item.(string) ; is_str { append(&colnames, value) } // LEAK
        else if value, is_int := item.(int) ; is_int { append(&colwidths, value) } // LEAK
	}
	if len(colnames) == len(colwidths) // If they are same, we can proceed
	{
		for col, i in colnames
		{
			pCol := new_listview_column(col, colwidths[i])
			listview_add_column(lv, pCol)
		}
	}

	create_control(lv)
	return lv
}

@private lv_constructor7 :: proc(f : ^Form, x, y, w, h : int, cols: []^ListViewColumn) -> ^ListView
{
	lv := lv_constructor(f, x, y, w, h)
	for pCol in cols { listview_add_column(lv, pCol) }
	create_control(lv)
	return lv
}

/*------------------------------------------------------------------------------------------------------------
										↓ ListViewColumn constructor ↓
*-------------------------------------------------------------------------------------------------------------*/

new_listview_column :: proc{lv_col_constructor1, lv_col_constructor2, lv_col_constructor3}

@private lv_col_constructor1 :: proc(txt : string, width : int ) -> ^ListViewColumn
{
	lvc := new(ListViewColumn)
	lvc.text = txt
	lvc.width = width
	lvc.hasImage = false
	lvc.imageOnRight =false
	lvc.imageIndex = -1
	lvc.alignment = .Center
	lvc._hdrTxtFlag = DEF_HDR_TXT_FLAG
	//lvc.position = pos
	return lvc
}

@private lv_col_constructor2 :: proc(txt : string ) -> ^ListViewColumn
{
	lvc := new(ListViewColumn)
	lvc.text = txt
	lvc.width = 100
	lvc.hasImage = false
	lvc.imageOnRight =false
	lvc.imageIndex = -1
	lvc.alignment = .Center
	lvc._hdrTxtFlag = DEF_HDR_TXT_FLAG
	//lvc.position = pos
	return lvc
}

@private lv_col_constructor3 :: proc(txt : string, width : int, col_align : ColumnAlignment = .Left,
							hdr_align: HeaderAlignment = .Center  ) -> ^ListViewColumn
{
	lvc := new(ListViewColumn)
	lvc.text = txt
	lvc.width = width
	lvc.hasImage = false
	lvc.imageOnRight =false
	lvc.imageIndex = -1
	lvc.alignment = col_align
	lvc.headerAlign = hdr_align
	set_hdr_text_flag(lvc)
	//lvc.position = pos
	return lvc
}

new_listviewcolumn_array :: proc(name_and_width: ..any) -> [dynamic]^ListViewColumn
{
	colnames : [dynamic]string
	colwidths : [dynamic]int
	defer delete(colnames)
	defer delete(colwidths)
	// Extracting column names and widths
	for item in name_and_width
	{
        if value, is_str := item.(string) ; is_str { append(&colnames, value) }
        else if value, is_int := item.(int) ; is_int { append(&colwidths, value) }
	}
	if len(colnames) == len(colwidths) // If they are same, we can proceed
	{
		result : [dynamic]^ListViewColumn
		for col, i in colnames
		{
			pCol := new_listview_column(col, colwidths[i], ColumnAlignment.Center )
			append(&result, pCol)
		}
		return result
	}
	return nil
}

/*------------------------------------------------------------------------------------------------------------
										↓  ListViewItem constructor ↓
*-----------------------------------------------------------------------------------------------------------*/

// Create new list view item.
new_listviewitem :: proc{listview_item_constructor1, listview_item_constructor2, listview_item_constructor3}

@private lv_item_constructor :: proc(txt : string, bgc : uint, fgc : uint, img : int = -1) -> ^ListViewItem
{
	lvi := new(ListViewItem)
	lvi.backColor = bgc
	lvi.foreColor = fgc
	lvi.text = txt
	lvi.imageIndex = img
	return lvi
}

@private listview_item_constructor1 :: proc(txt : string) -> ^ListViewItem
{
	lvi := lv_item_constructor(txt, white, black)
	return lvi
}

@private listview_item_constructor2 :: proc(txt : string, bk_clr, fr_clr : uint) -> ^ListViewItem
{
	lvi := lv_item_constructor(txt, bk_clr, fr_clr)
	return lvi
}

@private listview_item_constructor3 :: proc(txt : string, img : int) -> ^ListViewItem
{
	lvi := lv_item_constructor(txt, white, black, img)
	return lvi
}


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Coulmn functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add a column to list view
listview_add_column :: proc{lv_addCol1, lv_addCol2, lv_addCol3}

@private lv_addCol1 :: proc(lv : ^ListView, txt : string, width : int,
								img : bool = false, imgOnRight : bool = false)
{
	lvc := new(ListViewColumn)
	lvc.text = txt
	lvc.width = width
	lvc.hasImage = img
	lvc.imageOnRight =imgOnRight
	lvc.imageIndex = -1
	lvc.index = int(lv._colIndex)
	lv._colIndex += 1
	set_hdr_text_flag(lvc)

	lv_add_column(lv, lvc)
}

@private lv_addCol2 :: proc(lv : ^ListView, lvc : ^ListViewColumn)
{
	lvc.index = int(lv._colIndex)
	if lvc.headerAlign != .Center do set_hdr_text_flag(lvc)
	lv._colIndex += 1
	lv_add_column(lv, lvc)
}

@private lv_addCol3 :: proc(lv : ^ListView, txt : string, width : int, align : ColumnAlignment)
{
	lvc := new(ListViewColumn)
	lvc.text = txt
	lvc.width = width
	lvc.hasImage = false
	lvc.imageOnRight = false
	lvc.index = int(lv._colIndex)
	lvc.imageIndex = -1
	lvc.alignment = align
	lv._colIndex += 1
	lvc._hdrTxtFlag = DEF_HDR_TXT_FLAG

	lv_add_column(lv, lvc)
}

// Here is the actual add column work happening.
@private lv_add_column :: proc(lv : ^ListView, lvCol : ^ListViewColumn)
{
	lvc : LVCOLUMN
	lvc.mask = LVCF_FMT | LVCF_TEXT | LVCF_WIDTH | LVCF_SUBITEM
	lvc.fmt = cast(i32) lvCol.alignment
	lvc.cx = i32((lvCol^).width)
	lvc.pszText = to_wstring(lvCol.text)

	if lvCol.hasImage {
		lvc.mask |= LVCF_IMAGE
		lvc.fmt |= LVCFMT_COL_HAS_IMAGES | LVCFMT_IMAGE
		lvc.iImage = i32(lvCol.imageIndex)
	}

	if lvCol.imageOnRight do lvc.fmt |= LVCFMT_BITMAP_ON_RIGHT

	if lv._isCreated {
		SendMessage(lv.handle,
					LVM_INSERTCOLUMNW,
					WPARAM(lvCol.index),
					direct_cast(&lvc, LPARAM) )

		// print("LVM_INSERTCOLUMNW res ", res, lvCol.text)
	} else {
		append(&lv._lvcList, lvc)
		// print("append success")
	}
	append(&lv.columns, lvCol) // We need to add columns if lv is not created now.
}

/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Row functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add an item and sub items(if any) to list view.
listview_add_row :: proc{lv_addrow1, lv_addrow2}

@private lv_addrow1 :: proc(lv : ^ListView, items : ..any, )
{
	if lv.viewStyle != ListViewStyle.Report do return
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

		lvItem := listview_item_constructor1(sItems[0])
		listview_add_item(lv, lvItem)

		for i := 1; i < iLen; i += 1 {
			lvi : LVITEM
			lvi.iSubItem = i32(i)
			lvi.pszText = to_wstring(to_str(sItems[i]))
			iIndx := i32(lvItem.index)
			SendMessage(lv.handle, LVM_SETITEMTEXT, WPARAM(iIndx), direct_cast(&lvi, LPARAM) )
		}
	}
}

@private lv_addrow2 :: proc(lv : ^ListView, item_txt : any)
{
	sItem : string
	if value, is_str := item_txt.(string) ; is_str { // Magic -- type assert
		sItem = value
	} else {
		sItem = to_str(item_txt)
	}
	lvItem := listview_item_constructor1(sItem)
	listview_add_item(lv, lvItem)
}


/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add Item functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add an item to list view
listview_add_item :: proc(lv : ^ListView, lvi : ^ListViewItem)
{
	item : LVITEM
	using item
		mask = LVIF_TEXT | LVIF_PARAM | LVIF_STATE
		if lvi.imageIndex > -1 do mask |= LVIF_IMAGE
		state = 0
		stateMask = 0
		iItem = lv._index
		iSubItem = 0
		lvi.index = int(lv._index)
		iImage = cast(i32) lvi.imageIndex
		pszText = to_wstring(lvi.text)
		cchTextMax = i32(len(lvi.text))
		lParam = direct_cast(lvi, LPARAM)
	SendMessage(lv.handle, LVM_INSERTITEMW, 0, direct_cast(&item, LPARAM))
	append(&lv.items, lvi)
	lv._index += 1
}

/*-------------------------------------------------------------------------------------------------------
*									↓ ListView Add SubItem functions ↓
*--------------------------------------------------------------------------------------------------------*/
// Add a sub item to list view
listview_add_subitem :: proc(lv : ^ListView, item_indx : int, sitem : any, sub_indx : int)
{
	lvi : LVITEM
	lvi.iSubItem = i32(sub_indx)
	lvi.pszText = to_wstring(to_str(sitem))
	iIndx := i32(item_indx)
	SendMessage(lv.handle, LVM_SETITEMTEXT, WPARAM(iIndx), direct_cast(&lvi, LPARAM) )
}

// Add a list of sub items to an item in list view
listview_add_subitems :: proc(lv : ^ListView, item_indx : int, items : ..any)
{
	if lv.viewStyle != ListViewStyle.Report do return
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
		SendMessage(lv.handle, LVM_SETITEMTEXT, WPARAM(iIndx), direct_cast(&lvi, LPARAM) )
		sub_indx += 1
	}
}

/*---------------------------------------------------------------------------------------------------------\
 *									↓ General Public functions ↓
\*--------------------------------------------------------------------------------------------------------*/

// Set the column order of list view.
// Example - listview_set_column_order(lv, 2, 1, 0)
// This will set the column indices in the same order.
listview_set_column_order :: proc(lv : ListView, col_order : ..i32)
{
	// print("set col order")
	if lv._isCreated {
		SendMessage(lv.handle,
					 LVM_SETCOLUMNORDERARRAY,
					 cast(WPARAM) len(col_order),
					 direct_cast(raw_data(col_order), LPARAM))
	}
}

// Returns the column count of this list view
listview_get_coulmn_count :: proc (lv : ^ListView) -> int
{
	x:= cast(int) SendMessage(lv_get_header(lv.handle), 0x1200, 0, 0) // I don't know what is this 0x1200 means.
	return x
}

listview_set_style :: proc (lv : ^ListView, view : ListViewStyle)
{
	lv.viewStyle = view
	if lv._isCreated {
		SendMessage(lv.handle, LVM_SETVIEW, WPARAM(lv.viewStyle), 0)
	}
}

listview_begin_update :: proc (lv : ^ListView)
{
	wp_value : bool = false
	SendMessage(lv.handle, LV_WM_SETREDRAW, WPARAM(wp_value), 0)
}

listview_end_update :: proc (lv : ^ListView)
{
	wp_value : bool = true
	SendMessage(lv.handle, LV_WM_SETREDRAW, WPARAM(wp_value), 0)
}

/*-------------------------------------------------------------------------------------------------------
*											↓ ListView Delete Item functions ↓
*--------------------------------------------------------------------------------------------------------*/
listview_delete_item :: proc{lv_del_item1, lv_del_item2}

lv_del_item1 :: proc (lv : ^ListView, item : ^ListViewItem)
{
	if lv._isCreated {
		SendMessage(lv.handle, LVM_DELETEITEM, WPARAM(i32(item.index)), 0)
		ordered_remove(&lv.items, item.index)
		free(item)
	}
}

lv_del_item2 :: proc (lv : ^ListView, item_index : int)
{
	if lv._isCreated {
		SendMessage(lv.handle, LVM_DELETEITEM, WPARAM(i32(item_index)), 0)
		indx := -1
		for item in lv.items {
			indx += 1
			if item.index == item_index	do break
		}
		if indx > -1 {
			item := lv.items[indx]
			ordered_remove(&lv.items, indx)
			free(item)
		}
	}
}

listview_delete_selected_item :: proc (lv : ^ListView )
{
	print("Not Implemented")
}

listview_clear_items :: proc (lv : ^ListView)
{
	print("Not Implemented")
}

listview_delete_column :: proc (lv : ^ListView)
{
	//LVM_DELETECOLUMN
	print("Not Implemented")
}

listview_get_item :: proc (lv : ^ListView)
{
	print("Not Implemented")
}

listview_get_row :: proc (lv : ^ListView) -> []string
{
	print("Not Implemented")
	 return nil
}


/*-------------------------------------------------------------------------------------------------------
*											↓ Private Helper functions ↓
*--------------------------------------------------------------------------------------------------------*/



@private
lv_get_header :: proc(lvh : HWND) -> HWND {return cast(HWND) cast(UINT_PTR) SendMessage(lvh, LVM_GETHEADER, 0, 0)}



@private
lv_adjust_styles :: proc(lv : ^ListView) {
	#partial switch lv.viewStyle {
		case .Large_Icon :
			lv._style |= LVS_ICON
		case .Report :
			lv._style |= LVS_REPORT
		case .Small_Icon :
			lv._style |= LVS_SMALLICON
		case .List :
			lv._style |= LVS_LIST
	}

	if lv.editLabel do lv._style |= LVS_EDITLABELS
	if !lv.hideSelection do lv._style |= LVS_SHOWSELALWAYS
	if lv.noHeader do lv._style |= LVS_NOCOLUMNHEADER



}

@private
lv_set_extended_styles :: proc(lv : ^ListView) {
	lxs : DWORD
	if lv.showGridLines do lxs |= LVS_EX_GRIDLINES
	if lv.hasCheckBoxes do lxs |= LVS_EX_CHECKBOXES
	if lv.fullRowSelect do lxs |= LVS_EX_FULLROWSELECT
	if lv.oneClickActivate do lxs |= LVS_EX_ONECLICKACTIVATE
	if lv.hotTrackSelect do lxs |= LVS_EX_TRACKSELECT

	SendMessage(lv.handle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LPARAM(lxs) )
}

@private
set_hdr_text_flag :: proc(lvc: ^ListViewColumn) {
	// print("worked")
	if lvc.headerAlign == .Left {
		lvc._hdrTxtFlag = DT_SINGLELINE | DT_VCENTER | DT_LEFT | DT_NOPREFIX
	} else if lvc.headerAlign == .Right {
		lvc._hdrTxtFlag = DT_SINGLELINE | DT_VCENTER | DT_RIGHT | DT_NOPREFIX
	} else {
		lvc._hdrTxtFlag = DEF_HDR_TXT_FLAG
	}
}

@private
draw_divider :: proc(pen: HPEN, hdc: HDC, xp, yp, y2: i32) {
	SelectObject(hdc, HGDIOBJ(pen))
	MoveToEx(hdc, xp, yp, nil)
	LineTo(hdc, xp, y2)
}

@private
draw_header :: proc(lv : ^ListView, nmcd: ^NMCUSTOMDRAW) -> LRESULT
{
	if len(lv.columns) > 0
	{
		hd_index := cast(i32) cast(UINT_PTR) nmcd.dwItemSpec
		col := lv.columns[hd_index]
		// print("hdr drawing started ", col.width, hd_index)

		if col.index > 0 do nmcd.rc.left += 1
		if lv.headerClickable {

			if (nmcd.uItemState & CDIS_SELECTED) == CDIS_SELECTED {
				// Header is clicked. So we will change the back color.
				api.FillRect(nmcd.hdc, &nmcd.rc, lv._hdrBkBrush)
			} else {
				if hd_index == lv._hdrIndex {
					// Mouse pointer is on header. So we will change the back color.
					api.FillRect(nmcd.hdc, &nmcd.rc, lv._hdrHotBrush)
				} else {
					api.FillRect(nmcd.hdc, &nmcd.rc, lv._hdrBkBrush)
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
			api.FillRect(nmcd.hdc, &nmcd.rc, lv._hdrBkBrush);
		}

		// SelectObject(nmcd.hdc, this.mHdrFont.handle);
		// SetTextColor(nmcd.hdc, get_color_ref(lv.headerForeColor))
		// coltxt := to_wstring(col.text)
		draw_divider(lv._divPen, nmcd.hdc, nmcd.rc.right, nmcd.rc.top, nmcd.rc.bottom)
		SetBkMode(nmcd.hdc, 1) // TRANSPARENT
		nmcd.rc.left += 3 // We need some room on the left side
		DrawText(nmcd.hdc, to_wstring(col.text), -1, &nmcd.rc, col._hdrTxtFlag)
		// print("draw text res ", col._hdrTxtFlag, col.text)
		return CDRF_SKIPDEFAULT
	}
	else {
		api.FillRect(nmcd.hdc, &nmcd.rc, lv._hdrBkBrush);
	}
	return CDRF_DODEFAULT
}

@private set_coloumn_autosize :: proc(lv: ^ListView, colname: string) -> int
{
	txtlen:= i32(len(colname))
	ss : SIZE
	hdc: HDC = GetDC(lv.handle)
    defer ReleaseDC(lv.handle, hdc)
    SelectObject(hdc, HGDIOBJ(lv.font.handle))
    GetTextExtentPoint32(hdc, to_wstring(colname), txtlen, &ss)
    return int(ss.width + 10)
}



@private // This will executed right before a list view is created
lv_before_creation :: proc(lv : ^ListView) {
	lv_adjust_styles(lv)
	lv._hdrBkBrush = create_hbrush(lv.headerBackColor)
	lv._hdrHotBrush = CreateSolidBrush(change_color(lv.headerBackColor, 1.12))
	lv._bgcRef = get_color_ref(lv.backColor)
	lv._fgcRef = get_color_ref(lv.foreColor)
	lv._divPen = CreatePen(PS_SOLID, 1, 0x00FFFFFF)
}

@private // This will executed right after a list view is created
lv_after_creation :: proc(lv : ^ListView) {
	// print("alloc data ", (transmute(^int) alloc.data)^)
	set_subclass(lv, lv_wnd_proc)
    lv_set_extended_styles(lv)
	if lv.viewStyle == .Tile do SendMessage(lv.handle, LVM_SETVIEW, WPARAM(0x0004), 0)
	if lv._imgList.handle != nil {	// We need to set the image list to list view.
		SendMessage(lv.handle,
					LVM_SETIMAGELIST,
					cast(WPARAM) lv._imgList.imageType,
					direct_cast(lv._imgList.handle, LPARAM))
	}

	if len(lv._lvcList) > 0 {
		res : i32
		for col in &lv._lvcList {
			res = i32(SendMessage(lv.handle, LVM_INSERTCOLUMNW, WPARAM(res), direct_cast(&col, LPARAM)))
			res += 1
		}
		delete(lv._lvcList) // We don't want this list anymore
	}

	// Let's collect the header handle and subclass it.
	lv._hdrHwnd = HWND(cast(UINT_PTR) SendMessage(lv.handle, LVM_GETHEADER, 0, 0))
	SetWindowSubclass(lv._hdrHwnd, SUBCLASSPROC(hdr_wnd_proc), UINT_PTR(globalSubClassID), to_dwptr(lv))
	globalSubClassID += 1

	// if lv.backColor != 0xFFFFFF do SendMessage(lv.handle, LVM_SETBKCOLOR, 0, LPARAM(lv._bgcRef))

	// print("hdr drawing coooo ")
}


@private lv_finalize :: proc(lv: ^ListView, scid: UINT_PTR) {

	delete_gdi_object(lv._divPen)
	if lv._imgList.handle != nil do ImageList_Destroy(lv._imgList.handle)
	if lv._hdrBkBrush != nil do delete_gdi_object(lv._hdrBkBrush)
	if lv._hdrHotBrush != nil do delete_gdi_object(lv._hdrHotBrush)
    RemoveWindowSubclass(lv.handle, lv_wnd_proc, scid)
    for pcol in lv.columns {free(pcol)}
    for pitem in lv.items	 {free(pitem)}
    delete(lv.items)
	delete(lv.columns)
    free(lv)
}


@private
lv_wnd_proc :: proc "std" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
												sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT {
	context = global_context //runtime.default_context()
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
				lvcd.clrTextBk = lv._bgcRef
				lvcd.clrText = lv._fgcRef
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
hdr_wnd_proc :: proc "std" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
												sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT {
	context = global_context //runtime.default_context()
	lv := control_cast(ListView, ref_data)
	// display_msg(msg)
		switch msg {
			case WM_DESTROY :
				RemoveWindowSubclass(hw, hdr_wnd_proc, UINT_PTR(sc_id) )
				// print("Removed header subclassing result ", res)

			case WM_MOUSEMOVE:
				hti : HDHITTESTINFO
				hti.pt = get_mouse_points(lp)
				lv._hdrIndex = i32(SendMessage(hw, HDM_HITTEST, 0, direct_cast(&hti, LPARAM)))

			case WM_MOUSELEAVE:
				lv._hdrIndex = -1

			case HDM_LAYOUT:
				phl := direct_cast(lp, ^HD_LAYOUT)
				res := DefSubclassProc(hw, msg, wp, lp)
				phl.pwpos.cy = i32(lv.headerHeight)
				return res

			case WM_PAINT:
				DefSubclassProc(hw, msg, wp, lp)
				hrc : RECT
                SendMessage(hw, HDM_GETITEMRECT, WPARAM(len(lv.columns) - 1), direct_cast(&hrc, LPARAM))
                rc : RECT = {hrc.right + 1, hrc.top, i32(lv.width), hrc.bottom}
                hdc : HDC = GetDC(hw)
                api.FillRect(hdc, &rc, lv._hdrBkBrush)
                ReleaseDC(hw, hdc)
                return 0





		}
	return DefSubclassProc(hw, msg, wp, lp)
}