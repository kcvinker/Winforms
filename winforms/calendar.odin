/*
    Created on : 18-Jan-2022 04:30 PM
    Author : kcvinu
*/

package winforms
import "core:runtime"

Calendar :: struct {
    using control : Control,
    value : DateTime,
    view_mode : ViewMode,
    old_view : ViewMode,
    show_week_num : b64,
    no_today_circle : b64,
    no_today : b64,
    no_trailing_dates : b64,
    short_day_names : b64,

    value_changed,
    view_changed,
    selection_changed : EventHandler,


}

// Enum for setting Calendar's view mode.
// Posible values : month, year, decade, centuary
ViewMode :: enum {month, year, decade, centuary}

@private calendar_ctor :: proc(p : ^Form, x, y : int) -> Calendar {
    if !is_dtp_class_inited { // Then we need to initialize the date class control.
        is_dtp_class_inited = true
        app.iccx.dwIcc = ICC_DATE_CLASSES
        init_comm_ctrl_ex(&app.iccx)
    }
    c : Calendar
    c.parent = p
    c.font = p.font
    c.kind = .calendar
    c.width = 0
    c.height = 0
    c.xpos = x
    c.ypos = y
    c._style = WS_CHILD | WS_VISIBLE //| MCS_DAYSTATE

    return c
}

// Create a new Calendar control.
new_calendar :: proc{new_cal1, new_cal2}

@private new_cal1 :: proc(parent : ^Form, x, y : int) -> Calendar{
    c := calendar_ctor(parent, x, y)
    return c
}

@private new_cal2 :: proc(parent : ^Form) -> Calendar{
    c := calendar_ctor(parent, 10, 10)
    return c
}

// Api constants.
    MCM_FIRST :: 0x1000
    MCM_GETMINREQRECT :: (MCM_FIRST + 9)
    MCM_SETCOLOR :: (MCM_FIRST + 10)
    MCM_GETCALENDARGRIDINFO :: (MCM_FIRST + 24)

    MCN_FIRST :: 4294966550
    MCN_GETDAYSTATE :: (MCN_FIRST + 3)
    MCN_SELCHANGE :: (MCN_FIRST - 3)
    MCN_SELECT :: MCN_FIRST
    MCN_VIEWCHANGE :: (MCN_FIRST-4)

    MCMV_MONTH :: 0
    MCMV_YEAR :: 1
    MCMV_DECADE :: 2
    MCMV_CENTURY :: 3
    MCMV_MAX :: MCMV_CENTURY

    MCGIP_CALENDARBODY :: 6
    MCGIP_CALENDAR :: 4
    MCGIF_RECT :: 0x2

    NM_RELEASEDCAPTURE :: 4294967280

// End of API constants.

// Api Types
    NMSELCHANGE :: struct {
        nmhdr : NMHDR,
        stSelStart,
        stSelEnd : SYSTEMTIME,
    }

    NMVIEWCHANGE :: struct {
        nmhdr : NMHDR,
        dwOldView : Dword,
        dwNewView : Dword,
    }

    MCGRIDINFO :: struct {
        cbSize : Uint,       
        dwPart : Dword,      
        dwFlags : Dword,      
        iCalendar : i32,        
        iRow : i32,        
        iCol : i32,        
        bSelecte : b32,       
        stStart : SYSTEMTIME,
        stEnd : SYSTEMTIME,
        rc : Rect,       
        pszName : wstring,      
        cchNam : size_t, 
    }

    NMMOUSE :: struct {
        nmhdr : NMHDR,
        dwItemSpec : DwordPtr,
        dwItemData : DwordPtr,
        pt : Point,
        dwHitInfo : Lparam,

    }

// End of API Types

@private set_cal_style :: proc(c : ^Calendar) {
    if c.show_week_num do c._style |= MCS_WEEKNUMBERS
    if c.no_today_circle do c._style |= MCS_NOTODAYCIRCLE
    if c.no_today do c._style |= MCS_NOTODAY
    if c.no_trailing_dates do c._style |= MCS_NOTRAILINGDATES
    if c.short_day_names do c._style |= MCS_SHORTDAYSOFWEEK
}

// Create the handle of a Calendar control.
create_calendar :: proc(cal : ^Calendar) {    
    set_cal_style(cal)
    _global_ctl_id += 1  
    cal.control_id = _global_ctl_id  
    cal.handle = create_window_ex(   cal._ex_style, 
                                    to_wstring("SysMonthCal32"), 
                                    to_wstring(cal.text),
                                    cal._style, 
                                    i32(cal.xpos), 
                                    i32(cal.ypos), 
                                    i32(cal.width), 
                                    i32(cal.height),
                                    cal.parent.handle, 
                                    direct_cast(cal.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if cal.handle != nil { 
        cal._is_created = true 
        setfont_internal(cal) 
        set_subclass(cal, cal_wnd_proc) 
        rc : Rect
        send_message(cal.handle, MCM_GETMINREQRECT, 0, convert_to(Lparam, &rc))
        set_window_pos(cal.handle, nil, i32(cal.xpos), i32(cal.ypos), rc.right, rc.bottom, SWP_NOZORDER)
              
    }

}

@private cal_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
                                                    sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
    context = runtime.default_context()
    cal := control_cast(Calendar, ref_data)
   //display_msg(msg)                                 
    switch msg {  

        case WM_PAINT :
            if cal.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                cal.paint(cal, &pea)
                end_paint(hw, &ps)
                return 0
            }
            
        case CM_NOTIFY :
            nm := direct_cast(lp, ^NMHDR)
            //print("nm.code - ", nm.code)
            switch nm.code {
                case MCN_SELECT:
                    nms := direct_cast(lp, ^NMSELCHANGE)
                    cal.value = systime_to_datetime(nms.stSelStart)
                    if cal.value_changed != nil {
                        ea := new_event_args()
                        cal.value_changed(cal, &ea)
                    }

                case MCN_SELCHANGE :                    
                    nms := direct_cast(lp, ^NMSELCHANGE)
                    cal.value = systime_to_datetime(nms.stSelStart)
                    if cal.selection_changed != nil {
                        ea := new_event_args()
                        cal.selection_changed(cal, &ea)
                    }

                case MCN_VIEWCHANGE:
                    nmv := direct_cast(lp, ^NMVIEWCHANGE)
                    cal.view_mode = ViewMode(nmv.dwNewView)
                    cal.old_view = ViewMode(nmv.dwOldView)
                    if cal.view_changed != nil {
                        ea := new_event_args()
                        cal.view_changed(cal, &ea)
                    }
            }
        
         case WM_MOUSEHWHEEL:
            if cal.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cal.mouse_scroll(cal, &mea)
            }	
            
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if cal._is_mouse_entered {
                if cal.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    cal.mouse_move(cal, &mea)                    
                }
            } else {
                cal._is_mouse_entered = true
                if cal.mouse_enter != nil  {
                    ea := new_event_args()
                    cal.mouse_enter(cal, &ea)                    
                }
            }
        
        case WM_MOUSELEAVE :                      
            cal._is_mouse_entered = false
            if cal.mouse_leave != nil {               
                ea := new_event_args()
                cal.mouse_leave(cal, &ea)                
            } 
        
        
            case WM_LBUTTONDOWN:                       
            cal._mdown_happened = true            
            if cal.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cal.left_mouse_down(cal, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            cal._mrdown_happened = true
            if cal.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cal.right_mouse_down(cal, &mea)
            }

        case WM_LBUTTONUP :     
            if cal.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cal.left_mouse_up(cal, &mea)
            }
            if cal._mdown_happened do send_message(cal.handle, CM_LMOUSECLICK, 0, 0)             

        case CM_LMOUSECLICK :            
            cal._mdown_happened = false
            if cal.mouse_click != nil {
                ea := new_event_args()
                cal.mouse_click(cal, &ea)
                return 0
            }
        
        case WM_LBUTTONDBLCLK :
            if cal.double_click != nil {
                ea := new_event_args()
                cal.double_click(cal, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if cal.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                cal.right_mouse_up(cal, &mea)
            }
            if cal._mrdown_happened do send_message(cal.handle, CM_LMOUSECLICK, 0, 0) 
            
        case CM_RMOUSECLICK :           
            cal._mrdown_happened = false
            if cal.right_click != nil {
                ea := new_event_args()
                cal.right_click(cal, &ea)
                return 0
            }
       

        
        
            case :
            return def_subclass_proc(hw, msg, wp, lp)

    }
    return def_subclass_proc(hw, msg, wp, lp)
}
