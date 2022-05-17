package winforms
import "core:runtime"

EN_SETFOCUS :: 256
UIS_CLEAR :: 2
UISF_HIDEFOCUS :: 0x1
WcEditClassW : wstring
// Text case for Textbox control.
// Possible values : default, lower_case, upper_case
TextCase :: enum {Default, Lower_Case, Upper_Case}

// Text case for Textbox control.
// Possible values : default, number_only, password_char
TextType :: enum {Default, Number_Only, Password_Char}

// Text alignment for Textbox control.
// Possible values : left, center, right
TbTextAlign :: enum {Left, Center, Right}

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
    _frc_ref : ColorRef,



}

@private tb_ctor :: proc(p : ^Form, w : int = 200, h : int = 0) -> TextBox {
    if WcEditClassW == nil do WcEditClassW = to_wstring("EDIT")
    tb : TextBox
    tb.kind = .Text_Box
    tb.width = w
    tb.height = h + 25 if h == 0 else h
    tb.parent = p
    tb.xpos = 10
    tb.ypos = 10
    tb.font = p.font
    tb.hide_selection = true
    tb.back_color = def_back_clr
    tb.fore_color = def_fore_clr
    tb.focus_rect_color = 0x007FFF
    //tb._draw_focus_rct = true
    tb._frc_ref = get_color_ref(tb.focus_rect_color)
    tb._style = WS_BORDER | WS_CHILD | WS_VISIBLE | ES_LEFT | ES_AUTOVSCROLL | WS_TABSTOP  // | WS_CLIPCHILDREN
    tb._ex_style = WS_EX_WINDOWEDGE // WS_EX_CLIENTEDGE // WS_EX_STATICEDGE // WS_EX_WINDOWEDGE WS_EX_CLIENTEDGE WS_EX_STATICEDGE WS_EX_WINDOWEDGE //| 
    tb._cls_name = WcEditClassW
    tb._before_creation = cast(CreateDelegate) tb_before_creation
    tb._after_creation = cast(CreateDelegate) tb_after_creation
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
    if tb.text_case == .Lower_Case {
        tb._style |= ES_LOWERCASE
    } else if tb.text_case == .Upper_Case {
        tb._style |= ES_UPPERCASE
    }
    if tb.text_type == .Number_Only {
        tb._style |= ES_NUMBER
    } else if tb.text_type == .Password_Char {
        tb._style |= ES_PASSWORD
    }
    if tb.text_alignment == .Center {
        tb._style |= ES_CENTER
    } else if tb.text_alignment == .Right {
        tb._style |= ES_RIGHT
    }
}

@private set_tb_bk_clr :: proc(tb : ^TextBox, clr : uint) {
    tb.back_color = clr
    if tb._is_created do InvalidateRect(tb.handle, nil, true)    
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
    SendMessage(tb.handle, EM_SETSEL, Wparam(wpm), Lparam(lpm))
}

// Set a TextBox's read only state.
textbox_set_readonly :: proc(tb : ^TextBox, bstate : bool) {
    SendMessage(tb.handle, EM_SETREADONLY, Wparam(bstate), 0)
    tb.read_only = bstate
}

textbox_clear_all :: proc(tb : ^TextBox) {
    if tb._is_created do SetWindowText(tb.handle, to_wstring(""))
}

@private tb_before_creation :: proc(tb : ^TextBox) {
    adjust_styles(tb)
}

@private tb_after_creation :: proc(tb : ^TextBox) {    
    set_subclass(tb, tb_wnd_proc)
    if len(tb.cue_banner) > 0 {
        up := cast(uintptr) to_wstring(tb.cue_banner)
        SendMessage(tb.handle, EM_SETCUEBANNER, 1, Lparam(up) )
    }     
}


// Create the handle of TextBox control.
// create_textbox :: proc(tb : ^TextBox) {
//     _global_ctl_id += 1     
//     tb.control_id = _global_ctl_id 
//     adjust_styles(tb)
//     tb.handle = CreateWindowEx(   tb._ex_style, 
//                                     WcEditClassW, //to_wstring("Edit"), 
//                                     to_wstring(tb.text),
//                                     tb._style, 
//                                     i32(tb.xpos), 
//                                     i32(tb.ypos), 
//                                     i32(tb.width), 
//                                     i32(tb.height),
//                                     tb.parent.handle, 
//                                     direct_cast(tb.control_id, Hmenu), 
//                                     app.h_instance, 
//                                     nil )
    
//     if tb.handle != nil {
//         tb._is_created = true
//         //mdw := Wparam(make_dword(3,  4))
//         // emty_wstr := to_wstring(" 0")
//         // SetWindowTheme(tb.handle, emty_wstr,emty_wstr)
//         set_subclass(tb, tb_wnd_proc) 
//         setfont_internal(tb)
//         //SendMessage(tb.parent.handle, WM_UPDATEUISTATE, mdw, 0)
//         if len(tb.cue_banner) > 0 {
//             up := cast(uintptr) to_wstring(tb.cue_banner)
//             SendMessage(tb.handle, EM_SETCUEBANNER, 1, Lparam(up) )
//         }     
//     }
// }




@private tb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {    
    
    context = runtime.default_context()
    tb := control_cast(TextBox, ref_data)
    
    switch msg {   
        case WM_PAINT :
            if tb._draw_focus_rct {
                ps : PAINTSTRUCT
                hdc := BeginPaint(tb.handle, &ps)
                frame_brush := CreateSolidBrush(tb._frc_ref)
                FrameRect(hdc, &ps.rcPaint, frame_brush)
                SetBkMode(hdc, Opaque)
                SetBackColor(hdc, get_color_ref(tb.back_color))
                EndPaint(tb.handle, &ps)
                return 0
            }        

            if tb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                tb.paint(tb, &pea)
                EndPaint(hw, &ps)
                return 0
            }       
        
        

        case CM_CTLLCOLOR : 
            //print("ctl clr rcvd")
            if tb.fore_color != def_fore_clr || tb.back_color != def_back_clr {
                dc_handle := direct_cast(wp, Hdc)
                SetBkMode(dc_handle, Transparent)
                if tb.fore_color != def_fore_clr do SetTextColor(dc_handle, get_color_ref(tb.fore_color))   
                //SetBackColor(dc_handle, get_color_ref(tb.back_color))
                tb._bk_brush = CreateSolidBrush(get_color_ref(tb.back_color))
                return to_lresult(tb._bk_brush)
            } //else do return 0 

            //-------------------------

        case CM_CTLCOMMAND :
            ncode := hiword_wparam(wp)
            if ncode == EN_SETFOCUS { 
            //    tb._draw_focus_rct = true
               //SetWindowPos(tb.handle, nil, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_DRAWFRAME)
               
               if tb.got_focus != nil {
                    ea := new_event_args()
                    tb.got_focus(tb, &ea)
                    return 0
                }
               
            }
           
            
            
        
            
           

        case WM_LBUTTONDOWN:
           // tb._draw_focus_rct = true
            tb._mdown_happened = true
            if tb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tb.left_mouse_down(tb, &mea)
                //return 0
            }
            //return 0
            

        case WM_RBUTTONDOWN :
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
            if tb._mdown_happened {
                tb._mdown_happened = false
                SendMessage(tb.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            tb._mdown_happened = false
            if tb.mouse_click != nil {
                ea := new_event_args()
                tb.mouse_click(tb, &ea)
                //return 0
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
            if tb._mrdown_happened {
                tb._mrdown_happened = false
                SendMessage(tb.handle, CM_LMOUSECLICK, 0, 0)
            } 
            
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
            // if SetFocus(tb.handle) == nil {

            //     return 0
            // }
            //return 1
            
            // tb._draw_focus_rct = true
            // InvalidateRect(hw, nil, true)
            //SetFocus(tb.handle)
            // print("st foc rcvd")
            // mdw := Wparam(make_dword(1,  0x1))
            // SendMessage(tb.handle, WM_CHANGEUISTATE, mdw, 0)
            //ptf("low word - %d, hi word - %d\n", loword_wparam(mdw), hiword_wparam(mdw))
            //SetWindowPos(tb.handle, nil, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_DRAWFRAME)
            // if tb.got_focus != nil {
            //     ea := new_event_args()
            //     tb.got_focus(tb, &ea)
            //     return 0 WM_UPDATEUISTATE  WM_CHANGEUISTATE
            // }
           //return 1 //DefSubclassProc(hw, msg, wp, lp)

        // case WM_UPDATEUISTATE :

        // //     print("ui update")
        //     mdw := Wparam(make_dword(1,  0x1))
        //     return DefSubclassProc(hw, msg, mdw, lp)

        // case WM_CHANGEUISTATE :
        //     //print("change ui state")
            
        //     SendMessage(tb.handle, WM_UPDATEUISTATE, wp, lp)
        //     ptf("low word - %d, hi word - %d\n", loword_wparam(wp), hiword_wparam(wp))
            //return  DefSubclassProc(hw, msg, wp, lp)

        //     print("change ui state")

       // case WM_MOUSEACTIVATE :
            //print("WM_MOUSEACTIVATE")

        case WM_KILLFOCUS:
            
           tb._draw_focus_rct = false
            if tb.lost_focus != nil {
                
                ea := new_event_args()
                tb.lost_focus(tb, &ea)
                //return 0
            }
            
            
        case WM_KEYDOWN :
           // tb._draw_focus_rct = true
            if tb.key_down != nil {
                kea := new_key_event_args(wp)
                tb.key_down(tb, &kea)
                return 0 
            }

        case WM_KEYUP :
            if tb.key_up != nil {
                kea := new_key_event_args(wp)
                tb.key_up(tb, &kea)
                return 0
            }

        case WM_CHAR :  
            if tb.key_press != nil {
                kea := new_key_event_args(wp)
                tb.key_press(tb, &kea)
            }          
           SendMessage(tb.handle, CM_TBTXTCHANGED, 0, 0)
            
        case CM_TBTXTCHANGED :
            if tb.text_changed != nil {
                ea:= new_event_args()
                tb.text_changed(tb, &ea)
            }
            

        case WM_DESTROY:
            tb_dtor(tb)
            remove_subclass(tb)

        
        
        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}
