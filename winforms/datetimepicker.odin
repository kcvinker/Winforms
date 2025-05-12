
/*===========================DateTimePicker Docs==============================
    DateTimePicker struct
        Constructor: new_datetimepicker() -> ^DateTimePicker
        Properties:
            All props from Control struct
            format         : DtpFormat
            formatString   : string
            rightAlign     : b64
            fourDigitYear  : b64
            value          : DateTime
            showWeekNum    : b64
            noTodayCircle  : b64
            noToday        : b64
            noTrailingDates: b64
            showUpdown     : b64
            shortDayNames  : b64
        Functions:
            dtp_set_value
            dtp_set_custom_format

        Events:
            EventHandler type -proc(^Control, ^EventArgs) [See events.odin]
                onCalendarOpened
                onValueChanged
                onCalendarClosed            
            DateTimeEventHandler type -proc(^TrayIcon, ^DateTimeEventArgs) [See events.odin]
                 onTextChanged 
        
===============================================================================*/


package winforms		// Notes: write func for setting value by user.

// import "core:strings"
import "core:fmt"
import "base:runtime"


isDtpClassInit: bool = false
WcDTPClassW: wstring = L("SysDateTimePick32")


// Date time time format for DTP control.
// Possible values: long = 1, short = 2, time = 4, custom = 8
DtpFormat:: enum {Long = 1, Short = 2, Time = 4, Custom = 8}

DateTimePicker:: struct
{
    using control: Control,
    format: DtpFormat,
    formatString: string,
    rightAlign: b64,
    fourDigitYear: b64,
    value: DateTime,
    showWeekNum: b64,
    noTodayCircle: b64,
    noToday: b64,
    noTrailingDates: b64,
    showUpdown: b64,
    shortDayNames: b64,

   // _fmt_str: string,
    _valueChangeCount: int,
    _bkBrush: HBRUSH,
    _calStyle: DWORD,

    onCalendarOpened,
    onValueChanged,
    onCalendarClosed: EventHandler,
    onTextChanged: DateTimeEventHandler,
}

// DateTimePicker constructor.
new_datetimepicker:: proc{new_dtp1, new_dtp2, new_dtp3}

dtp_set_value:: proc(dtp: ^DateTimePicker, dt_value: DateTime)
{
    dtp.value = dt_value
    if dtp._isCreated {
        sysTm:= datetime_to_systime(dt_value)
        SendMessage(dtp.handle, DTM_SETSYSTEMTIME, 0, dir_cast(&sysTm, LPARAM))
    }
}

dtp_set_custom_format:: proc(dtp: ^DateTimePicker, fmt_string: string)
{
    dtp.formatString = fmt_string
    dtp.format = .Custom
    if dtp._isCreated {
        SendMessage(dtp.handle, DTM_SETFORMATW, 0, convert_to(LPARAM, to_wstring(dtp.formatString)))
        // free_all(context.temp_allocator)
    }
}

//==================================Private Functions========================
@private dtp_ctor:: proc(p: ^Form, x, y, w, h: int) -> ^DateTimePicker
{
    if !isDtpClassInit { // global var of this module. Then we need to initialize the date class control.
        isDtpClassInit = true
        app.iccx.dwIcc = ICC_DATE_CLASSES
        InitCommonControlsEx(&app.iccx)
        // print("inited comctrlex")
    }
    dtp:= new(DateTimePicker)
    dtp.kind = .Date_Time_Picker
    dtp.text = ""
    dtp.parent = p
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
    font_clone(&p.font, &dtp.font )
    append(&p._controls, dtp)
    return dtp
}

@private new_dtp1:: proc(parent: ^Form) -> ^DateTimePicker
{
    dtp:= dtp_ctor(parent, 10, 10, 120, 30 )
    if parent.createChilds do create_control(dtp)
    return dtp
}

@private new_dtp2:: proc(parent: ^Form, x, y: int) -> ^DateTimePicker
{
    dtp:= dtp_ctor(parent, x, y, 120, 30)
    if parent.createChilds do create_control(dtp)
    return dtp
}

@private new_dtp3:: proc(parent: ^Form, x, y, w, h: int) -> ^DateTimePicker
{
    dtp:= dtp_ctor(parent,x, y, w, h)
    if parent.createChilds do create_control(dtp)
    return dtp
}

@private set_dtp_style_internal:: proc(dtp: ^DateTimePicker)
{
    switch dtp.format {
        case .Custom:
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATEFORMAT | DTS_APPCANPARSE
        case .Long:
            dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_LONGDATEFORMAT
        case .Short:
            if dtp.fourDigitYear {
                dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATECENTURYFORMAT
            } else {
                dtp._style = WS_TABSTOP | WS_CHILD|WS_VISIBLE|DTS_SHORTDATEFORMAT
            }
        case .Time:
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

// @private get_dtp_info:: proc(dp: ^DateTimePicker) {
//     di: DATETIMEPICKERINFO
//     di.cbSize = size_of(di)
//     SendMessage(dp.handle, DTM_GETDATETIMEPICKERINFO, WPARAM(0), dir_cast(&di, LPARAM ))
//     using dp._dtp_info
//     tb_handle = di.hwndEdit
//     ud_handle = di.hwndUD
//     dd_handle = di.hwndDropDown
//     dtp_handle = dp.handle

// }

// print_dtpinfo:: proc(di: DtpInfo) {
//     ptf("Edit HANDLE - %d\n", di.tb_handle)
//     ptf("Updown HANDLE - %d\n", di.ud_handle)
//     ptf("Dropdown HANDLE - %d\n", di.dd_handle)
//     ptf("Dtp HANDLE - %d\n", di.dtp_handle)
//     print("---------------------------------------------------")
// }

// Set custom date format for a DTP control.
// To see how to create a custom format, see the docs.

@private dtp_before_creation:: proc(dtp: ^DateTimePicker) {set_dtp_style_internal(dtp)}

@private dtp_after_creation:: proc(dtp: ^DateTimePicker)
{
    // print("dtp creation ended")
    set_subclass(dtp, dtp_wnd_proc)
    if dtp.format == .Custom {
		fmt_str:= fmt.tprintf("%v\x00", dtp.formatString)	// Creating a null terminated string.
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

@private set_dtp_size:: proc(dtp: ^Control)
{
    ss: SIZE
    SendMessage(dtp.handle, DTM_GETIDEALSIZE, 0, to_lparam(&ss))
    dtp.width = int(ss.width + 3)
    dtp.height = int(ss.height )
    SetWindowPos(dtp.handle, nil, dtp.xpos, dtp.ypos, dtp.width, dtp.height, SWP_NOZORDER)
}


@private dtp_property_setter:: proc(this: ^DateTimePicker, prop: DTPProps, value: $T)
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
                st:= datetime_to_systime(value)
                SendMessage(this.handle, DTM_SETSYSTEMTIME, 0, LPARAM(&st))
            }
        case .Show_Updown: break
    }
}


@private dtp_finalize:: proc(this: ^DateTimePicker, scid: UINT_PTR)
{
    RemoveWindowSubclass(this.handle, dtp_wnd_proc, scid)
    font_destroy(&this.font)
    free(this)
}

@private
dtp_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    // context = runtime.default_context()
    context = global_context
    
    //display_msg(msg)
    switch msg {
        case WM_DESTROY: 
            dtp:= control_cast(DateTimePicker, ref_data)
            dtp_finalize(dtp, sc_id)

        case WM_PAINT:
            dtp:= control_cast(DateTimePicker, ref_data)
            if dtp.onPaint != nil {
                ps: PAINTSTRUCT
                hdc:= BeginPaint(hw, &ps)
                pea:= new_paint_event_args(&ps)
                dtp.onPaint(dtp, &pea)
                EndPaint(hw, &ps)
                return 0
            }

        case WM_CONTEXTMENU:
            dtp:= control_cast(DateTimePicker, ref_data)
		    if dtp.contextMenu != nil do contextmenu_show(dtp.contextMenu, lp)

        case CM_NOTIFY:
            dtp:= control_cast(DateTimePicker, ref_data)
            nm:= dir_cast(lp, ^NMHDR)
            switch nm.code {
                case DtnUserStr:
                    if dtp.onTextChanged != nil {
                        dts:= dir_cast(lp, ^NMDATETIMESTRINGW)
                        dtea: DateTimeEventArgs
                        dtea.dateString = wstring_to_string(dts.pszUserString)
                        dtp.onTextChanged(dtp, &dtea )
                        // After invoking the event, send this message to set the time in dtp
                        if dtea.handled do SendMessage(dtp.handle, DTM_SETSYSTEMTIME, 0, dir_cast(&dtea.dateStruct, LPARAM))
                        // free_all(context.temp_allocator)

                    }
                case DTN_DROPDOWN:
                    if dtp.onCalendarOpened != nil {
                        ea:= new_event_args()
                        dtp.onCalendarOpened(dtp, &ea)
                        return 0
                    }

                case DTN_DATETIMECHANGE:
                    // For unknown reason, this notification occures two times.
                    // So we need to use an integer value to limit it once and only.
                    if dtp._valueChangeCount == 0 {
                        dtp._valueChangeCount = 1
                        dtc:= dir_cast(lp, ^NMDATETIMECHANGE)
                        dtp.value = systime_to_datetime(dtc.st)
                        if dtp.onValueChanged != nil {
                            ea:= new_event_args()
                            dtp.onValueChanged(dtp, &ea)
                            return 0
                        }
                    } else if dtp._valueChangeCount == 1 {
                        dtp._valueChangeCount = 0
                        return 0
                    }
                    return 0

                case DTN_CLOSEUP:
                    if dtp.onCalendarClosed != nil {
                        ea:= new_event_args()
                        dtp.onCalendarClosed(dtp, &ea)
                    }
            }

        case WM_LBUTTONDOWN:   
            dtp:= control_cast(DateTimePicker, ref_data)         
            if dtp.onMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                dtp.onMouseDown(dtp, &mea)
                return 0
            }

        case WM_RBUTTONDOWN: 
            dtp:= control_cast(DateTimePicker, ref_data)           
            if dtp.onRightMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                dtp.onRightMouseDown(dtp, &mea)
            }

        case WM_LBUTTONUP:
            dtp:= control_cast(DateTimePicker, ref_data)
            if dtp.onMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                dtp.onMouseUp(dtp, &mea)
            }  
            if dtp.onClick != nil {
                ea:= new_event_args()
                dtp.onClick(dtp, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK:
            dtp:= control_cast(DateTimePicker, ref_data)
            if dtp.onDoubleClick != nil {
                ea:= new_event_args()
                dtp.onDoubleClick(dtp, &ea)
                return 0
            }

        case WM_RBUTTONUP:
            dtp:= control_cast(DateTimePicker, ref_data)
            if dtp.onRightMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                dtp.onRightMouseUp(dtp, &mea)
            }            
            if dtp.onRightClick != nil {
                ea:= new_event_args()
                dtp.onRightClick(dtp, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            dtp:= control_cast(DateTimePicker, ref_data)
            if dtp.onMouseScroll != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                dtp.onMouseScroll(dtp, &mea)
            }

        case WM_MOUSEMOVE: // Mouse Enter & Mouse Move is happening here.
            dtp:= control_cast(DateTimePicker, ref_data)
            if dtp._isMouseEntered {
                if dtp.onMouseMove != nil {
                    mea:= new_mouse_event_args(msg, wp, lp)
                    dtp.onMouseMove(dtp, &mea)
                }
            }
            else {
                dtp._isMouseEntered = true
                if dtp.onMouseEnter != nil  {
                    ea:= new_event_args()
                    dtp.onMouseEnter(dtp, &ea)
                }
            }

        case WM_MOUSELEAVE:
            dtp:= control_cast(DateTimePicker, ref_data)
            dtp._isMouseEntered = false
            if dtp.onMouseLeave != nil {
                ea:= new_event_args()
                dtp.onMouseLeave(dtp, &ea)
            }

        case: return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}


