/*
    Created on : 01-Feb-2022 06:30 AM
    Name : MsgBox functions
*/

package winforms
import "core:fmt"

def_msg_title := to_wstring("Winforms")
dummy_hwnd := Hwnd(cast(uintptr) 0)

MsgResult :: enum { none, okay, canel, abort, retry, ignore, yes, no }
MsgBoxButtons :: enum {okay, ok_cancel, abort_retry_ignore, yes_no_cancel, yes_no, retry_cancel }
MsgBoxIcons :: enum {
    none = 0,
    hand = 16,
    stop = 16,  
    error = 16,
    question = 32,
    exclamation = 48,
    warning = 48,
    asterisk = 64,
    information = 64,
}
MsgBoxDefButton :: enum {button1 = 0, button2 = 256, button3 = 512}
// MsgBoxOptions :: enum {
//     def_desktop = 131072,
//     right_align = 524288,
//     rtl_reading = 1048576,
//     service_notify = 2097152,
// }

msg_box :: proc{    msg_box1, 
                    msg_box2, 
                    msg_box3, 
                    msg_box4,
                    msg_box5,
                    msg_box6,
                }

@private msg_box1 :: proc(msg : string) {     
    message_box(dummy_hwnd, to_wstring(msg), def_msg_title, 0) 
}

@private msg_box2 :: proc(msg : string, title : string) { 
    message_box(dummy_hwnd, to_wstring(msg), to_wstring(title), 0) 
}

@private msg_box3 :: proc(msg : any) {
	ms_str := fmt.tprint(msg)	
	message_box(dummy_hwnd, to_wstring(ms_str), def_msg_title, 0)
}
@private msg_box4 :: proc(msg : any, title : string) {
	ms_str := fmt.tprint(msg)	
	message_box(dummy_hwnd, to_wstring(ms_str), to_wstring(title), 0)
}

@private msg_box5 :: proc(msg : any, title : string, msg_btn : MsgBoxButtons) -> MsgResult {
    ms_str := to_wstring(fmt.tprint(msg))
    cap_str : wstring
    if len(title) == 0 {
        cap_str = def_msg_title
    } else do cap_str = to_wstring(title)
    return MsgResult(message_box(dummy_hwnd, ms_str, cap_str, u32(msg_btn) ))
}

@private msg_box6 :: proc(msg : any, title : string, msg_btn : MsgBoxButtons, ms_icon : MsgBoxIcons) -> MsgResult {
    ms_str := to_wstring(fmt.tprint(msg))
    cap_str : wstring
    if len(title) == 0 {
        cap_str = def_msg_title
    } else do cap_str = to_wstring(title)
    utype : u32 = u32(msg_btn) | u32(ms_icon)
    return MsgResult(message_box(dummy_hwnd, ms_str, cap_str, utype ))
}
