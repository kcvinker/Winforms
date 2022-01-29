package winforms
import "core:runtime"

// Text case for Textbox control.
// Possible values : default, lower_case, upper_case
TextCase :: enum {default, lower_case, upper_case}

// Text case for Textbox control.
// Possible values : default, number_only, password_char
TextType :: enum {default, number_only, password_char}

// Text alignment for Textbox control.
// Possible values : left, center, right
TbTextAlign :: enum {left, center, right}

TextBox :: struct {
    using control : Control,
    text_alignment : TbTextAlign, 
    multi_line : bool,
    text_type : TextType,
    text_case : TextCase,
    hide_selection : bool,
    read_only : bool,
    cue_banner : string,
    focus_rect_color : uint,

    text_changed : EventHandler,

    _bk_brush : Hbrush,
    _draw_focus_rct : bool,
    _focus_rct_clr : ColorRef,



}

@private tb_ctor :: proc(p : ^Form, w : int = 200, h : int = 0) -> TextBox {
    tb : TextBox
    tb.kind = .text_box
    tb.width = w
    tb.height = h + 25 if h == 0 else h
    tb.parent = p
    tb.xpos = 10
    tb.ypos = 10
    tb.font = p.font
    tb.hide_selection = true
    tb.back_color = 0xFFFFFF
    tb.fore_color = 0x000000
    tb.focus_rect_color = 0x0080FF
    tb._focus_rct_clr = get_color_ref(tb.focus_rect_color)
    tb._style = WS_CHILD | WS_VISIBLE | ES_LEFT | WS_CLIPCHILDREN | ES_AUTOHSCROLL | WS_TABSTOP | WS_BORDER
    tb._ex_style =  WS_EX_LTRREADING | WS_EX_WINDOWEDGE | WS_EX_WINDOWEDGE //| WS_EX_LEFT | WS_EX_WINDOWEDGE | WS_EX_STATICEDGE 
    
    return tb
}

@private tb_dtor :: proc(tb : ^TextBox) {
    delete_gdi_object(tb._bk_brush)
}

// TextBox control constructor.
new_textbox :: proc{new_tb1, new_tb2}

@private new_tb1 :: proc(parent : ^Form) -> TextBox {
    tb := tb_ctor(parent)
    return tb
}

@private new_tb2 :: proc(parent : ^Form, w, h : int, x : int = 50, y : int = 50) -> TextBox {
    tb := tb_ctor(parent, w, h)
    tb.xpos = x
    tb.ypos = y
    return tb
}


@private adjust_styles :: proc(tb : ^TextBox) {
    if tb.multi_line do tb._style |= ES_MULTILINE | ES_WANTRETURN
    if !tb.hide_selection do tb._style |= ES_NOHIDESEL
    if tb.read_only do tb._style |= ES_READONLY
    if tb.text_case == .lower_case {
        tb._style |= ES_LOWERCASE
    } else if tb.text_case == .upper_case {
        tb._style |= ES_UPPERCASE
    }
    if tb.text_type == .number_only {
        tb._style |= ES_NUMBER
    } else if tb.text_type == .password_char {
        tb._style |= ES_PASSWORD
    }
    if tb.text_alignment == .center {
        tb._style |= ES_CENTER
    } else if tb.text_alignment == .right {
        tb._style |= ES_RIGHT
    }
}

@private set_tb_bk_clr :: proc(tb : ^TextBox, clr : uint) {
    tb.back_color = clr
    if tb._is_created do invalidate_rect(tb.handle, nil, true)    
}

// Select or de-select all the text in TextBox control.
textbox_set_selection :: proc(tb : ^TextBox, value : bool) {
    wpm, lpm : i32
    if value {
        wpm = 0
        lpm = -1        
    } else {
        wpm = -1
        lpm = 0
    }
    send_message(tb.handle, EM_SETSEL, Wparam(wpm), Lparam(lpm))
}

// Set a TextBox's read only state.
textbox_set_readonly :: proc(tb : ^TextBox, bstate : bool) {
    send_message(tb.handle, EM_SETREADONLY, Wparam(bstate), 0)
    tb.read_only = bstate
}

textbox_clear_all :: proc(tb : ^TextBox) {
    
}

// Create the handle of TextBox control.
create_textbox :: proc(tb : ^TextBox) {
    _global_ctl_id += 1     
    tb.control_id = _global_ctl_id 
    adjust_styles(tb)
    tb.handle = create_window_ex(   tb._ex_style, 
                                    to_wstring("Edit"), 
                                    to_wstring(tb.text),
                                    tb._style, 
                                    i32(tb.xpos), 
                                    i32(tb.ypos), 
                                    i32(tb.width), 
                                    i32(tb.height),
                                    tb.parent.handle, 
                                    direct_cast(tb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if tb.handle != nil {
        tb._is_created = true
        setfont_internal(tb)
        set_subclass(tb, tb_wnd_proc) 
        if len(tb.cue_banner) > 0 {
            up := cast(uintptr) to_wstring(tb.cue_banner)
            send_message(tb.handle, EM_SETCUEBANNER, 1, Lparam(up) )  
        }     
    }
}




@private tb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {    
    
    context = runtime.default_context()
    tb := control_cast(TextBox, ref_data)
    
    switch msg {   
        case WM_PAINT :
            if tb._draw_focus_rct {                
                ps : PAINTSTRUCT
                hdc := begin_paint(tb.handle, &ps)
                frame_brush := create_solid_brush(tb._focus_rct_clr)
                frame_rect(hdc, &ps.rcPaint, frame_brush)
                end_paint(tb.handle, &ps)
            }

            if tb.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                tb.paint(tb, &pea)
                end_paint(hw, &ps)
                return 0
            }

        

        case CM_CTLLCOLOR : 
                               
            if tb.fore_color != 0x000000 || tb.back_color != 0xFFFFFF {                
                dc_handle := direct_cast(wp, Hdc)
                set_bk_mode(dc_handle, Transparent)
                if tb.fore_color != 0x000000 do set_text_color(dc_handle, get_color_ref(tb.fore_color))                
                if tb._bk_brush == nil do tb._bk_brush = create_solid_brush(get_color_ref(tb.back_color))                 
                return to_lresult(tb._bk_brush)
            } 

        
            
           

        case WM_LBUTTONDOWN:                
            tb._mdown_happened = true            
            if tb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.left_mouse_down(tb, &mea)
                return 0
            }
        case WM_RBUTTONDOWN:
            tb._mrdown_happened = true
            if tb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.right_mouse_down(tb, &mea)
            }
        case WM_LBUTTONUP :     
            if tb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.left_mouse_up(tb, &mea)
            }
            if tb._mdown_happened do send_message(tb.handle, CM_LMOUSECLICK, 0, 0)             

        case CM_LMOUSECLICK :
            tb._mdown_happened = false
            if tb.mouse_click != nil {
                ea := new_event_args()
                tb.mouse_click(tb, &ea)
                return 0
            }
        
        case WM_LBUTTONDBLCLK :
            if tb.double_click != nil {
                ea := new_event_args()
                tb.double_click(tb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if tb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.right_mouse_up(tb, &mea)
            }
            if tb._mrdown_happened do send_message(tb.handle, CM_LMOUSECLICK, 0, 0) 
            
        case CM_RMOUSECLICK :
            tb._mrdown_happened = false
            if tb.right_click != nil {
                ea := new_event_args()
                tb.right_click(tb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if tb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.mouse_scroll(tb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if tb._is_mouse_entered {
                if tb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    tb.mouse_move(tb, &mea)                    
                }
            }
            else {
                tb._is_mouse_entered = true
                if tb.mouse_enter != nil  {
                    ea := new_event_args()
                    tb.mouse_enter(tb, &ea)                    
                }
            }
        
        case WM_MOUSELEAVE :            
            tb._is_mouse_entered = false
            if tb.mouse_leave != nil {               
                ea := new_event_args()
                tb.mouse_leave(tb, &ea)                
            }

        case WM_SETFOCUS :
            tb._draw_focus_rct = true
            if tb.got_focus != nil {
                ea := new_event_args()
                tb.got_focus(tb, &ea)
                return 0
            }

        case WM_KILLFOCUS:
            tb._draw_focus_rct = false
            if tb.lost_focus != nil {
                ea := new_event_args()
                tb.lost_focus(tb, &ea)
                return 0
            }

        case WM_KEYDOWN :
            if tb.key_down != nil {
                kea := new_key_event_args(wp)
                tb.key_down(tb, &kea)                
            }
        case WM_KEYUP :
            if tb.key_up != nil {
                kea := new_key_event_args(wp)
                tb.key_up(tb, &kea)   
            }

        case WM_CHAR :  
            if tb.key_press != nil {
                kea := new_key_event_args(wp)
                tb.key_press(tb, &kea)   
            }          
            send_message(tb.handle, CM_TBTXTCHANGED, 0, 0)
            
        case CM_TBTXTCHANGED :
            if tb.text_changed != nil {
                ea:= new_event_args()
                tb.text_changed(tb, &ea)
            }

        case WM_DESTROY:
            tb_dtor(tb)
            remove_subclass(tb)

        
        
        case : return def_subclass_proc(hw, msg, wp, lp)
    }
    return def_subclass_proc(hw, msg, wp, lp)
}
