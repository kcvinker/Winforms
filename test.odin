
package some	

import "core:fmt"
import "core:slice"
import "core:c"
print :: fmt.println
ptf :: fmt.printf

wchar :: c.wchar_t
Control :: struct {name : string, handle : int, font : Font, typ : Type}
Form :: struct {using control : Control, width, heigt : int, }
Button :: struct {using control : Control, text : string,}
Type :: enum {ctrl, win, btn, textb, label, listview, dgv,}
Font :: struct {name : string, size : int, bold : b32}

// set_font :: proc(cnt : ^Control, fn : string) {
// 	cnt.font = fn
// 	if cnt.typ == Type.win {
// 		f := cast(^Form) cnt
// 		fmt.println("cnt name - ", f.name)
// 	}
	
// }

new_control1 :: proc() -> Control {
	c : Control
	c.name = "Dummy"
	c.typ = Type.ctrl
	return c
}

new_control2 :: proc(n : string) -> Control {
	c : Control
	c.name = n
	c.typ = Type.ctrl
	return c
}
new_control :: proc{new_control1, new_control2}

new_form :: proc() -> Form {
	f : Form
	f.name = "New Form"
	f.typ = Type.win
	return f
}

new_btn :: proc(hnd : int) -> Button {
	b : Button
	b.name = "Button"
	b.typ = .btn
	b.handle = hnd
	return b
}



main :: proc() {
	fmt.println("We are starting the test")
	colors :: enum {def , txt, bgc, tx_bg, grd, gr_tx} // 1, 3, 7, 15, 31, 63
	c1 :: 10
	c2 :: 5
	c3 := c1 | c2
	c3 ~= c2
	print("c3 - ", c3)
}




test :: proc(item : ..any) { 
	for n in item {
		switch ty in n {
			case Form :
				print("It's a form")
				print(ty.name)				
			case Button :
				print("it's a button")
				print(ty.handle)
			case int :
				print("its an int")
				//ft := f32(n)
		}
	}
}

//------------------------

