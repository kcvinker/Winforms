package winforms

// import "core:fmt"
import "core:runtime"

WcGroupBoxW : wstring

GroupBox :: struct {
    using control : Control,

    _bk_brush : Hbrush,
    _paint_bkg : b64,

}

@private gb_count : int = 1

@private gb_ctor :: proc(p : ^Form, txt : string, x, y, w, h : int) -> GroupBox {
    if WcGroupBoxW == nil do WcGroupBoxW = to_wstring("Button")
    gb : GroupBox
    using gb
        kind = .Group_Box
        parent = p
        font = p.font
        xpos = x
        ypos = y
        text = txt
        width = w
        height = h
        back_color = p.back_color
        fore_color = p.fore_color
        _cls_name = WcGroupBoxW
	    _before_creation = cast(CreateDelegate) gb_before_creation
	    _after_creation = cast(CreateDelegate) gb_after_creation
        
        _style = WS_CHILD | WS_VISIBLE | BS_GROUPBOX | BS_NOTIFY | BS_TEXT | BS_TOP
        _ex_style = WS_EX_TRANSPARENT | WS_EX_CONTROLPARENT
    
    return gb    
}

@private gb_dtor :: proc(gb : ^GroupBox) {
    delete_gdi_object(gb._bk_brush)
}

@private gb_ctor1 :: proc(parent : ^Form) -> GroupBox {
    gb_txt : string = concat_number("GroupBox_", gb_count)    
    gb := gb_ctor(parent, gb_txt, 10, 10, 250, 250)
    gb_count += 1
    return gb
}

@private gb_ctor2 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> GroupBox {
    gb := gb_ctor(parent, txt, x, y, w, h)
    return gb
}

// Groupbox control's constructor
new_groupbox :: proc{gb_ctor1, gb_ctor2}

@private gb_before_creation :: proc(gb : ^GroupBox) {if gb.back_color != gb.parent.back_color do gb._paint_bkg = true}

@private gb_after_creation :: proc(gb : ^GroupBox) {	
	set_subclass(gb, gb_wnd_proc) 
    SetWindowTheme(gb.handle, to_wstring(" "), to_wstring(" "))

}

// create_groupbox :: proc(gb : ^GroupBox) {
//     _global_ctl_id += 1     
//     gb.control_id = _global_ctl_id 
//     //set_style_internal(gb)
//     if gb.back_color != gb.parent.back_color do gb._paint_bkg = true
//     gb.handle = CreateWindowEx(  gb._ex_style, 
//                                     to_wstring("Button"), 
//                                     to_wstring(gb.text),
//                                     gb._style, 
//                                     i32(gb.xpos), 
//                                     i32(gb.ypos), 
//                                     i32(gb.width), 
//                                     i32(gb.height),
//                                     gb.parent.handle, 
//                                     direct_cast(gb.control_id, Hmenu), 
//                                     app.h_instance, 
//                                     nil )
    
//     if gb.handle != nil {              
//         gb._is_created = true
//         setfont_internal(gb)
//         set_subclass(gb, gb_wnd_proc)
//         SetWindowTheme(gb.handle, to_wstring(" "), to_wstring(" "))
        

        
//     }
// }

@private gb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {        
    context = runtime.default_context()
    gb := control_cast(GroupBox, ref_data)
    //display_msg(msg)
    switch msg { 
        case WM_PAINT :
            if gb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                gb.paint(gb, &pea)
                EndPaint(hw, &ps)
                return 0
            }
        case WM_DESTROY :
            //print("groubox destroyed")
            gb_dtor(gb)      
            
        case CM_CTLLCOLOR :            
            hdc := direct_cast(wp, Hdc)
            SetBkMode(hdc, Transparent)            
            gb._bk_brush = CreateSolidBrush(get_color_ref(gb.back_color))
            if gb.fore_color != 0x000000 do SetTextColor(hdc, get_color_ref(gb.fore_color))            
            return direct_cast(gb._bk_brush, Lresult)           

        case WM_ERASEBKGND :  
            if gb._paint_bkg {
                hdc := direct_cast(wp, Hdc)
                rc : Rect
                GetClientRect(gb.handle, &rc)
                rc.bottom -= 2         
                FillRect(hdc, &rc, CreateSolidBrush(get_color_ref(gb.back_color)))                
                return 1
            }       
            
        
         case WM_MOUSEHWHEEL:
            if gb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                gb.mouse_scroll(gb, &mea)
            }	

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            //print("grop mouse move")
            if gb._is_mouse_entered {
                if gb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    gb.mouse_move(gb, &mea)                    
                }
            }
            else {
                gb._is_mouse_entered = true
                if gb.mouse_enter != nil  {
                    ea := new_event_args()
                    gb.mouse_enter(gb, &ea)                    
                }
            }
        case WM_NCHITTEST : // This will cause a mouse move message           
            return 1

       
        case WM_MOUSELEAVE :
           // print("m leaved")
            gb._is_mouse_entered = false
            if gb.mouse_leave != nil {               
                ea := new_event_args()
                gb.mouse_leave(gb, &ea)                
            }

        
       
            
        case :
            return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}