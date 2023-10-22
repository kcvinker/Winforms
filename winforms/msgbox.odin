/*
    Created on : 01-Feb-2022 06:30 AM
    Name : MsgBox functions
*/

package winforms
import "core:fmt"

def_msg_title := to_wstring("Winforms")
dummy_hwnd := HWND(cast(UINT_PTR) 0)

MsgResult :: enum { None, Okay, Canel, Abort, Retry, Ignore, Yes, No }
MsgBoxButtons :: enum {Okay, Ok_Cancel, Abort_Retry_Ignore, Yes_No_Cancel, Yes_No, Retry_Cancel }
MsgBoxIcons :: enum {
    None = 0,
    Hand = 16,
    Stop = 16,
    Error = 16,
    Question = 32,
    Exclamation = 48,
    Warning = 48,
    Asterisk = 64,
    Information = 64,
}
MsgBoxDefButton :: enum {Button1 = 0, Button2 = 256, Button3 = 512}
// MsgBoxOptions :: enum {
//     def_desktop = 131072,
//     right_align = 524288,
//     rtl_reading = 1048576,
//     service_notify = 2097152,
// }

msgbox :: proc{    msgbox1,
                    msgbox2,
                    msgbox3,
                    msgbox4,
                    msgbox5,
                    msgbox6,
                    msgbox7,
                }

@private msgbox1 :: proc(msg : string) {
    MessageBox(dummy_hwnd, to_wstring(msg), def_msg_title, 0)
}

@private msgbox2 :: proc(msg : string, title : string) {
    MessageBox(dummy_hwnd, to_wstring(msg), to_wstring(title), 0)
}

@private msgbox3 :: proc(msg : any) {
	ms_str := fmt.tprint(msg)
	MessageBox(dummy_hwnd, to_wstring(ms_str), def_msg_title, 0)
}
@private msgbox4 :: proc(msg : any, title : string) {
	ms_str := fmt.tprint(msg)
	MessageBox(dummy_hwnd, to_wstring(ms_str), to_wstring(title), 0)
}

@private msgbox5 :: proc(msg : any, title : string, msg_btn : MsgBoxButtons) -> MsgResult {
    ms_str := to_wstring(fmt.tprint(msg))
    cap_str : wstring
    if len(title) == 0 {
        cap_str = def_msg_title
    } else do cap_str = to_wstring(title)
    return MsgResult(MessageBox(dummy_hwnd, ms_str, cap_str, u32(msg_btn) ))
}

@private msgbox6 :: proc(  msg : any,
                            title : string,
                            msg_btn : MsgBoxButtons,
                            ms_icon : MsgBoxIcons ) -> MsgResult
{
    ms_str := to_wstring(fmt.tprint(msg))
    cap_str : wstring
    if len(title) == 0 {
        cap_str = def_msg_title
    } else do cap_str = to_wstring(title)
    utype : u32 = u32(msg_btn) | u32(ms_icon)
    return MsgResult(MessageBox(dummy_hwnd, ms_str, cap_str, utype ))
}


@private msgbox7 :: proc(  msg : any,
                            title : string,
                            msg_btn : MsgBoxButtons,
                            ms_icon : MsgBoxIcons,
                            def_btn : MsgBoxDefButton = .Button1) -> MsgResult
{
    ms_str := to_wstring(fmt.tprint(msg))
    cap_str : wstring
    if len(title) == 0 {
        cap_str = def_msg_title
    } else do cap_str = to_wstring(title)
    utype : u32 = u32(msg_btn) | u32(ms_icon) | u32(def_btn)
    return MsgResult(MessageBox(dummy_hwnd, ms_str, cap_str, utype ))
}


