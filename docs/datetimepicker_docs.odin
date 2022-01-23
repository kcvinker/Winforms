// Doc for DateTimePicker type

DateTimePicker :: struct {
    using control : Control, 
    format : DtpFormat, // time format to display
                // Possible values - {long = 1, short = 2, time = 4, custom = 8}
                
    format_string : string, // Custom format string for dtp.
                // See this page to know more about custom format strings
                // https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.datetimepicker.customformat?view=windowsdesktop-6.0

    right_align : b64, // Text will be right aligned
    four_digit_year : b64,  // Year will be displayed in four digit. Only work in 'short' format.
    value : DateTime,   // The date value
    show_week_num : b64, // Show week numbers on the left side of calendar
    no_today_circle : b64, // No cirecle around today
    no_today : b64, // No today will be displayed
    no_trailing_dates : b64, // No prevoious & next month dates displayed
    show_updown : b64, // To show an updown control to change the date
    short_day_names : b64, // day names will be displayed in shor forms.

    // Events
    calendar_opened, // when calendar control opened
    value_changed,    // when user change date/ time value
    calendar_closed : EventHandler, // when calendar control closed
    text_changed : DateTimeEventHandler, // when text changed in text area.
        // DateTimeEventHandler - signature - proc(sender : ^Control, e : ^DateTimeEvent)
        // DateTimeEvent 
        DateTimeEvent :: struct {
            using base : EventArgs,
            date_string : string, // date string which user typed
            dt_struct : SYSTEMTIME, // a date & time structure by Win32 API        
        }
        /*
            typedef struct _SYSTEMTIME {
                WORD wYear;
                WORD wMonth;
                WORD wDayOfWeek;
                WORD wDay;
                WORD wHour;
                WORD wMinute;
                WORD wSecond;
                WORD wMilliseconds;
                } SYSTEMTIME
        */
}

// Constructors
new_datetimepicker :: proc(parent : ^Form) -> DateTimePicker
new_datetimepicker :: proc(parent : ^Form, w, h, x, y : int) -> DateTimePicker

// Functions
create_datetimepicker :: proc(dtp : ^DateTimePicker) // create dtp handle
set_dtp_custom_format :: proc(dtp : ^DateTimePicker, fmt_string : string) 
        // To set custom format in datetimepicker
        // Parameter
            // fmt_string - A string value. Please see the above link to know more.

