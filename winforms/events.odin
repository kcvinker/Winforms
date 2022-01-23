package winforms
//import "core:fmt"

EventHandler :: proc(sender : ^Control, ea : ^EventArgs) //distinct #type
MouseEventHandler :: proc(sender : ^Control, e : ^MouseEventArgs)
KeyEventHandler :: proc(sender : ^Control, e : ^KeyEventArgs)
DateTimeEventHandler :: proc(sender : ^Control, e : ^DateTimeEvent)
PaintEventHandler :: proc(sender : ^Control, e : ^PaintEventArgs)
MoveEventHandler :: proc(sender : ^Control, e : ^MoveEventArgs)
LBoxEventHandler :: proc(sender : ^Control, e : string)




EventArgs :: struct {handled : b64, cancelled : b64,}
MouseEventArgs :: struct {
	using base : EventArgs,
	button : MouseButtons,
	clicks, delta : i32,
	shift_key, ctrl_key : KeyState,	
	x, y : int,
}

KeyEventArgs :: struct {
    using base : EventArgs,
	alt_pressed : b32,
    ctrl_pressed : b32, 
    shift_pressed : b32,       
    key_code : KeyEnum,     
    key_value : int,    
    suppress_key_press : b32,
}

DateTimeEvent :: struct {
    using base : EventArgs,
    date_string : string,
    dt_struct : SYSTEMTIME,
}

PaintEventArgs ::  struct {
    using base : EventArgs,
    paint_info : ^PAINTSTRUCT,

}

MoveEventArgs :: struct {
    using base : EventArgs,
    form_rect : ^Rect,
    x, y : int,
}




new_event_args :: proc() -> EventArgs {
	ea : EventArgs
	ea.handled = false
    ea.cancelled = false
	return ea
}

new_mouse_event_args :: proc(msg : u32, wp : Wparam, lp : Lparam) -> MouseEventArgs {
	mea : MouseEventArgs
	fw_keys := cast(Word) (wp & 0xffff) //(lo_word(cast(Dword) wp))	
	//fmt.println("fw_keys - ", fw_keys)
	mea.delta = cast(i32) (hi_word(cast(Dword) wp))
	switch fw_keys {
	case 5 : mea.shift_key = KeyState.pressed
	case 9 : mea.ctrl_key = KeyState.pressed
	case 17 : mea.button = MouseButtons.middle
	case 33 : mea.button = MouseButtons.xButton1                
	}

	switch msg {
	case WM_MOUSEWHEEL, WM_MOUSEMOVE, WM_MOUSEHOVER, WM_NCHITTEST :
		mea.x = cast(int) (lo_word(cast(Dword) lp))
		mea.y = cast(int) (hi_word(cast(Dword) lp))
	case WM_LBUTTONDOWN, WM_LBUTTONUP : 
        mea.button = MouseButtons.left 
        mea.x = cast(int) (lo_word(cast(Dword) lp))
        mea.y = cast(int) (hi_word(cast(Dword) lp))
    case WM_RBUTTONDOWN, WM_RBUTTONUP : 
        mea.button = MouseButtons.right ;
        mea.x = cast(int) (lo_word(cast(Dword) lp))
        mea.y = cast(int) (hi_word(cast(Dword) lp))
	}
	return mea
}

new_key_event_args :: proc(wP : Wparam) -> KeyEventArgs {
	kea : KeyEventArgs    
    kea.key_code = KeyEnum(wP)    
    kea.key_value = cast(int) kea.key_code  
    #partial switch kea.key_code {
	case KeyEnum.shift : kea.shift_pressed = true     		    		 
	case KeyEnum.ctrl : kea.ctrl_pressed = true     				 
	case KeyEnum.alt : kea.alt_pressed = true         	      
    }      
    return kea
}

new_paint_event_args :: proc(ps : ^PAINTSTRUCT) -> PaintEventArgs {
    pea : PaintEventArgs
    pea.paint_info = ps
    return pea
}

new_move_event_args :: proc(m : u32, lpm : Lparam) -> MoveEventArgs {
    mea : MoveEventArgs
    if m == WM_MOVING {
        mea.form_rect = direct_cast(lpm, ^Rect)
        mea.x = int(mea.form_rect.left)
        mea.y = int(mea.form_rect.top)
    }
    else {
        mea.x = get_x_lparam(lpm)
        mea.y = get_y_lparam(lpm)
    }
    return mea
}
//new_datetime_event_args :: proc()


MouseButtons :: enum {
	none = 0,
    right = 2097152,
    middle = 4194304,
    left = 1048576,
    xButton1 = 8388608,
    xButton2 = 16777216,
}

KeyState :: enum {released, pressed,}

KeyEnum :: enum {
    modifier = -65_536,
    none = 0, 
    left_button, right_button, cancel, middle_button, x_button1, x_button2, 
    back_space = 8, tab,
    clear = 12, enter, 
    shift = 16, ctrl, alt, pause, caps_lock, 
    escape = 27,
    space = 32, page_up, page_down, end, home, left_arrow, up_arrow, right_arrow, down_arrow,
    select, print, execute, print_screen, insert, del, help,
    d0, d1, d2, d3, d4, d5, d6, d7, d8, d9,   
    a = 65, 
    b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z,    
    left_win, right_win, apps,
    sleep = 95,     
    num_pad0, num_pad1, num_pad2, num_pad3, num_pad4, num_pad5, num_pad6, num_pad7, num_pad8, num_pad9, 
    multiply, add, seperator, subtract, decimal, divide, 
    f_1, f_2, f_3, f_4, f_5, f_6, f_7, f_8, f_9, f_10, f_11, f_12, f_13, f_14, f_15, f_16, f_17, f_18, f_19, f_20, f_21, f_22, f_23, f_24, 
    num_lock = 144, scroll, 
    left_shift = 160, right_shift, left_ctrl, right_ctrl, left_menu, right_menu, 
    browser_back, browser_forward, brower_refresh, browser_stop, browser_search, browser_favorites, browser_home, 
    volume_mute, volume_down, volume_up, 
    media_next_track, media_prev_track, media_stop, media_play_pause, launch_mail, select_media, 
    launch_app1, launch_app2, 
    colon = 186, oem_plus, oem_comma, oem_minus, oem_period, oem_question, oem_tilde, 
    oem_open_bracket = 219, oem_pipe, oem_close_bracket, oem_quotes, oem8,
    oem_back_slash = 226,
    process = 229,
    packet = 231,
    attn = 246, cr_sel, ex_sel, erase_eof, play, zoom, no_name, pa1, oem_clear,  // start from 400    
}