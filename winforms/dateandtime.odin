package winforms

import "core:fmt"

DateTime :: struct{
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond : int,
    day_of_week : WeekDays,
}

WeekDays :: enum {sunday, monday, tuesday, wednesday, thursday, friday, saturday }

@private dt_ctor :: proc() -> DateTime {
    dt : DateTime
    st : SYSTEMTIME
    get_local_time(&st)
    dt.year = int(st.wYear)
    dt.month = int(st.wMonth)
    dt.day = int(st.wDay)
    dt.hour = int(st.wHour)
    dt.minute = int(st.wMinute)
    dt.second = int(st.wSecond)
    dt.millisecond = int(st.wMilliseconds)
    dt.day_of_week = WeekDays(st.wDayOfWeek)
    //ptf("wHour - %d\n", st.wHour)
    return dt
}

@private systime_to_datetime :: proc(st : SYSTEMTIME) -> DateTime {
    dt : DateTime
    dt.year = int(st.wYear)
    dt.month = int(st.wMonth)
    dt.day = int(st.wDay)
    dt.hour = int(st.wHour)
    dt.minute = int(st.wMinute)
    dt.second = int(st.wSecond)
    dt.millisecond = int(st.wMilliseconds)
    dt.day_of_week = WeekDays(st.wDayOfWeek)   
    return dt
}

current_time :: proc() -> DateTime {
    return dt_ctor()
}

datetime_string :: proc(dt : DateTime) -> string {
    return fmt.tprintf(  "%2d-%2d-%4d %2d:%2d:%2d", dt.day, dt.month, dt.year, dt.hour, dt.minute, dt.second)
}

date_string ::proc(dt : DateTime) -> string {
    return fmt.tprintf(  "%2d-%2d-%4d", dt.day, dt.month, dt.year)
}

print_time :: proc(dt : DateTime) {
    ptf("Year - %d\n", dt.year)
    ptf("Month - %d\n", dt.month)
    ptf("Day - %d\n", dt.day)
    ptf("Hour - %d\n", dt.hour)
    ptf("Minute - %d\n", dt.minute)
    ptf("Second - %d\n", dt.second)
    ptf("Milliseconds - %d\n", dt.millisecond)
    ptf("Day of the week - %s\n", dt.day_of_week)
}

print_systime :: proc(st : SYSTEMTIME) {
    ptf("Year - %d\n", st.wYear)
    ptf("Month - %d\n", st.wMonth)
    ptf("Day - %d\n", st.wDay)
    ptf("Hour - %d\n", st.wHour)
    ptf("Minute - %d\n", st.wMinute)
    ptf("Second - %d\n", st.wSecond)
    ptf("Milliseconds - %d\n", st.wMilliseconds)
    ptf("Day of the week - %d\n", st.wDayOfWeek)
    print("----------------------------------------------------")
}