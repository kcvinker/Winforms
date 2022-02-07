
/*
    Created on : 06-Feb-2022 7:36:35 PM
    Name : TreeView type
*/

package winforms

import "core:runtime"

// Constants

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
    NMTVDISPINFOEXW :: struct {
        hdr : NMHDR,
        item : TVITEMEXW,
    }
    ICC_TREEVIEW_CLASSES :: 0x2
    WcTreeViewClassW : wstring

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

    begin_edit,
    end_edit : EventHandler,
    

}



@private add_style :: proc(tv : ^TreeView, stls : ..Dword) {    
	for i in stls {
		if (tv._style & i) != i do tv._style |= i
	}
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
    tv.xpos = x
    tv.ypos = y
    tv.width = w
    tv.height = h           // By default a treeview has buttons and lines. Every user might need that.
    tv._style = WS_CHILD | WS_VISIBLE | TVS_HASLINES | TVS_HASBUTTONS | TVS_HASLINES | TVS_LINESATROOT
    tv._ex_style = 0

    return tv
}

@private new_tv1 :: proc(parent : ^Form) -> TreeView {
    tv := tv_ctor(parent, 10, 10, 100, 80)
    return tv
}

@private new_tv2 :: proc(parent : ^Form, x, y, w, h : int) -> TreeView {
    tv := tv_ctor(parent, x, y, w, h)
    return tv
}

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
    
    if tv.handle != nil {
        tv._is_created = true
        set_subclass(tv, tv_wnd_proc) 
        setfont_internal(tv)
        // SendMessage(tv.handle, TBM_SETTHUMBLENGTH, Wparam(i32(100)), 0)
        //tv_set_range_internal(tv)
       
        
    }
}

@private tv_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {      
    context = runtime.default_context()   
    tv := control_cast(TreeView, ref_data)
   // display_msg(msg)
    switch msg {
        case WM_DESTROY :
            //delete_gdi_object(tv._bk_brush)
            remove_subclass(tv)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}
