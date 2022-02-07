// Documentation for Calendar type.
Calendar :: struct {
    using control : Control,
    value : DateTime, // See DateTime type.
    view_mode : ViewMode, //  values - Month, Year, Decade, Centuary
    old_view : ViewMode, // values - same as above
    show_week_num : b64, // To show the week numbers in left side of the Calendar.
    no_today_circle : b64, // No circle or square around today
    no_today : b64, //  today won't be showed in Calendar
    no_trailing_dates : b64, // Do not show next & previous month dates
    short_day_names : b64,  // Day names appear as in short forms

    //Events
    value_changed, // When user change the date value 
    view_changed, // When user change the view mode
    // when user change the selection (probably with arrow keys.)
    selection_changed : EventHandler,
}
// Constructors
new_calendar :: proc(parent : ^Form) -> Calendar
new_calendar :: proc(parent : ^Form, x, y : int) -> Calendar

// Functions
create_calendar :: proc(cal : ^Calendar) // Create the handle of Calendar control.



