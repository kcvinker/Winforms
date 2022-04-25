
package winforms

//import "core:fmt"
import "core:runtime"
//import "core:strings"

ICC_DATE_CLASSES :: 0x100
is_dtp_class_inited : bool = false
WcDTPClassW : wstring 
 

//#region dtp styles
    //DTN_FIRST :: i64(-740)   //~u64(0) - 740  // 0xFFFFFFFFFFFFFD1C
    //DTN_LAST :: ~u64(0) - 745 - 1
    //DTN_FIRST2 :: i64(-753)      //~u64(0) - 753  // 0xFFFFFFFFFFFFFD0F 
    //DTN_LAST2 ::  ~u64(0) - 799 - 1
    DtnFirst :: u64(4294966556)
    DTN_DATETIMECHANGE :: u64(4294966537) //DTN_FIRST2-6
    DTN_DROPDOWN :: u64(4294967280) //u64(18446744073709550862) // DTN_FIRST2 - 1
    DTN_CLOSEUP :: u64(140728898419983) //u64(18446744073709550863) //DTN_FIRST2
    DTN_USERSTRINGW :: u64(18446744073709550871) //(DTN_FIRST-5)
    DTN_WMKEYDOWNW :: u64(18446744073709550872)   //(DTN_FIRST-4)
    DTN_FORMATW :: u64(18446744073709550873) //(DTN_FIRST-3)
    DTN_FORMATQUERYW :: u64(18446744073709550874) //(DTN_FIRST-2)
    DtnUserStr :: DtnFirst - 5

    DTM_FIRST :: 0x1000
    DTM_SETFORMATW :: DTM_FIRST + 50
    DTM_GETDATETIMEPICKERINFO :: DTM_FIRST + 14
    DTM_SETMCCOLOR :: DTM_FIRST + 6
    DTM_GETMCSTYLE :: (DTM_FIRST + 12)
    DTM_SETMCSTYLE  :: (DTM_FIRST + 11)
    DTM_SETSYSTEMTIME :: (DTM_FIRST + 2)

    MCSC_BACKGROUND :: 0
    MCSC_TEXT :: 1
    MCSC_TITLEBK :: 2
    CSC_TITLETEXT :: 3
    MCSC_MONTHBK :: 4
    MCSC_TRAILINGTEXT :: 5

    MCS_DAYSTATE :: 0x1
    MCS_MULTISELECT :: 0x2
    MCS_WEEKNUMBERS :: 0x4
    MCS_NOTODAYCIRCLE :: 0x8
    MCS_NOTODAY :: 0x10
    MCS_NOTRAILINGDATES :: 0x40
    MCS_SHORTDAYSOFWEEK :: 0x80
    MCS_NOSELCHANGEONNAV :: 0x100

    subVal : i32 = -1
    myDtnfirst : u64 : 4294966556
    myDtnFirst2 : u64 : 4294966543
    myDtnDropdown : u64 : 4294966542
    myDtnCloseup := myDtnFirst2


    DTS_UPDOWN :: 0x1
    DTS_SHOWNONE :: 0x2
    DTS_SHORTDATEFORMAT :: 0x0
    DTS_LONGDATEFORMAT :: 0x4
    DTS_SHORTDATECENTURYFORMAT :: 0xc
    DTS_TIMEFORMAT :: 0x9
    DTS_APPCANPARSE :: 0x10
    DTS_RIGHTALIGN :: 0x20
//#endregion


// Date time time format for DTP control.
// Possible values : long = 1, short = 2, time = 4, custom = 8
DtpFormat :: enum {Long = 1, Short = 2, Time = 4, Custom = 8}


DateTimePicker :: struct {
    using control : Control,
    format : DtpFormat,
    format_string : string,
    right_align : b64,
    four_digit_year : b64,    
    value : DateTime,
    show_week_num : b64,
    no_today_circle : b64,
    no_today : b64,
    no_trailing_dates : b64,
    show_updown : b64,
    short_day_names : b64,


   // _fmt_str : string,
    _value_change_count : int,
    _bk_brush : Hbrush,   
    _cal_style : Dword,


    calendar_opened,
    value_changed,    
    calendar_closed : EventHandler,
    text_changed : DateTimeEventHandler,
    



}

// Api Types
    NMDATETIMECHANGE :: struct{
        nmhdr : NMHDR,
        dwFlags : Dword,
        st : SYSTEMTIME,
    }

    NMDATETIMESTRINGW :: struct {
        nmhdr :  NMHDR,
        pszUserString : wstring,
        st : SYSTEMTIME,
        dwFlags : Dword,
    }



    // DATETIMEPICKERINFO :: struct {
    //     cbSize : Dword,
    //     rcCheck : Rect,
    //     stateCheck : Dword,
    //     rcButton : Rect,
    //     stateButton : Dword,
    //     hwndEdit : Hwnd,
    //     hwndUD : Hwnd,
    //     hwndDropDown : Hwnd,
    // }

    // DtpInfo :: struct {
    //     tb_handle,
    //     ud_handle,
    //     dd_handle,
    //     dtp_handle : Hwnd,
    // }

// End of API Types

@private dtp_ctor :: proc(p : ^Form, x, y, w, h : int) -> DateTimePicker {   

    if !is_dtp_class_inited { // Then we need to initialize the date class control.
        is_dtp_class_inited = true
        WcDTPClassW = to_wstring("SysDateTimePick32" )
        app.iccx.dwIcc = ICC_DATE_CLASSES
        InitCommonControlsEx(&app.iccx)
    }

    dtp : DateTimePicker
    dtp.kind = .Date_Time_Picker
    dtp.parent = p    
    dtp.font = p.font
    dtp.xpos = x
    dtp.ypos = y
    dtp.width = w
    dtp.height = h  

    dtp._style = 0x52000004 //WS_CHILD|WS_VISIBLE|DTS_LONGDATEFORMAT
    dtp._ex_style = WS_EX_LEFT
    return dtp
}


@private new_dtp1 :: proc(parent : ^Form) -> DateTimePicker {
    d := dtp_ctor(parent, 10, 10, 120, 30)
    return d
}

@private new_dtp2 :: proc(parent : ^Form, x, y : int) -> DateTimePicker {
    d := dtp_ctor(parent, x, y, 120, 30)
    return d
}

@private new_dtp3 :: proc(parent : ^Form, x, y, w, h : int) -> DateTimePicker {
    d := dtp_ctor(parent,x, y, w, h)    
    return d
}

// DateTimePicker constructor.
new_datetimepicker :: proc{new_dtp1, new_dtp2, new_dtp3}

@private set_style_internal :: proc(dtp : ^DateTimePicker) {
    switch dtp.format {
        case .Custom :
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATEFORMAT | DTS_APPCANPARSE 
        case .Long :
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_LONGDATEFORMAT
        case .Short :
            if dtp.four_digit_year { 
                dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATECENTURYFORMAT 
            } else {
                dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATEFORMAT 
            }
        case .Time :
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_TIMEFORMAT        
    }
    
    if dtp.show_week_num do dtp._cal_style |= MCS_WEEKNUMBERS
    if dtp.no_today_circle do dtp._cal_style |= MCS_NOTODAYCIRCLE
    if dtp.no_today do dtp._cal_style |= MCS_NOTODAY
    if dtp.no_trailing_dates do dtp._cal_style |= MCS_NOTRAILINGDATES
    if dtp.short_day_names do dtp._cal_style |= MCS_SHORTDAYSOFWEEK

    if dtp.right_align do dtp._style |= DTS_RIGHTALIGN
    if dtp.show_updown do dtp._style ~= DTS_UPDOWN

}
    


// @private get_dtp_info :: proc(dp : ^DateTimePicker) {
//     di : DATETIMEPICKERINFO
//     di.cbSize = size_of(di)
//     SendMessage(dp.handle, DTM_GETDATETIMEPICKERINFO, Wparam(0), direct_cast(&di, Lparam ))    
//     using dp._dtp_info
//     tb_handle = di.hwndEdit
//     ud_handle = di.hwndUD
//     dd_handle = di.hwndDropDown
//     dtp_handle = dp.handle    
   
// }

// print_dtpinfo :: proc(di : DtpInfo) {
//     ptf("Edit Handle - %d\n", di.tb_handle)
//     ptf("Updown Handle - %d\n", di.ud_handle)
//     ptf("Dropdown Handle - %d\n", di.dd_handle)
//     ptf("Dtp Handle - %d\n", di.dtp_handle)
//     print("---------------------------------------------------")
// }

// Set custom date format for a DTP control.
// To see how to create a custom format, see the docs.
set_dtp_custom_format :: proc(dtp : ^DateTimePicker, fmt_string : string) {
    dtp.format_string = fmt_string
    dtp.format = .Custom
    if dtp._is_created {        
        SendMessage(dtp.handle, DTM_SETFORMATW, 0, convert_to(Lparam, to_wstring(dtp.format_string)))
    } 
}

// Create handle of a DateTimePicker control.
create_datetimepicker :: proc(dtp : ^DateTimePicker) {
    _global_ctl_id += 1     
    dtp.control_id = _global_ctl_id 
    set_style_internal(dtp)
    dtp.handle = CreateWindowEx(  dtp._ex_style, 
                                    WcDTPClassW, 
                                    to_wstring(dtp.text),
                                    dtp._style, 
                                    i32(dtp.xpos), 
                                    i32(dtp.ypos), 
                                    i32(dtp.width), 
                                    i32(dtp.height),
                                    dtp.parent.handle, 
                                    direct_cast(dtp.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if dtp.handle != nil {
        // print("dtp handle - ", dtp.handle)
        
        dtp._is_created = true
        setfont_internal(dtp)
        set_subclass(dtp, dtp_wnd_proc) 
        if dtp.format == .Custom {          
            SendMessage(dtp.handle, DTM_SETFORMATW, 0, convert_to(Lparam, to_wstring(dtp.format_string)))
        }  
        if dtp._cal_style > 0 {
            SendMessage(dtp.handle, DTM_SETMCSTYLE, 0, direct_cast(dtp._cal_style, Lparam))
        } 
        //print("month cal style - ", mst)
        //print_dtpinfo(dtp._dtp_info)
    }
}


@private dtp_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {        
    context = runtime.default_context()
    dtp := control_cast(DateTimePicker, ref_data)
    //display_msg(msg)
    switch msg {   
        case WM_PAINT :
            if dtp.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                dtp.paint(dtp, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case CM_NOTIFY :
            nm := direct_cast(lp, ^NMHDR)
            switch nm.code {
                case DtnUserStr :                      
                    if dtp.text_changed != nil {
                        dts := direct_cast(lp, ^NMDATETIMESTRINGW)
                        dtea : DateTimeEvent
                        dtea.date_string = wstring_to_utf8(dts.pszUserString, -1)
                        dtp.text_changed(dtp, &dtea )
                        // After invoking the event, send this message to set the time in dtp
                        if dtea.handled do SendMessage(dtp.handle, DTM_SETSYSTEMTIME, 0, direct_cast(&dtea.dt_struct, Lparam))
                    }
                case DTN_DROPDOWN :
                    if dtp.calendar_opened != nil {
                        ea := new_event_args()
                        dtp.calendar_opened(dtp, &ea)
                        return 0
                    }

                case DTN_DATETIMECHANGE :
                    // For unknown reason, this notification occures two times.
                    // So we need to use an integer value to limit it once and only.
                    if dtp._value_change_count == 0 {
                        dtp._value_change_count = 1
                        dtc := direct_cast(lp, ^NMDATETIMECHANGE)
                        dtp.value = systime_to_datetime(dtc.st)                    
                        if dtp.value_changed != nil {
                            ea := new_event_args()
                            dtp.value_changed(dtp, &ea)
                            return 0
                        }
                    } else if dtp._value_change_count == 1 {
                        dtp._value_change_count = 0
                        return 0
                    }
                    return 0

                case DTN_CLOSEUP :
                    if dtp.calendar_closed != nil {
                        ea := new_event_args()
                        dtp.calendar_closed(dtp, &ea)
                    }
            }

        case WM_LBUTTONDOWN:                       
            dtp._mdown_happened = true            
            if dtp.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.left_mouse_down(dtp, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            dtp._mrdown_happened = true
            if dtp.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.right_mouse_down(dtp, &mea)
            }

        case WM_LBUTTONUP :     
            if dtp.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.left_mouse_up(dtp, &mea)
            }
            if dtp._mdown_happened {
                dtp._mdown_happened = false
                SendMessage(dtp.handle, CM_LMOUSECLICK, 0, 0)    
            }         

        case CM_LMOUSECLICK :
            dtp._mdown_happened = false
            if dtp.mouse_click != nil {
                ea := new_event_args()
                dtp.mouse_click(dtp, &ea)
                return 0
            }
        
        case WM_LBUTTONDBLCLK :
            if dtp.double_click != nil {
                ea := new_event_args()
                dtp.double_click(dtp, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if dtp.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.right_mouse_up(dtp, &mea)
            }
            if dtp._mrdown_happened {
                dtp._mrdown_happened = false
                SendMessage(dtp.handle, CM_RMOUSECLICK, 0, 0) 
            }
            
        case CM_RMOUSECLICK :
            dtp._mrdown_happened = false
            if dtp.right_click != nil {
                ea := new_event_args()
                dtp.right_click(dtp, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if dtp.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.mouse_scroll(dtp, &mea)
            }	
            
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if dtp._is_mouse_entered {
                if dtp.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    dtp.mouse_move(dtp, &mea)                    
                }
            }
            else {
                dtp._is_mouse_entered = true
                if dtp.mouse_enter != nil  {
                    ea := new_event_args()
                    dtp.mouse_enter(dtp, &ea)                    
                }
            }
        
        case WM_MOUSELEAVE :            
            dtp._is_mouse_entered = false
            if dtp.mouse_leave != nil {               
                ea := new_event_args()
                dtp.mouse_leave(dtp, &ea)                
            } 

        
           

        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}


