
package winforms

import "core:fmt"
import "core:runtime"


print :: fmt.println // Its easy to use. Delete after finishing this module.
txt_flag : Uint = DT_SINGLELINE | DT_VCENTER | DT_CENTER | DT_HIDEPREFIX
transparent : i32 : 1
WcButtonW : wstring
_button_count : int

mouse_clicked :: 0b1
mouse_over :: 0b1000000
btn_focused :: 0b10000
round_factor : i32 : 5

ButtonStyle :: enum {Default, Flat, Gradient,}
ButtonDrawMode :: enum {Default, Text_Only, Bg_Only, Text_And_Bg, Gradient, Grad_And_Text}

Button :: struct
{
	using control : Control,
	style : ButtonStyle,
	//click : EventHandler,
	_draw_needed : bool,
	// _draw_mode : ButtonDrawMode,
	_fclr_changed, _bclr_changed : bool,
	_fdraw : FlatDraw,
	_gdraw : GradDraw,
	// _gradient_color : GradientColors,
	_added_in_draw_list : b64,
}

FlatDraw :: struct { // To manage flat color button drawing
	def_brush : Hbrush,
	hot_brush : Hbrush,
	def_pen : Hpen,
	hot_pen : Hpen,
}

@private flatdraw_setdata :: proc(fd: ^FlatDraw, c: uint) {
	fd.def_brush = get_solid_brush(c)
	fd.hot_brush = CreateSolidBrush(change_color_get_ref(c, 1.2))
	fd.def_pen = CreatePen(PS_SOLID, 1, change_color_get_ref(c, 0.6))
	fd.hot_pen = CreatePen(PS_SOLID, 1, change_color_get_ref(c, 0.3))
}

@private flatdraw_dtor :: proc(fd: FlatDraw) {
	if fd.def_brush != nil do delete_gdi_object(fd.def_brush)
	if fd.hot_brush != nil do delete_gdi_object(fd.hot_brush)
	if fd.def_pen != nil do delete_gdi_object(fd.def_pen)
	if fd.hot_pen != nil do delete_gdi_object(fd.hot_pen)
	// print("flatdraw freed")
}


GradColor :: struct {
	c1 : Color,
	c2 : Color,
}

GradDraw :: struct { // To manage gradient drawing
	gc_def : GradColor,
	gc_hot : GradColor,
	def_brush : Hbrush,
	hot_brush : Hbrush,
	def_pen : Hpen,
	hot_pen : Hpen,
}

@private graddraw_setdata :: proc(gd: ^GradDraw, c1, c2: uint) {
	gd.gc_def.c1 = new_color(c1)
	gd.gc_def.c2 = new_color(c2)
	hadj1: f64 = 1.5 if is_dark_color(gd.gc_def.c1) else 1.2
	hadj2: f64 = 1.5 if is_dark_color(gd.gc_def.c2) else 1.2
	gd.gc_hot.c1 = change_color_rgb(gd.gc_def.c1, hadj1)
	gd.gc_hot.c2 = change_color_rgb(gd.gc_def.c2, hadj2)
	gd.def_pen = CreatePen(PS_SOLID, 1, change_color_get_ref(gd.gc_def.c1, 0.6))
	gd.hot_pen = CreatePen(PS_SOLID, 1, change_color_get_ref(gd.gc_hot.c1, 0.3))
}

@private graddraw_dtor :: proc(gd: GradDraw) {
	if gd.def_brush != nil do delete_gdi_object(gd.def_brush)
	if gd.hot_brush != nil do delete_gdi_object(gd.hot_brush)
	if gd.def_pen != nil do delete_gdi_object(gd.def_pen)
	if gd.hot_pen != nil do delete_gdi_object(gd.hot_pen)
	print("gradDraw freed")
}

// create new Button type
new_button :: proc{new_button1, new_button2, new_button3, new_button4}

@private btn_ctor :: proc(p : ^Form, txt : string, x, y, w, h : int) -> Button
{
	if WcButtonW == nil do WcButtonW = to_wstring("Button")
	_button_count += 1
	b : Button
	b.kind = .Button
	b.text = txt == "" ? concat_number("Button_", _button_count) : txt
	b.width = w
	b.height = h
	b.xpos = x
	b.ypos = y
	b.parent = p
	b.font = p.font
	b._ex_style = 0
	b._style = WS_CHILD | WS_TABSTOP | WS_VISIBLE | BS_NOTIFY
	b._cls_name = WcButtonW
	b._draw_flag = 0
	b.fore_color = p.fore_color
	b.back_color = p.back_color
	b._before_creation = cast(CreateDelegate) btn_before_creation
	b._after_creation = cast(CreateDelegate) btn_after_creation
	return b
}

@private new_button1 :: proc(parent : ^Form) -> Button
{
	btn := btn_ctor(parent, "", 10, 10, 120, 35)
	return btn
}

@private new_button2 :: proc(parent : ^Form, txt : string) -> Button
{
	btn := btn_ctor(parent, txt, 10, 10, 120, 35)
	return btn
}

@private new_button3 :: proc(parent : ^Form, txt : string, x, y : int) -> Button
{
	btn := btn_ctor(parent, txt, x, y, 120, 35)
	return btn
}

@private new_button4 :: proc(parent : ^Form, txt : string, x, y, w, h: int) -> Button
{
	btn := btn_ctor(parent, txt, x, y, w, h)
	return btn
}




// @private btn_dtor :: proc(btn : ^Button) {

// }

@private btn_before_creation :: proc(b : ^Button) {if b._draw_flag > 0 do check_initial_color_change(b)}

@private btn_after_creation :: proc(b : ^Button) {
	// if b._draw_mode != .Default && !b._added_in_draw_list {
	// 	append(&b.parent._cdraw_childs, b.handle)
	// }
	set_subclass(b, btn_wnd_proc)
}




@private check_initial_color_change :: proc(btn : ^Button)
{
	// There is a chance to user set back/fore color just before creating handle.
	// In that case, we need to check for color changes.
	// if btn.fore_color.value != btn.parent.fore_color.value do btn._draw_flag += 1
	if btn.back_color != btn.parent.back_color {
		flatdraw_setdata(&btn._fdraw, btn.back_color)
	}
}

@private set_fore_color_internal :: proc(btn : ^Button, ncd : ^NMCUSTOMDRAW) -> Lresult
{
	btxt := to_wstring(btn.text)
	SetTextColor(ncd.hdc, get_color_ref(btn.fore_color))
	SetBkMode(ncd.hdc, 1)
	DrawText(ncd.hdc, btxt, -1, &ncd.rc, txt_flag)
	return CDRF_NOTIFYPOSTPAINT
}

@private set_back_color_internal :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> Lresult
{
	switch nmcd.dwDrawStage
	{
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:
			// We need to change color when user clicks the button with  mouse.
			// But that is only working when we write code in pre-paint stage.
			// It won't work in other stages.
			if (nmcd.uItemState & mouse_clicked) == mouse_clicked {
				paint_flat_button(nmcd.hdc, nmcd.rc, btn._fdraw.def_brush, btn._fdraw.hot_pen)
			} else if (nmcd.uItemState & mouse_over) == mouse_over 	{
				paint_flat_button(nmcd.hdc, nmcd.rc, btn._fdraw.hot_brush, btn._fdraw.hot_pen)
			} else  {
				paint_flat_button(nmcd.hdc, nmcd.rc, btn._fdraw.def_brush, btn._fdraw.def_pen)
			}
			return  CDRF_DODEFAULT
	}
	return Lresult(0)
}

@private paint_flat_button :: proc(hdc : Hdc, rc : Rect, hbr: Hbrush, pen: Hpen) {
	SelectObject(hdc, to_hgdi_obj(hbr))
	SelectObject(hdc, to_hgdi_obj(pen))
	RoundRect(hdc, rc.left, rc.top, rc.right, rc.bottom, round_factor, round_factor)
	FillPath(hdc)
}



@private btn_forecolor_control :: proc(btn : ^ Button, clr : uint)
{	// Public version of this function is in control.odin

	if (btn._draw_flag & 1) != 1 do btn._draw_flag += 1
	btn.fore_color = clr
	if btn._is_created do InvalidateRect(btn.handle, nil, false)

}

@private btn_backcolor_control :: proc(btn : ^Button, clr : uint)
{  // Public version of this function is in control.odin
	if (btn._draw_flag & 2) != 2 do btn._draw_flag += 2
	btn.back_color = clr
	flatdraw_setdata(&btn._fdraw, btn.back_color)
	if btn._is_created {
		InvalidateRect(btn.handle, nil, false)
	}

}

// Set gradient colors for this button.
button_set_gradient_colors :: proc(btn : ^Button, clr1, clr2 : uint) {
	if (btn._draw_flag & 4) != 1 do btn._draw_flag += 4
	graddraw_setdata(&btn._gdraw, clr1, clr2)
    if btn._is_created do InvalidateRect(btn.handle, nil, false)

}

@private draw_gradient_bkg :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> Lresult
{
	switch nmcd.dwDrawStage
	{
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:
			//draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, -1, 1)
			if (nmcd.uItemState & mouse_clicked) == mouse_clicked {
				paint_gradient_button(btn, nmcd.hdc, nmcd.rc, btn._gdraw.gc_def, btn._gdraw.def_pen)
			} else if (nmcd.uItemState & mouse_over) == mouse_over {	// color change when mouse is over the btn
				paint_gradient_button(btn, nmcd.hdc, nmcd.rc, btn._gdraw.gc_hot, btn._gdraw.hot_pen)
			} else {
				paint_gradient_button(btn, nmcd.hdc, nmcd.rc, btn._gdraw.gc_def, btn._gdraw.def_pen)
			}
	}
	return CDRF_DODEFAULT
}

@private
paint_gradient_button :: proc(btn: ^Button, hdc: Hdc, rc: Rect, gc : GradColor, pen: Hpen) {
	gr_brush : Hbrush = create_gradient_brush(hdc, rc, gc.c1, gc.c2)
	defer delete_gdi_object(gr_brush)
	select_gdi_object(hdc, pen)
	select_gdi_object(hdc, gr_brush)
	RoundRect(hdc, rc.left, rc.top, rc.right, rc.bottom, round_factor, round_factor)
	FillPath(hdc)
}



@private btn_wmnotify_handler :: proc(btn: ^Button, lpm: Lparam) -> Lresult  {
	ret : Lresult = CDRF_DODEFAULT
	// print("draw flg ", btn._draw_flag)
	if btn._draw_flag > 0 {

		nmcd := direct_cast(lpm, ^NMCUSTOMDRAW)
		switch btn._draw_flag {
			case 1: ret = set_fore_color_internal(btn, nmcd)
			case 2: ret = set_back_color_internal(btn, nmcd)
			case 3:
				set_back_color_internal(btn, nmcd)
				ret = set_fore_color_internal(btn, nmcd)
			case 4: ret = draw_gradient_bkg(btn, nmcd)
			case 5:
				draw_gradient_bkg(btn, nmcd)
				ret = set_fore_color_internal(btn, nmcd)
		}
	}
	return ret
}

@private btn_finalize :: proc(btn: ^Button, scid: UintPtr) {
	switch btn._draw_flag {
		case 2, 3: flatdraw_dtor(btn._fdraw)
		case 4, 5: graddraw_dtor(btn._gdraw)
	}
	RemoveWindowSubclass(btn.handle, btn_wnd_proc, scid)
}


//mc : int = 1
@private btn_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam,
									sc_id : UintPtr, ref_data : DwordPtr) -> Lresult
{
	context = runtime.default_context()
	btn := control_cast(Button, ref_data)
	switch msg
	{
		case WM_PAINT :
            if btn.paint != nil
            {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                btn.paint(btn, &pea)
                EndPaint(hw, &ps)
                return 0
            }
		case WM_SETFOCUS:
            if btn.got_focus != nil
            {
                ea := new_event_args()
                btn.got_focus(btn, &ea)
                return 0
            }

        case WM_KILLFOCUS:
            //btn._draw_focus_rct = false
            if btn.lost_focus != nil
            {
                ea := new_event_args()
                btn.lost_focus(btn, &ea)
                return 0
            }
			return 0  // Avoid this if you want to show the focus rectangle (....)



		case WM_LBUTTONDOWN:
			btn._mdown_happened = true
			if btn.left_mouse_down != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.left_mouse_down(btn, &mea)
			}
		case WM_RBUTTONDOWN:
			btn._mrdown_happened = true
			if btn.right_mouse_down != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.right_mouse_down(btn, &mea)
			}
		case WM_LBUTTONUP :
			if btn.left_mouse_up != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.left_mouse_up(btn, &mea)
			}
			if btn._mdown_happened {
				btn._mdown_happened = false
				SendMessage(btn.handle, CM_LMOUSECLICK, 0, 0)
			}

		case CM_LMOUSECLICK :
			btn._mdown_happened = false
			if btn.mouse_click != nil
			{
				ea := new_event_args()
				btn.mouse_click(btn, &ea)
				return 0
			}

		case WM_RBUTTONUP :

			if btn.right_mouse_up != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.right_mouse_up(btn, &mea)
			}
			if btn._mrdown_happened {
				btn._mrdown_happened = false
				SendMessage(btn.handle, CM_RMOUSECLICK, 0, 0)
			}

		case CM_RMOUSECLICK :
			btn._mrdown_happened = false
			if btn.right_click != nil
			{
				ea := new_event_args()
				btn.right_click(btn, &ea)
				return 0
			}

		case WM_MOUSEHWHEEL:
			if btn.mouse_scroll != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.mouse_scroll(btn, &mea)
			}
		case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
			if btn._is_mouse_entered
			{
                if btn.mouse_move != nil
                {
                    mea := new_mouse_event_args(msg, wp, lp)
                    btn.mouse_move(btn, &mea)
                }
            }
            else {
                btn._is_mouse_entered = true
                if btn.mouse_enter != nil
                {
                    ea := new_event_args()
                    btn.mouse_enter(btn, &ea)
                }
            }

		case WM_MOUSELEAVE :
			btn._is_mouse_entered = false
            if btn.mouse_leave != nil
            {
                ea := new_event_args()
                btn.mouse_leave(btn, &ea)
            }

		case CM_NOTIFY:	return btn_wmnotify_handler(btn, lp)
		case WM_DESTROY: btn_finalize(btn, sc_id)

		case : return DefSubclassProc(hw, msg, wp, lp)


	}
	return DefSubclassProc(hw, msg, wp, lp)
}
