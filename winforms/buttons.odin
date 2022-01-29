
package winforms

import "core:fmt"
import "core:runtime"

print :: fmt.println // Its easy to use. Delete after finishing this module.
txt_flag : Uint = DT_SINGLELINE | DT_VCENTER | DT_CENTER | DT_HIDEPREFIX
transparent : i32 : 1
_button_count : int
// BS_NOTIFY :: 0x00004000
// BS_DEFPUSHBUTTON :: 0x00000001
mouse_clicked :: 0b1  
mouse_over :: 0b1000000 
btn_focused :: 0b10000

ButtonStyle :: enum {default, flat, gradient,}
ButtonDrawMode :: enum {default, text_only, bg_only, text_and_bg, gradient, grad_and_text}

Button :: struct {
	using control : Control,	
	style : ButtonStyle,
	click : EventHandler,
	_draw_needed : bool,
	_draw_mode : ButtonDrawMode,	
	_fclr_changed, _bclr_changed : bool,
	_gradient_style : GradientStyle,
    _gradient_color : GradientColors,
	_added_in_draw_list : b64,
	

}

// create new Button type
new_button :: proc{new_button1, new_button2}

@private new_button1 :: proc(parent : ^Form) -> Button {
	btn := new_button_ctor(parent)
	return btn
}

@private new_button2 :: proc(parent : ^Form, txt : string, x, y : int, w : int = 120, h : int = 40) -> Button {
	btn := new_button_ctor(parent, txt, w, h, x, y)
	return btn
}


@private new_button_ctor :: proc(p : ^Form, txt : string = "", w : int = 120, h : int = 40, x : int = 10, y : int = 10) -> Button {	
	_button_count += 1	
	b : Button
	b.kind = .button
	b.text = txt == "" ? concat_number("Button_", _button_count) : txt
	b.width = w
	b.height = h
	b.xpos = x
	b.ypos = y
	b.parent = p
	b.font = p.font
	b._ex_style = 0
	b._style = WS_CHILD | WS_TABSTOP | WS_VISIBLE | BS_NOTIFY
	return b
}

// @private btn_dtor :: proc(btn : ^Button) {

// }

// Create the Button Hwnd
create_button :: proc(btn : ^Button) -> bool {	
	_global_ctl_id += 1
	btn.control_id = _global_ctl_id
	if btn._draw_mode == .default do check_initial_color_change(btn)	
	btn.handle = create_window_ex(  btn._ex_style, 
									to_wstring("Button"), 
									to_wstring(btn.text),
                                    btn._style, 
									i32(btn.xpos), 
									i32(btn.ypos), 
                                    i32(btn.width), 
									i32(btn.height),
                                    btn.parent.handle, 
									direct_cast(btn.control_id, Hmenu), 
									app.h_instance, 
									nil )
	
	if btn.handle != nil {
		btn._is_created = true
		if btn._draw_mode != .default && !btn._added_in_draw_list {
			append(&btn.parent._cdraw_childs, btn.handle)
		}
		set_subclass(btn, btn_wnd_proc)
		setfont_internal(btn) 		
		
	}
	return true
}

// Create more than one buttons. It's handy when you need to create plenty of buttons.
create_buttons :: proc(btns : ..^Button) { for b in btns do create_button(b) }

@private check_initial_color_change :: proc(btn : ^Button) {
	// There is a chance to user set back/fore color just before creating handle.
	// In that case, we need to check for color changes.
	if btn.fore_color != 0 {
		if btn.back_color != 0 {
			btn._draw_mode = ButtonDrawMode.text_and_bg
		} else do btn._draw_mode = ButtonDrawMode.text_only
	} 

	if btn.back_color != 0 {
		if btn.fore_color != 0 {
			btn._draw_mode = ButtonDrawMode.text_and_bg
		} else do btn._draw_mode = ButtonDrawMode.bg_only
	} 		
}

@private set_fore_color_internal :: proc(btn : ^Button, ncd : ^NMCUSTOMDRAW) -> Lresult {			
	cref := get_color_ref(btn.fore_color)
	btxt := to_wstring(btn.text)		
	set_text_color(ncd.hdc, cref)	
	set_bk_mode(ncd.hdc, 1)
	draw_text(ncd.hdc, btxt, -1, &ncd.rc, txt_flag)	
	return CDRF_NOTIFYPOSTPAINT	 
}

@private set_back_color_internal :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> Lresult {	
	switch nmcd.dwDrawStage {		
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.		
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:	
			// We need to change color when user clicks the button with  mouse.
			// But that is only working when we write code in pre-paint stage.
			// It won't work in other stages.
			if (nmcd.uItemState & mouse_clicked) == mouse_clicked {				
				cref := get_color_ref(btn.back_color)
				draw_back_color(nmcd.hdc, &nmcd.rc, cref, -1)												
			} 
			
			// Note that above if statement must separate from this one. 
			// Otherwise, button's click action look weird.
			if (nmcd.uItemState & mouse_over) == mouse_over {	// color change when mouse is over the btn
				cref := change_color(btn.back_color, 1.2)
				draw_back_color(nmcd.hdc, &nmcd.rc, cref, -1)
				draw_frame(nmcd.hdc, &nmcd.rc, btn.back_color, 1) 

			} else { // Default button color.				
				cref := get_color_ref(btn.back_color)
				draw_back_color(nmcd.hdc, &nmcd.rc, cref, -1)
				draw_frame(nmcd.hdc, &nmcd.rc, btn.back_color, 1)								
			}
			return  CDRF_DODEFAULT			
	}
	return Lresult(0)	
}

@private draw_back_color :: proc(hd : Hdc, rct : ^Rect, clr : ColorRef, rc_size : i32 = -3) {	
	hbr := create_solid_brush(clr)
	select_object(hd, to_hgdi_obj(hbr))	
	tmp_rct : ^Rect = rct
	if rc_size != 0 do inflate_rect(tmp_rct, rc_size, rc_size)	
	fill_rect(hd, tmp_rct, hbr)
	delete_object(to_hgdi_obj(hbr))
}

@private draw_frame :: proc(hd : Hdc, rct : ^Rect, clr : uint, pen_width : i32, rc_size : i32 = 1) {
	trc : ^Rect = rct
	inflate_rect(trc, rc_size, rc_size )
	clr := change_color(clr, 0.5) //  find a way to get the color which is matching to button back color.
	frame_pen := create_pen(PS_SOLID, pen_width, clr)
	select_object(hd, to_hgdi_obj(frame_pen))
	draw_rectangle(hd, trc.left, trc.top, trc.right, trc.bottom)
	delete_object(to_hgdi_obj(frame_pen))
}

@private set_button_forecolor :: proc(btn : ^ Button, clr : uint) {	// Public version of this function is in control.odin
	if btn._draw_mode == .default && btn._is_created{
		append(&btn.parent._cdraw_childs, btn.handle)
		btn._added_in_draw_list = true
	}
	#partial switch btn._draw_mode {
		case .bg_only : btn._draw_mode = .text_and_bg
		case .gradient : btn._draw_mode = .grad_and_text
		case : btn._draw_mode = .text_only
	}
	btn.fore_color = clr	
	if btn._is_created do invalidate_rect(btn.handle, nil, true)	
}

@private set_button_backcolor :: proc(btn : ^Button, clr : uint) {  // Public version of this function is in control.odin
	if btn._draw_mode == .default && btn._is_created{
		append(&btn.parent._cdraw_childs, btn.handle)
		btn._added_in_draw_list = true
	}
	#partial switch btn._draw_mode {
		case .text_only : btn._draw_mode = .text_and_bg
		case .gradient : btn._draw_mode = .bg_only
		case .grad_and_text : btn._draw_mode = .text_and_bg
		case .text_and_bg : btn._draw_mode = .text_and_bg
		case : btn._draw_mode = .bg_only
	}
	btn.back_color = clr	
	if btn._is_created do invalidate_rect(btn.handle, nil, true)
}

// Set gradient colors for a button.
set_button_gradient :: proc(btn : ^Button, clr1, clr2 : uint, style : GradientStyle = .top_to_bottom) {
	if btn._draw_mode == .default && btn._is_created {
		append(&btn.parent._cdraw_childs, btn.handle)
		btn._added_in_draw_list = true
	}
	#partial switch btn._draw_mode {
		case .text_only : btn._draw_mode = .grad_and_text		
		case .grad_and_text : btn._draw_mode = .grad_and_text
		case : btn._draw_mode = .gradient
	}
    btn._gradient_color.color1 = new_rgb_color(clr1)
    btn._gradient_color.color2 = new_rgb_color(clr2)   
    btn._gradient_style = style	
    if btn._is_created do invalidate_rect(btn.handle, nil, true)
	//print("draw mode in sgb func - ", btn._draw_mode)
}

@private set_gradient_internal :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> Lresult {	
	switch nmcd.dwDrawStage {		
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.		
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:	
			//draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, -1, 1)		
			if (nmcd.uItemState & mouse_clicked) == mouse_clicked {	
				draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, -1, 1)
				paint_with_gradient_brush(btn._gradient_color, btn._gradient_style, nmcd.hdc, nmcd.rc, -2)
				return  CDRF_DODEFAULT			
			} 
			
			// Note that above if statement must separate from this one. 
			// Otherwise, button's click action look weird.
			if (nmcd.uItemState & mouse_over) == mouse_over {	// color change when mouse is over the btn
				draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, 0, 1)
				ngc := change_gradient_color(btn._gradient_color, 1.2)
				paint_with_gradient_brush(ngc, btn._gradient_style, nmcd.hdc, nmcd.rc, -1)				
				return  CDRF_DODEFAULT
			} else {	
				draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, 0, 1)
				paint_with_gradient_brush(btn._gradient_color, btn._gradient_style, nmcd.hdc, nmcd.rc, -1)				
				return  CDRF_DODEFAULT
			}						
	}
	return CDRF_DODEFAULT
}

@private 
paint_with_gradient_brush :: proc(grc : GradientColors, grs : GradientStyle, hd : Hdc, rc : Rect, rc_size : i32) {
	rct : Rect = rc
	if rc_size != 0 do inflate_rect(&rct, rc_size, rc_size)
	gr_brush := create_gradient_brush(grc, grs, hd, rct)
	fill_rect(hd, &rct, gr_brush)
	delete_object(to_hgdi_obj(gr_brush))
}

@private 
draw_frame_gr :: proc (hd : Hdc, rc : Rect, rgbc : RgbColor, rc_size : i32, pw : i32 = 2) {
	rct := rc
	if rc_size != 0 do inflate_rect(&rct, rc_size, rc_size )	
	clr := change_color_get_uint(rgbc, 0.5)
	frame_pen := create_pen(PS_SOLID, pw, clr)	
	select_gdi_object(hd, frame_pen)	
	draw_rectangle(hd, rct.left, rct.top, rct.right, rct.bottom)
	delete_gdi_object(frame_pen)
}


//mc : int = 1
@private btn_wnd_proc :: proc "std" (hw : Hwnd, msg : u32, wp : Wparam, lp : Lparam, 
									sc_id : UintPtr, ref_data : DwordPtr) -> Lresult {
	context = runtime.default_context()
	btn := control_cast(Button, ref_data) 	
	switch msg {
		case WM_PAINT :
            if btn.paint != nil {
                ps : PAINTSTRUCT
                hdc := begin_paint(hw, &ps)
                pea := new_paint_event_args(&ps)
                btn.paint(btn, &pea)
                end_paint(hw, &ps)
                return 0
            }
		case WM_SETFOCUS:			
            if btn.got_focus != nil {
                ea := new_event_args()
                btn.got_focus(btn, &ea)
                return 0
            }

        case WM_KILLFOCUS:
            //btn._draw_focus_rct = false
            if btn.lost_focus != nil {
                ea := new_event_args()
                btn.lost_focus(btn, &ea)
                return 0
            }
			return 0  // Avoid this if you want to show the focus rectangle (....)

		
		
		case WM_LBUTTONDOWN:
			btn._mdown_happened = true
			if btn.left_mouse_down != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				btn.left_mouse_down(btn, &mea)
			}
		case WM_RBUTTONDOWN:
			btn._mrdown_happened = true
			if btn.right_mouse_down != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				btn.right_mouse_down(btn, &mea)
			}
		case WM_LBUTTONUP :
			if btn.left_mouse_up != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				btn.left_mouse_up(btn, &mea)
			}
			if btn._mdown_happened do send_message(btn.handle, CM_LMOUSECLICK, 0, 0)
			
		case CM_LMOUSECLICK :
			btn._mdown_happened = false	
			if btn.mouse_click != nil {
				ea := new_event_args()
				btn.mouse_click(btn, &ea)
				return 0
			}			

		case WM_RBUTTONUP :
			
			if btn.right_mouse_up != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				btn.right_mouse_up(btn, &mea)
			}
			if btn._mrdown_happened do send_message(btn.handle, CM_RMOUSECLICK, 0, 0)
			 
		case CM_RMOUSECLICK :
			btn._mrdown_happened = false
			if btn.right_click != nil {
				ea := new_event_args()
				btn.right_click(btn, &ea)
				return 0
			}

		case WM_MOUSEHWHEEL:
			if btn.mouse_scroll != nil {
				mea := new_mouse_event_args(msg, wp, lp)
				btn.mouse_scroll(btn, &mea)
			}	
		case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.			
			if btn._is_mouse_entered {
                if btn.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    btn.mouse_move(btn, &mea)                    
                }
            }
            else {
                btn._is_mouse_entered = true
                if btn.mouse_enter != nil  {
                    ea := new_event_args()
                    btn.mouse_enter(btn, &ea)                    
                }
            }
		
		case WM_MOUSELEAVE :			
			btn._is_mouse_entered = false
            if btn.mouse_leave != nil {               
                ea := new_event_args()
                btn.mouse_leave(btn, &ea)                
            }
		
		case CM_NOTIFY:		//{default, text_only, bg_only, text_and_bg, gradient, grad_and_text}	
			if btn._draw_mode != .default {	
				nmcd := direct_cast(lp, ^NMCUSTOMDRAW)			
				#partial switch btn._draw_mode {
					case .text_only :						
						return set_fore_color_internal(btn, nmcd)						
					case .bg_only :
						return set_back_color_internal(btn, nmcd)
					case .text_and_bg :
						set_back_color_internal(btn, nmcd)
						return set_fore_color_internal(btn, nmcd)
					case .gradient :						
						return set_gradient_internal(btn, nmcd)	
					case .grad_and_text :						
						set_gradient_internal(btn, nmcd)
						return set_fore_color_internal(btn, nmcd)						
				}
			}

		case WM_DESTROY:
			remove_subclass(btn)

		case : return def_subclass_proc(hw, msg, wp, lp)
			
			
	}
	return def_subclass_proc(hw, msg, wp, lp)
}
