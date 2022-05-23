// Doc for DateTimePicker type

DateTimePicker :: struct {
    using control : Control, 
    format : DtpFormat, // time format to display
                // Possible values - {Long = 1, Short = 2, Time = 4, Custom = 8}
                
    format_string : string, // Custom format string for dtp.
				/* Format string Examples
					* To display 29-05-2022 - use dd-MM-yyyy
					* To display 05:35:41 AM - use hh:mm:ss tt
					* To display 24Hrs format - use HH:mm:ss
					* To display custom text, use text in single quotes.
						-e.g: To display Select Time : 05:35:40 - use 'Select Time - 'hh:mm:ss				
				*/
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
    // Besides these properties, DTP supports almost all common properties of Control type.

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
    // Besides these events, DTP supports almost all common events of Control type.
}

// Constructors
new_datetimepicker :: proc(parent : ^Form) -> DateTimePicker
new_datetimepicker :: proc(parent : ^Form, x, y : int) -> DateTimePicker
new_datetimepicker :: proc(parent : ^Form, x, y, w, h : int) -> DateTimePicker

// Functions
create_control :: proc(c : ^Control) // To create DTP
set_dtp_custom_format :: proc(dtp : ^DateTimePicker, fmt_string : string) 
        /* To set custom format in datetimepicker
            ----Parameter
                1. dtp - Pointer to the DateTimePicker struct
                2. fmt_string - A string value. Please see the above link to know more.
        */

dtp_set_value :: proc(dtp : ^DateTimePicker, dt_value : DateTime) // Set the time in dtp
    /* Parameter
            1. dtp - Pointer to the DateTimePicker struct
            2. dt_value - A DateTime value to be set in dtp.
    */


// Example code
// This code assumes frm is a Form struct.
dtp = new_datetimepicker(&frm, 20, 50, 180, 30) // Create a dtp struct with given location & size
dtp.format = DtpFormat.Custom   // Set the dtp format to custom
dtp.format_string = "'Time - 'HH:mm:ss"     // Set the format string.(Note the single quotes)
create_control(&dtp)    // Create the dtp control.