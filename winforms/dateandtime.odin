package winforms

import "core:fmt"

DateTime :: struct
{
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond : int,
    dayOfWeek : WeekDays,
}



new_date_time :: proc{dt_ctor, dt_ctor2}

@private dt_ctor :: proc() -> DateTime 
{
    dt : DateTime
    st : SYSTEMTIME
    GetLocalTime(&st)
    dt.year = int(st.wYear)
    dt.month = int(st.wMonth)
    dt.day = int(st.wDay)
    dt.hour = int(st.wHour)
    dt.minute = int(st.wMinute)
    dt.second = int(st.wSecond)
    dt.millisecond = int(st.wMilliseconds)
    dt.dayOfWeek = WeekDays(st.wDayOfWeek)
    //ptf("wHour - %d\n", st.wHour)
    return dt
}

@private
dt_ctor2 :: proc(iYear, iMonth, iDay, iHour, iMin, iSec : int) -> DateTime 
{
    dt : DateTime
    dt.year = iYear
    dt.month = iMonth
    dt.day = iDay
    dt.hour = iHour
    dt.minute = iMin
    dt.second = iSec
    dt.millisecond = 0
    dt.dayOfWeek = WeekDays(0)
    return dt
}

@private
systime_to_datetime :: proc(st : SYSTEMTIME) -> DateTime 
{
    dt : DateTime
    dt.year = int(st.wYear)
    dt.month = int(st.wMonth)
    dt.day = int(st.wDay)
    dt.hour = int(st.wHour)
    dt.minute = int(st.wMinute)
    dt.second = int(st.wSecond)
    dt.millisecond = int(st.wMilliseconds)
    dt.dayOfWeek = WeekDays(st.wDayOfWeek)
    return dt
}

@private
datetime_to_systime :: proc(dt : DateTime) -> SYSTEMTIME 
{
    st : SYSTEMTIME
    st.wYear = WORD(dt.year)
    st.wMonth = WORD(dt.month)
    st.wDay = WORD(dt.day)
    st.wHour = WORD(dt.hour)
    st.wMinute = WORD(dt.minute)
    st.wSecond = WORD(dt.second)
    st.wMilliseconds = WORD(dt.millisecond)
    st.wDayOfWeek = WORD(dt.dayOfWeek)
    return st
}

current_time :: proc() -> DateTime { return dt_ctor() }

datetime_string :: proc(dt : DateTime) -> string 
{
    return fmt.tprintf(  "%2d-%2d-%4d %2d:%2d:%2d", dt.day, dt.month, dt.year, dt.hour, dt.minute, dt.second)
}

date_string ::proc(dt : DateTime) -> string 
{
    return fmt.tprintf(  "%2d-%2d-%4d", dt.day, dt.month, dt.year)
}

sleep :: proc(msec : int) {Sleep(DWORD(msec))}

print_time :: proc(dt : DateTime) 
{
    ptf("Year - %d\n", dt.year)
    ptf("Month - %d\n", dt.month)
    ptf("Day - %d\n", dt.day)
    ptf("Hour - %d\n", dt.hour)
    ptf("Minute - %d\n", dt.minute)
    ptf("Second - %d\n", dt.second)
    ptf("Milliseconds - %d\n", dt.millisecond)
    ptf("Day of the week - %s\n", dt.dayOfWeek)
}

print_systime :: proc(st : SYSTEMTIME) 
{
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