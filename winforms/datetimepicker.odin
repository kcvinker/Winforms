
package winforms		// Notes : write func for setting value by user.

// import "core:strings"
import "core:fmt"
import "base:runtime"

ICC_DATE_CLASSES :: 0x100
DTM_GETIDEALSIZE :: (DTM_FIRST+15)
isDtpClassInit : bool = false
WcDTPClassW : wstring = L("SysDateTimePick32")

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
	DTM_SETFORMATA :: 0x1005
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

DateTimePicker :: struct
{
    using control : Control,
    format : DtpFormat,
    formatString : string,
    rightAlign : b64,
    fourDigitYear : b64,
    value : DateTime,
    showWeekNum : b64,
    noTodayCircle : b64,
    noToday : b64,
    noTrailingDates : b64,
    showUpdown : b64,
    shortDayNames : b64,

   // _fmt_str : string,
    _valueChangeCount : int,
    _bkBrush : HBRUSH,
    _calStyle : DWORD,

    onCalendarOpened,
    onValueChanged,
    onCalendarClosed : EventHandler,
    onTextChanged : DateTimeEventHandler,
}

// DateTimePicker constructor.
new_datetimepicker :: proc{new_dtp1, new_dtp2, new_dtp3}

dtp_set_value :: proc(dtp : ^DateTimePicker, dt_value : DateTime)
{
    dtp.value = dt_value
    if dtp._isCreated {
        sysTm := datetime_to_systime(dt_value)
        SendMessage(dtp.handle, DTM_SETSYSTEMTIME, 0, dir_cast(&sysTm, LPARAM))
    }
}

dtp_set_custom_format :: proc(dtp : ^DateTimePicker, fmt_string : string)
{
    dtp.formatString = fmt_string
    dtp.format = .Custom
    if dtp._isCreated {
        SendMessage(dtp.handle, DTM_SETFORMATW, 0, convert_to(LPARAM, to_wstring(dtp.formatString)))
        // free_all(context.temp_allocator)
    }
}

// Api Types
    NMDATETIMECHANGE :: struct
    {
        nmhdr : NMHDR,
        dwFlags : DWORD,
        st : SYSTEMTIME,
    }

    NMDATETIMESTRINGW :: struct
    {
        nmhdr :  NMHDR,
        pszUserString : wstring,
        st : SYSTEMTIME,
        dwFlags : DWORD,
    }

    // DATETIMEPICKERINFO :: struct {
    //     cbSize : DWORD,
    //     rcCheck : RECT,
    //     stateCheck : DWORD,
    //     rcButton : RECT,
    //     stateButton : DWORD,
    //     hwndEdit : HWND,
    //     hwndUD : HWND,
    //     hwndDropDown : HWND,
    // }

    // DtpInfo :: struct {
    //     tb_handle,
    //     ud_handle,
    //     dd_handle,
    //     dtp_handle : HWND,
    // }

// End of API Types

@private dtp_ctor :: proc(p : ^Form, x, y, w, h : int) -> ^DateTimePicker
{
    if !isDtpClassInit { // global var of this module. Then we need to initialize the date class control.
        isDtpClassInit = true
        app.iccx.dwIcc = ICC_DATE_CLASSES
        InitCommonControlsEx(&app.iccx)
        // print("inited comctrlex")
    }
    dtp := new(DateTimePicker)
    dtp.kind = .Date_Time_Picker
    dtp.text = ""
    dtp.parent = p
    dtp.font = p.font
    dtp.xpos = x
    dtp.ypos = y
    dtp.width = w
    dtp.height = h
    dtp._clsName = WcDTPClassW
    dtp.format = .Custom
    dtp._fp_size_fix = set_dtp_size
    dtp.formatString = " dd-MMM-yyyy"
    dtp._fp_beforeCreation = cast(CreateDelegate) dtp_before_creation
	dtp._fp_afterCreation = cast(CreateDelegate) dtp_after_creation

    dtp._style = 0x52000004 //WS_CHILD|WS_VISIBLE|DTS_LONGDATEFORMAT
    dtp._exStyle = WS_EX_LEFT
    append(&p._controls, dtp)
    return dtp
}

@private new_dtp1 :: proc(parent : ^Form, autoc: b8 = false) -> ^DateTimePicker
{
    dtp := dtp_ctor(parent, 10, 10, 120, 30 )
    if autoc do create_control(dtp)
    return dtp
}

@private new_dtp2 :: proc(parent : ^Form, x, y : int, autoc: b8 = false) -> ^DateTimePicker
{
    dtp := dtp_ctor(parent, x, y, 120, 30)
    if autoc do create_control(dtp)
    return dtp
}

@private new_dtp3 :: proc(parent : ^Form, x, y, w, h : int, autoc: b8 = false) -> ^DateTimePicker
{
    dtp := dtp_ctor(parent,x, y, w, h)
    if autoc do create_control(dtp)
    return dtp
}

@private set_dtp_style_internal :: proc(dtp : ^DateTimePicker)
{
    switch dtp.format {
        case .Custom :
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATEFORMAT | DTS_APPCANPARSE
        case .Long :
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_LONGDATEFORMAT
        case .Short :
            if dtp.fourDigitYear {
                dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATECENTURYFORMAT
            } else {
                dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATEFORMAT
            }
        case .Time :
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_TIMEFORMAT
    }

    if dtp.showWeekNum do dtp._calStyle |= MCS_WEEKNUMBERS
    if dtp.noTodayCircle do dtp._calStyle |= MCS_NOTODAYCIRCLE
    if dtp.noToday do dtp._calStyle |= MCS_NOTODAY
    if dtp.noTrailingDates do dtp._calStyle |= MCS_NOTRAILINGDATES
    if dtp.shortDayNames do dtp._calStyle |= MCS_SHORTDAYSOFWEEK

    if dtp.rightAlign do dtp._style |= DTS_RIGHTALIGN
    if dtp.showUpdown do dtp._style ~= DTS_UPDOWN
}

// @private get_dtp_info :: proc(dp : ^DateTimePicker) {
//     di : DATETIMEPICKERINFO
//     di.cbSize = size_of(di)
//     SendMessage(dp.handle, DTM_GETDATETIMEPICKERINFO, WPARAM(0), dir_cast(&di, LPARAM ))
//     using dp._dtp_info
//     tb_handle = di.hwndEdit
//     ud_handle = di.hwndUD
//     dd_handle = di.hwndDropDown
//     dtp_handle = dp.handle

// }

// print_dtpinfo :: proc(di : DtpInfo) {
//     ptf("Edit HANDLE - %d\n", di.tb_handle)
//     ptf("Updown HANDLE - %d\n", di.ud_handle)
//     ptf("Dropdown HANDLE - %d\n", di.dd_handle)
//     ptf("Dtp HANDLE - %d\n", di.dtp_handle)
//     print("---------------------------------------------------")
// }

// Set custom date format for a DTP control.
// To see how to create a custom format, see the docs.

@private dtp_before_creation :: proc(dtp : ^DateTimePicker) {set_dtp_style_internal(dtp)}

@private dtp_after_creation :: proc(dtp : ^DateTimePicker)
{
    // print("dtp creation ended")
    set_subclass(dtp, dtp_wnd_proc)
    if dtp.format == .Custom {
		fmt_str := fmt.tprintf("%v\x00", dtp.formatString)	// Creating a null terminated string.
        SendMessage(dtp.handle, DTM_SETFORMATA, 0, convert_to(LPARAM, raw_data(fmt_str)))
		/*
		Here, we have a strange situation. Since, we are working with unicode string, we need...
		to use the W version functions & messages. So, here DTM_SETFORMATW is the candidate.
		But it won't work. For some unknown reason, only DTM_SETFORMATA is working here. So we need...
		to pass a null terminated c string ptr to this function. Why MS, why ?
		*/
    }
    if dtp._calStyle > 0 {
        SendMessage(dtp.handle, DTM_SETMCSTYLE, 0, dir_cast(dtp._calStyle, LPARAM))
    }

    // Let's make proper size for this dtp
    set_dtp_size(dtp)
}

@private set_dtp_size :: proc(dtp: ^Control)
{
    ss : SIZE
    SendMessage(dtp.handle, DTM_GETIDEALSIZE, 0, to_lparam(&ss))
    dtp.width = int(ss.width + 3)
    dtp.height = int(ss.height )
    SetWindowPos(dtp.handle, nil, dtp.xpos, dtp.ypos, dtp.width, dtp.height, SWP_NOZORDER)
}


@private dtp_property_setter :: proc(this: ^DateTimePicker, prop: DTPProps, value: $T)
{
    switch prop {
        case .Format: break
        case .Format_String:
            when T == string {
                this.formatString = value
                this.format = DtpFormat.Custom
                if this._isCreated {
                    SendMessage(this.handle, DTM_SETFORMATA, 0, LPARAM(to_wstring(value)))
                    // free_all(context.temp_allocator)
                }
            }
        case .Right_Align: break
        case .Four_Digit_Year: break
        case .Value:
            when T == DateTime {
                this.value = value
                st := datetime_to_systime(value)
                SendMessage(this.handle, DTM_SETSYSTEMTIME, 0, LPARAM(&st))
            }
        case .Show_Updown: break
    }
}







@private dtp_finalize :: proc(dtp: ^DateTimePicker, scid: UINT_PTR)
{
    RemoveWindowSubclass(dtp.handle, dtp_wnd_proc, scid)
    free(dtp)
}

@private
dtp_wnd_proc :: proc "fast" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    dtp := control_cast(DateTimePicker, ref_data)
    //display_msg(msg)
    switch msg {
        case WM_DESTROY: dtp_finalize(dtp, sc_id)
        case WM_PAINT :
            if dtp.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                dtp.paint(dtp, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
		    if dtp.contextMenu != nil do contextmenu_show(dtp.contextMenu, lp)

        case CM_NOTIFY :
            nm := dir_cast(lp, ^NMHDR)
            switch nm.code {
                case DtnUserStr :
                    if dtp.onTextChanged != nil {
                        dts := dir_cast(lp, ^NMDATETIMESTRINGW)
                        dtea : DateTimeEvent
                        dtea.dateString = wstring_to_string(dts.pszUserString)
                        dtp.onTextChanged(dtp, &dtea )
                        // After invoking the event, send this message to set the time in dtp
                        if dtea.handled do SendMessage(dtp.handle, DTM_SETSYSTEMTIME, 0, dir_cast(&dtea.dateStruct, LPARAM))
                        // free_all(context.temp_allocator)

                    }
                case DTN_DROPDOWN :
                    if dtp.onCalendarOpened != nil {
                        ea := new_event_args()
                        dtp.onCalendarOpened(dtp, &ea)
                        return 0
                    }

                case DTN_DATETIMECHANGE :
                    // For unknown reason, this notification occures two times.
                    // So we need to use an integer value to limit it once and only.
                    if dtp._valueChangeCount == 0 {
                        dtp._valueChangeCount = 1
                        dtc := dir_cast(lp, ^NMDATETIMECHANGE)
                        dtp.value = systime_to_datetime(dtc.st)
                        if dtp.onValueChanged != nil {
                            ea := new_event_args()
                            dtp.onValueChanged(dtp, &ea)
                            return 0
                        }
                    } else if dtp._valueChangeCount == 1 {
                        dtp._valueChangeCount = 0
                        return 0
                    }
                    return 0

                case DTN_CLOSEUP :
                    if dtp.onCalendarClosed != nil {
                        ea := new_event_args()
                        dtp.onCalendarClosed(dtp, &ea)
                    }
            }

        case WM_LBUTTONDOWN:
            dtp._mDownHappened = true
            if dtp.onMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.onMouseDown(dtp, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            dtp._mRDownHappened = true
            if dtp.onRightMouseDown != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.onRightMouseDown(dtp, &mea)
            }

        case WM_LBUTTONUP :
            if dtp.onMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.onMouseUp(dtp, &mea)
            }
            if dtp._mDownHappened {
                dtp._mDownHappened = false
                SendMessage(dtp.handle, CM_LMOUSECLICK, 0, 0)
            }

        case CM_LMOUSECLICK :
            dtp._mDownHappened = false
            if dtp.onMouseClick != nil {
                ea := new_event_args()
                dtp.onMouseClick(dtp, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK :
            if dtp.onDoubleClick != nil {
                ea := new_event_args()
                dtp.onDoubleClick(dtp, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if dtp.onRightMouseUp != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.onRightMouseUp(dtp, &mea)
            }
            if dtp._mRDownHappened {
                dtp._mRDownHappened = false
                SendMessage(dtp.handle, CM_RMOUSECLICK, 0, 0)
            }

        case CM_RMOUSECLICK :
            dtp._mRDownHappened = false
            if dtp.onRightClick != nil {
                ea := new_event_args()
                dtp.onRightClick(dtp, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if dtp.onMouseScroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                dtp.onMouseScroll(dtp, &mea)
            }

        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if dtp._isMouseEntered {
                if dtp.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    dtp.onMouseMove(dtp, &mea)
                }
            }
            else {
                dtp._isMouseEntered = true
                if dtp.onMouseEnter != nil  {
                    ea := new_event_args()
                    dtp.onMouseEnter(dtp, &ea)
                }
            }

        case WM_MOUSELEAVE :
            dtp._isMouseEntered = false
            if dtp.onMouseLeave != nil {
                ea := new_event_args()
                dtp.onMouseLeave(dtp, &ea)
            }

        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}


