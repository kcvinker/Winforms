package winforms
import "core:runtime"
import "core:fmt"

ListBox :: struct {
    using control : Control,
    items : [dynamic]string,
    has_sort : b64,
    cancel_selection : b64,

    selection_changed : LBoxEventHandler,

}

@private lbox_ctor :: proc(p : ^Form, x, y, w, h : int) -> ListBox {
    lbx : ListBox
    lbx.kind = .list_box
    lbx.parent = p
    lbx.font = p.font
    lbx.width = w 
    lbx.height = h
    lbx.xpos = x
    lbx.ypos = y
    lbx._style = WS_VISIBLE | WS_CHILD | LBS_HASSTRINGS  | WS_VSCROLL | WS_BORDER | LBS_NOTIFY //LBS_SORT
    lbx._ex_style = 0
    return lbx
}

@private lbox_ctor1 :: proc(parent : ^Form) -> ListBox {
    lb := lbox_ctor(parent, 10, 10, 200, 230)
    return lb
}

@private lbox_dtor :: proc(lbx : ^ListBox) {
    delete(lbx.items)
}

new_listbox :: proc{lbox_ctor1}

// ListBox Constants
    LBS_DISABLENOSCROLL :: 4096
    LBS_EXTENDEDSEL :: 0x800
    LBS_HASSTRINGS :: 64
    LBS_MULTICOLUMN :: 512
    LBS_MULTIPLESEL :: 8
    LBS_NODATA :: 0x2000
    LBS_NOINTEGRALHEIGHT :: 256
    LBS_NOREDRAW :: 4
    LBS_NOSEL :: 0x4000
    LBS_NOTIFY :: 1
    LBS_OWNERDRAWFIXED :: 16
    LBS_OWNERDRAWVARIABLE :: 32
    LBS_SORT :: 2
    LBS_STANDARD :: 0xa00003
    LBS_USETABSTOPS :: 128
    LBS_WANTKEYBOARDINPUT :: 0x400

    LB_ADDFILE :: 406
    LB_ADDSTRING :: 384
    LB_DELETESTRING :: 386
    LB_DIR :: 397
    LB_ERR :: -1
    LB_FINDSTRING :: 399
    LB_FINDSTRINGEXACT :: 418
    LB_GETANCHORINDEX :: 413
    LB_GETCARETINDEX :: 415
    LB_GETCOUNT :: 395
    LB_GETCURSEL :: 392
    LB_GETHORIZONTALEXTENT :: 403
    LB_GETITEMDATA :: 409
    LB_GETITEMHEIGHT :: 417
    LB_GETITEMRECT :: 408
    LB_GETLOCALE :: 422
    LB_GETSEL :: 391
    LB_GETSELCOUNT :: 400
    LB_GETSELITEMS :: 401
    LB_GETTEXT :: 393
    LB_GETTEXTLEN :: 394
    LB_GETTOPINDEX :: 398
    LB_INITSTORAGE :: 424
    LB_INSERTSTRING :: 385
    LB_ITEMFROMPOINT :: 425
    LB_RESETCONTENT :: 388
    LB_SELECTSTRING :: 396
    LB_SELITEMRANGE :: 411
    LB_SELITEMRANGEEX :: 387
    LB_SETANCHORINDEX :: 412
    LB_SETCARETINDEX :: 414
    LB_SETCOLUMNWIDTH :: 405
    LB_SETCOUNT :: 423
    LB_SETCURSEL :: 390
    LB_SETHORIZONTALEXTENT :: 404
    LB_SETITEMDATA :: 410
    LB_SETITEMHEIGHT :: 416
    LB_SETLOCALE :: 421
    LB_SETSEL :: 389
    LB_SETTABSTOPS :: 402 
    LB_SETTOPINDEX :: 407
    LB_GETLISTBOXINFO :: 434


    LBN_DBLCLK :: 2
    LBN_ERRSPACE :: -2
    LBN_KILLFOCUS :: 5
    LBN_SELCANCEL :: 3
    LBN_SELCHANGE :: 1
    LBN_SETFOCUS :: 4
// Constants

@private set_lbox_style_internal :: proc(lbox : ^ListBox) {
    if lbox.has_sort do lbox._style |= LBS_SORT
    
}

listbox_add_item :: proc(lbx : ^ListBox, item : $T) {
    sitem : string
    when T == string {        
       sitem = item
    } else {
        sitem := fmt.tprint(item)        
    }  
    append(&lbx.items, sitem)
    if lbx._is_created {
        send_message(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(sitem), Lparam))
    }
}

listbox_add_items :: proc(lbx : ^ListBox, items : ..any) {
    for i in items { 
        if value, is_str := i.(string) ; is_str { // Magic -- type assert
            append(&lbx.items, value)
            if lbx._is_created {
                send_message(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(value), Lparam))
            }
        } 
        else {
            a_string := fmt.tprint(i)
            append(&lbx.items, a_string)
            if lbx._is_created {
                send_message(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(a_string), Lparam))
            }
        }
    }  
}

@private lbx_additem_internal :: proc(lbx : ^ListBox) {
    if len(lbx.items) > 0 {
        for item in lbx.items {
            send_message(lbx.handle, LB_ADDSTRING, 0, direct_cast(to_wstring(item), Lparam))
        }
    }
}

create_listbox :: proc(lbx : ^ListBox) {
    _global_ctl_id += 1  
    lbx.control_id = _global_ctl_id  
    set_lbox_style_internal(lbx)
    lbx.handle = create_window_ex(  lbx._ex_style, 
                                    to_wstring("Listbox"), 
                                    to_wstring(lbx.text),
                                    lbx._style, 
                                    i32(lbx.xpos), 
                                    i32(lbx.ypos), 
                                    i32(lbx.width), 
                                    i32(lbx.height),
                                    lbx.parent.handle, 
                                    direct_cast(lbx.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if lbx.handle != nil {          
        lbx._is_created = true          
        setfont_internal(lbx)
        set_subclass(lbx, lbx_wnd_proc) 
        lbx_additem_internal(lbx)
              
    }
}

@private lbx_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
                                                    sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    lbx := control_cast(ListBox, ref_data)
    //display_msg(msg)
    switch msg { 
        case WM_DESTROY :
            lbox_dtor(lbx) 
            remove_subclass(lbx)

        case CM_CTLCOMMAND :
            ncode := get_hiword(wp)
            switch ncode {
                case LBN_DBLCLK :
                case LBN_KILLFOCUS :
                    if lbx.cancel_selection {

                        
                    }
                case LBN_SELCHANGE :
                    sel_indx := send_message(lbx.handle, LB_GETCURSEL, 0, 0)
                    if sel_indx != LB_ERR {
                        if lbx.selection_changed != nil {
                            tlen := send_message(lbx.handle, LB_GETTEXTLEN, Wparam(sel_indx), 0)
                            mem_chunks := make([]Wchar, tlen )
	                        wsBuffer : wstring = &mem_chunks[0]
	                        defer delete(mem_chunks)
                            send_message(lbx.handle, LB_GETTEXT, Wparam(sel_indx), direct_cast(wsBuffer, Lparam))                   
                            lbx.selection_changed(lbx, wstring_to_utf8(wsBuffer, -1))
                            return 0
                        }                        
                    }
                    
                case LBN_SETFOCUS :
                case LBN_SELCANCEL :
                    print("sel cancel")


            }


    
        case : return def_subclass_proc(hw, msg, wp, lp)
    }
    return def_subclass_proc(hw, msg, wp, lp)
}