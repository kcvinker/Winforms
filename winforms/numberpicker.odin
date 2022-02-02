package winforms

import "core:runtime"
import "core:fmt"
import "core:strconv"

// Constants ----------
    is_np_inited : bool = false
    ICC_UPDOWN_CLASS :: 0x10
    
    UD_MAXVAL :: 0x7fff
    UD_MINVAL :: (-UD_MAXVAL)

    UDS_WRAP :: 0x1
    UDS_SETBUDDYINT :: 0x2
    UDS_ALIGNRIGHT :: 0x4
    UDS_ALIGNLEFT :: 0x8
    UDS_AUTOBUDDY :: 0x10
    UDS_ARROWKEYS :: 0x20
    UDS_HORZ :: 0x40
    UDS_NOTHOUSANDS :: 0x80
    UDS_HOTTRACK :: 0x100

    EN_UPDATE :: 1024

// Constants

NumberPicker :: struct {
    using control : Control,
    button_alignment : ButtonAlignment,
    text_alignment : SimpleTextAlignment,
    min_range, max_range : f32,
    has_separator : bool, 
    auto_rotate : bool, // use UDS_WRAP style
    value : f32,
    format_string : string,
    decimal_precision : int,
    hide_selection : bool,
    
    step : f32,

    _buddy_handle : Hwnd,
    _buddy_style : Dword,
    _buddy_exstyle : Dword,
    _buddy_sc_id : int,
    _buddy_proc : SUBCLASSPROC,
    _bk_brush : Hbrush,   
    _tbrc : Rect,
    _udrc : Rect,
    _updated_text : string,
    _update_started : bool,
    _update_finished : bool, 
    

    // Events
    button_paint,
    text_paint : PaintEventHandler,
    value_changed : EventHandler,
}

StepOprator :: enum {add, sub}
ButtonAlignment :: enum {right, left}
NMUPDOWN :: struct {
    hdr : NMHDR,
    iPos : i32,
    iDelta : i32,
}



@private np_ctor :: proc(p : ^Form, x, y, w, h : int) -> NumberPicker {
    if !is_np_inited { // Then we need to initialize the date class control.
        is_np_inited = true
        app.iccx.dwIcc = ICC_UPDOWN_CLASS
        InitCommonControlsEx(&app.iccx)
    }
    np : NumberPicker
    np.kind = .number_picker
    np.parent = p
    np.font = p.font
    np.width = w
    np.height = h
    np.xpos = x
    np.ypos = y
    np.step = 1
    np.back_color = def_back_clr
    np.fore_color = def_fore_clr 
    np.min_range = 0
    np.max_range = 100
    np.decimal_precision = 0
    
    np._style =  WS_VISIBLE | WS_CHILD | UDS_ALIGNRIGHT | UDS_ARROWKEYS | UDS_SETBUDDYINT |  UDS_AUTOBUDDY | UDS_HOTTRACK
    np._buddy_style = WS_CHILD | WS_VISIBLE | ES_NUMBER | WS_TABSTOP | WS_CLIPCHILDREN 
    np._buddy_exstyle = WS_EX_LTRREADING | WS_EX_RTLREADING | WS_EX_LEFT | WS_EX_CLIENTEDGE
    np._ex_style = WS_EX_LTRREADING | WS_EX_RTLREADING | WS_EX_CLIENTEDGE// | WS_EX_LTRREADING
    
    return np
}

@private np_dtor :: proc(np : ^NumberPicker) {
    delete_gdi_object(np._bk_brush)
    RemoveWindowSubclass(np.handle, np._wndproc_ptr, UintPtr(np._subclass_id) )
	RemoveWindowSubclass(np._buddy_handle, np._buddy_proc, UintPtr(np._buddy_sc_id) )
	
}

@private np_ctor1 :: proc(parent : ^Form) -> NumberPicker {
    np := np_ctor(parent,10, 10, 80, 25 )
    return np
}

@private np_ctor2 :: proc(parent : ^Form, x, y, w, h : int) -> NumberPicker {
    np := np_ctor(parent, x, y, w, h)
    return np
}

new_numberpicker :: proc{np_ctor1, np_ctor2}

@private set_np_styles :: proc(np : ^NumberPicker) {
    if np.button_alignment == .left {
        np._style ~= UDS_ALIGNRIGHT
        np._style |= UDS_ALIGNLEFT          
    }

    switch np.text_alignment {
        case .left : np._buddy_style |= ES_LEFT
        case .center : np._buddy_style |= ES_CENTER           
        case .right : np._buddy_style |= ES_RIGHT
    }

    if !np.has_separator do np._style |= UDS_NOTHOUSANDS
}

numberpicker_set_range :: proc(np : ^NumberPicker, max_val, min_val : int) {
    np.max_range = f32(max_val)
    np.min_range = f32(min_val)
    if np._is_created { 
        wpm := direct_cast(min_val, Wparam) 
        lpm := direct_cast(max_val, Lparam)      
        SendMessage(np.handle, UDM_SETRANGE32, wpm, lpm)
    }    
}

@private np_set_range_internal :: proc(np : ^NumberPicker) {
    wpm := direct_cast(i32(np.min_range), Wparam) 
    lpm := direct_cast(i32(np.max_range), Lparam)      
    SendMessage(np.handle, UDM_SETRANGE32, wpm, lpm)
}

@private np_set_value_internal :: proc(np : ^NumberPicker, op : StepOprator) {
    new_val : f32
    if op == .add {
        new_val = np.value + np.step
        if np.auto_rotate {             
            if new_val > np.max_range {  // 100.25 > 100.00
                np.value = np.min_range
            } else do np.value = new_val
        } else {
            if new_val > np.max_range {  // 100.25 > 100.00
                np.value = np.max_range
            } else do np.value = new_val
        }

    } else {
        new_val = np.value - np.step
        if np.auto_rotate {
            if new_val < np.min_range {  // -00.25 < 00.00
                np.value = np.max_range
            } else do np.value = new_val
        } else {
            if new_val < np.min_range {  // 100.25 > 100.00
                np.value = np.min_range
            } else do np.value = new_val
        }

    }
}

@private np_display_value_internal :: proc(np : ^NumberPicker) {
    val_str := fmt.tprintf(np.format_string, np.value)
    SetWindowText(np._buddy_handle, to_wstring(val_str)) 
    
}

@private set_mouse_leave_info :: proc(np : ^NumberPicker) {
    // Mouse leave from a number picker is big problem. Since it is a dual control,
    // So here, we are trying to solve it somehow.
    np._udrc = get_rect(np.handle)        
    np._tbrc = get_rect(np._buddy_handle)   
}

@private np_hide_selection :: proc(np : ^NumberPicker) {
    wpm : i32 = -1
    SendMessage(np._buddy_handle, EM_SETSEL, Wparam(wpm), 0)
}

@private check_updated_text :: proc(tb : ^NumberPicker) {
    // Sometimes user wants to directly type text into edit box.
    // In that situations, we need to take special care in processing that text.
    // Here, we are collecting users input from WM_KEYDOWN message and keep it...
    // in "_updated_text" variable.
    new_val, _ := strconv.parse_f32(tb._updated_text)
    if new_val > tb.max_range {
        tb.value = tb.max_range 
    } else if new_val < tb.min_range {
        tb.value = tb.min_range 
    } else do tb.value = new_val                
    wst := fmt.tprintf(tb.format_string, tb.value)                
    SetWindowText(tb._buddy_handle, to_wstring(wst))  
}



create_numberpicker :: proc(np : ^NumberPicker, ) {
    if !is_np_inited {
        icex : INITCOMMONCONTROLSEX
        icex.dwSize = size_of(icex)
        icex.dwIcc = ICC_UPDOWN_CLASS
        InitCommonControlsEx(&icex)  
        is_np_inited = true
    }
    _global_ctl_id += 1     
    np.control_id = _global_ctl_id 
    set_np_styles(np)
    
    np._buddy_handle = CreateWindowEx( np._buddy_exstyle, 
                                        to_wstring("Edit"), 
                                        nil,
                                        np._buddy_style, 
                                        i32(np.xpos), 
                                        i32(np.ypos), 
                                        i32(np.width), 
                                        i32(np.height),
                                        np.parent.handle, 
                                        direct_cast(np.control_id, Hmenu), 
                                        app.h_instance, 
                                        nil )

    np.handle = CreateWindowEx(  np._ex_style, 
                                    to_wstring("msctls_updown32"), 
                                    nil,
                                    np._style, 
                                    0, 0, 0, 0, // We don't need to set size & pos. Leave it to win32.
                                    np.parent.handle, 
                                    direct_cast(np.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if np.handle != nil && np._buddy_handle != nil {
      // print("np handle - ", np.handle) 
        nph = np.handle
        SendMessage(np.handle, UDM_SETBUDDY, convert_to(Wparam, np._buddy_handle), 0)       
        np._is_created = true        
        set_np_subclass(np, np_wnd_proc, buddy_wnd_proc) 
        if np.font.handle != np.parent.font.handle do CreateFont_handle(&np.font, np._buddy_handle)
	    SendMessage(np._buddy_handle, WM_SETFONT, Wparam(np.font.handle), Lparam(1))
        np_set_range_internal(np) 
        if np.format_string == "" do np.format_string = fmt.tprintf("%%.%df", np.decimal_precision)
        np_display_value_internal(np)  
        set_mouse_leave_info(np)
        
    }
}

@private np_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {        
    context = runtime.default_context()
    np := control_cast(NumberPicker, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY :            
            np_dtor(np)

        case WM_PAINT :
            if np.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                np.button_paint(np, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case CM_NOTIFY :  
            if np._update_started {
                // User started editing the text directly, ...
                // but seems that they are done with it.
                // So we need to finish the editing.
                np._update_finished = true
                np._update_started = false
                check_updated_text(np)
            }        
            nm := direct_cast(lp, ^NMUPDOWN)
            if nm.iDelta == 1 { 
                np_set_value_internal(np, .add)              
            } else {
                np_set_value_internal(np, .sub)
            }
            np_display_value_internal(np)
            if np.value_changed != nil {
                ea := new_event_args()
                np.value_changed(np, &ea)
            }                      
            return 1

        case WM_MOUSEMOVE :           
            if np._is_mouse_entered {
                if np.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    np.mouse_move(np, &mea)                    
                }
            }
            else {
                np._is_mouse_entered = true
                if np.mouse_enter != nil  {
                    ea := new_event_args()
                    np.mouse_enter(np, &ea)                    
                }
            }            

        case WM_MOUSELEAVE : 
            if np.mouse_leave != nil {  
                pt : Point
                GetCursorPos(&pt)
                ScreenToClient(hw, &pt)            
                xflag : bool = true if pt.x == (np._udrc.left + 1) else false
                yflag : bool = true if in_range(pt.y, np._udrc.top, np._udrc.bottom) else false   
                
                if !(xflag && yflag) {
                    np._is_mouse_entered = false                                         
                    ea := new_event_args()
                    np.mouse_leave(np, &ea) 
                    
                } 
            }
        case WM_ENABLE :            
            EnableWindow(hw, bool(wp))
            EnableWindow(np._buddy_handle, bool(wp))
            return 0

        //case WM_CANCELMODE : print("WM_CANCELMODE")
           
            

        

        

        

        
        case : return DefSubclassProc(hw, msg, wp, lp)


    }
    return DefSubclassProc(hw, msg, wp, lp)
}

@private buddy_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {        
    context = runtime.default_context()
    tb := control_cast(NumberPicker, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_PAINT :
            if tb.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                tb.text_paint(tb, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case CM_CTLLCOLOR : 
            if tb.hide_selection {
                wpm : i32 = -1
                SendMessage(hw, EM_SETSEL, Wparam(wpm), 0)
            }           
            if tb.fore_color != def_fore_clr || tb.back_color != def_back_clr {                
                dc_handle := direct_cast(wp, Hdc)
                SetBkMode(dc_handle, Transparent)
               
                if tb.fore_color != 0x000000 do SetTextColor(dc_handle, get_color_ref(tb.fore_color))                
                if tb._bk_brush == nil do tb._bk_brush = CreateSolidBrush(get_color_ref(tb.back_color))                 
                return to_lresult(tb._bk_brush)
            } 
        case WM_KEYDOWN :  
            kea := new_key_event_args(wp)          
            if !tb._update_started {
                if kea.key_code != .up_arrow && kea.key_code != .down_arrow {                    
                    tb._update_started = true
                    tb._update_finished = false
                }
            }

            if tb.key_down != nil {                
                tb.key_down(tb, &kea)  
            }

        case CM_CTLCOMMAND :
            ncode := hiword_wparam(wp)
            if ncode == EN_UPDATE { 
                if tb._update_started do tb._updated_text = get_ctrl_text_internal(hw)                              
            }

        case WM_KEYUP :            
            kea := new_key_event_args(wp)
            if kea.key_code == .enter || kea.key_code == .tab   { 
                tb._update_finished = true
                tb._update_started = false
            }  

            if tb._update_finished do check_updated_text(tb) // Now, we can check the updated text and display it.             

            if tb.key_up != nil {                
                tb.key_up(tb, &kea)   
            }            
            SendMessage(hw, CM_TBTXTCHANGED, 0, 0)
            return 0

        case WM_CHAR :           
            
            if tb.key_press != nil {
                kea := new_key_event_args(wp)
                tb.key_press(tb, &kea)
                return 0   
            }
        
        case CM_TBTXTCHANGED :            
             if tb.value_changed != nil {
                ea:= new_event_args()
                tb.value_changed(tb, &ea)
            }
            
        case WM_MOUSEMOVE :
            //print("mouse moved on buddy ")
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
            if tb.mouse_leave != nil {
                pt : Point
                GetCursorPos(&pt)
                ScreenToClient(hw, &pt)            
                xflag : bool = true if pt.x == tb._tbrc.right else false
                yflag : bool = true if in_range(pt.y, tb._tbrc.top, tb._tbrc.bottom) else false
                
                if !(xflag && yflag) {               
                    tb._is_mouse_entered = false                                         
                    ea := new_event_args()
                    tb.mouse_leave(tb, &ea)   
                    
                } 
            }
        
            
        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}

// Special subclassing for NumberPicker control. Remove_subclass is written in dtor
@private set_np_subclass :: proc(np : ^NumberPicker, np_func, buddy_func : SUBCLASSPROC ) {
	np_dwp := cast(DwordPtr)(cast(uintptr) np)
	SetWindowSubclass(np.handle, np_func, UintPtr(_global_subclass_id), np_dwp )
	np._subclass_id = _global_subclass_id
	np._wndproc_ptr = np_func       
	_global_subclass_id += 1  

	SetWindowSubclass(np._buddy_handle, buddy_func, UintPtr(_global_subclass_id), np_dwp )
	np._buddy_sc_id = _global_subclass_id
	np._buddy_proc = buddy_func
	_global_subclass_id += 1
}



