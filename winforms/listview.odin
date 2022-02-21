
/*
	Created on : 20-Feb-2022 9:00:25 AM
		Name : ListView type
		*/

package winforms

import "core:runtime"

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
// Constants End

ListView :: struct {
	using control : Control,
	item_alignment : enum {Left, Top},
	view_style : ListViewStyle,
	hide_selection : bool,
	multi_selection : bool,
	auto_select : bool,		// LVS_EX_AUTOCHECKSELECT
	auto_column_size : bool, // LVS_EX_AUTOSIZECOLUMNS
	has_checkboxes : bool, // LVS_EX_CHECKBOXES
	full_row_select : bool, // LVS_EX_FULLROWSELECT
	show_grid_lines : bool, // LVS_EX_GRIDLINES
	show_header_always : bool, // LVS_EX_HEADERINALLVIEWS
	one_click_activate : bool, // LVS_EX_ONECLICKACTIVATE
	hot_track_select : bool,  // LVS_EX_TRACKSELECT




}

ListViewStyle :: enum {List, Report, }

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
	lv.multi_selection = true
	lv._style = WS_VISIBLE | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | LVS_ALIGNLEFT | LVS_LIST
	lv._ex_style = 0

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

create_listview :: proc(lv : ^ListView) {
	_global_ctl_id += 1
    lv.control_id = _global_ctl_id 
   // lv_adjust_styles(lv)
    lv.handle = CreateWindowEx(   lv._ex_style,  
                                    WcListViewClassW, 
                                    to_wstring(lv.text),
                                    lv._style, 
                                    i32(lv.xpos), 
                                    i32(lv.ypos), 
                                    i32(lv.width), 
                                    i32(lv.height),
                                    lv.parent.handle, 
                                    direct_cast(lv.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if lv.handle != nil 
    {
        lv._is_created = true
        set_subclass(lv, lv_wnd_proc) 
        setfont_internal(lv)
        
    }
}


@private lv_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
												sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
	context = runtime.default_context()
	lv := control_cast(ListView, ref_data)

		switch msg { 
			case WM_DESTROY :
				remove_subclass(lv)
		}
	return DefSubclassProc(hw, msg, wp, lp)
}