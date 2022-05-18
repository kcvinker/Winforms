
// 

package main
import ui "winforms"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"

Control :: ui.Control
Form :: ui.Form
MouseEventArgs :: ui.MouseEventArgs
EventArgs :: ui.EventArgs
KeyEventArgs :: ui.KeyEventArgs
print :: fmt.println
ptf :: fmt.printf

frm : Form
tbTime : ui.TextBox
lb1 : ui.Label
lb2 : ui.Label
lb3 : ui.Label
tbRate : ui.TextBox
tbAmnt : ui.TextBox

timeStr : string
rate : int
timeData : Time

Time :: struct {
	hour, minute, second : int,
}
gtbfsize : int = 20


make_ui :: proc() {
	using ui
	frm = new_form("Rate Calculator -[15-May-2022]", 420, 200)	
	frm.font = new_font("Tahoma", 13)
	frm.left_mouse_down = frm_mouse_down
	create_form(&frm)
	
	lb1 = new_label(&frm, 10, 15, "Time")	
	lb2 = new_label(&frm, 215, 15, "Rate")	
	lb3 = new_label(&frm, 10, 73, "Amount")

	
	tbTime = new_textbox(&frm, 120, 35, 65, 10 )
	tbTime.text_type = .Number_Only	
	tbTime.lost_focus = tbTime_lostfocus
	tbTime.mouse_click = tbTime_onclick
	tbTime.key_up = tbTime_onKeyUp
	ui.control_set_font_size(&tbTime, gtbfsize)
	
	tbRate = new_textbox(&frm, 120, 35, 252, 10 )
	tbRate.text_type = .Number_Only	
	tbRate.key_up = tbRate_onKeyUp
	tbRate.mouse_click = tbRate_onclick
	ui.control_set_font_size(&tbRate, gtbfsize)

	tbAmnt = new_textbox(&frm, 120, 35, 65, 70 )
	tbAmnt.read_only = true
	ui.control_set_font_size(&tbAmnt, gtbfsize)

	create_controls(&lb1, &lb2, &lb3, &tbTime, &tbRate, &tbAmnt)	
	
	set_focus(tbTime.handle)
	start_form()
	
}

frm_mouse_down :: proc(c : ^Control, e : ^MouseEventArgs) {
	ui.print_point(e)
}

tbTime_lostfocus :: proc(c : ^Control, e : ^EventArgs) {
	txt := ui.control_get_text(tbTime)
	
	if len(txt) > 0 {
		hr, mn, sec : int 
		switch len(txt) {

			case 1, 2 : 
				mn, _ = strconv.parse_int(txt[0:2])
				timeStr = fmt.tprintf("00:%02d:00", mn)

			case 3, 4 : 
				mn, _ = strconv.parse_int(txt[0:2])
				sec, _ = strconv.parse_int(txt[2:])
				timeStr = fmt.tprintf("00:%02d:%02d", mn, sec)			

			case 5 :
				hr, _ = strconv.parse_int(txt[:1])
				mn, _ = strconv.parse_int(txt[1:3])
				sec, _ = strconv.parse_int(txt[3:])
				timeStr = fmt.tprintf("%02d:%02d:%02d", hr, mn, sec)	
			case 6 :
				hr, _ = strconv.parse_int(txt[0:2])
				mn, _ = strconv.parse_int(txt[2:4])
				sec, _ = strconv.parse_int(txt[4:])
				timeStr = fmt.tprintf("%02d:%02d:%02d", hr, mn, sec)
			case : ui.msg_box("Time must be in 'HH:MM:SS' format")

		}
		using timeData
		hour = hr
		minute = mn
		second = sec
	}
	ui.control_set_text(&tbTime, timeStr)
	if rate > 0 do calculate_rate()
	
}

tbTime_onclick :: proc(c : ^Control, e : ^EventArgs) {
	txt := ui.control_get_text(tbTime)
	if len(txt) > 0 {
		nTxt : string
		if strings.contains(txt, ":") {
			nTxt, _ = strings.replace_all(txt, ":", "")
		} else do nTxt = txt
		ui.control_set_text(&tbTime, nTxt)
		ui.textbox_set_selection(&tbTime, true)
	}
	
}

tbRate_onclick :: proc(c : ^Control, e : ^EventArgs) {
	ui.textbox_set_selection(&tbRate, true)
	
}


tbTime_onKeyUp :: proc(c : ^Control, e : ^KeyEventArgs) {
	if e.key_code == ui.KeyEnum.Tab || e.key_code == ui.KeyEnum.Enter {
		if rate > 0 && len(timeStr) > 0 {
			calculate_rate()
		}
		ui.set_focus(tbRate.handle)
		
	}
}

calculate_rate :: proc() {
	// We have global variable of Time struct
	// So calculate rate as per that time
	hrAmt := (timeData.hour * 60 ) * rate
	mnAmt := timeData.minute * rate
	secRate := rate / 60
	secAmt := secRate * timeData.second
	total := hrAmt + mnAmt + secAmt
	ui.control_set_text(&tbAmnt, fmt.tprintf("%d", total))


}

tbRate_onKeyUp :: proc(c : ^Control, e : ^KeyEventArgs) {
	if len(timeStr) > 0 {
		rate, _ = strconv.parse_int(ui.control_get_text(tbRate))
		//print(rate)
		if rate > 0 do calculate_rate()
	}
}


main :: proc() {
	track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)
    make_ui()
    for _, v in track.allocation_map { ptf("%v leaked %v bytes\n", v.location, v.size) }
    for bf in track.bad_free_array { ptf("%v allocation %p was freed badly\n", bf.location, bf.memory) }  
}