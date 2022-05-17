
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

ButtonStyle :: enum {Default, Flat, Gradient,}
ButtonDrawMode :: enum {Default, Text_Only, Bg_Only, Text_And_Bg, Gradient, Grad_And_Text}

Button :: struct 
{
	using control : Control,	
	style : ButtonStyle,
	//click : EventHandler,
	_draw_needed : bool,
	_draw_mode : ButtonDrawMode,	
	_fclr_changed, _bclr_changed : bool,
	_gradient_style : GradientStyle,
    _gradient_color : GradientColors,
	_added_in_draw_list : b64,
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

@private new_button4 :: proc(parent : ^Form, txt : string, x, y, w, h : int) -> Button 
{
	btn := btn_ctor(parent, txt, x, y, w, h)
	return btn
}




// @private btn_dtor :: proc(btn : ^Button) {

// }

@private btn_before_creation :: proc(b : ^Button) {if b._draw_mode == .Default do check_initial_color_change(b)}

@private btn_after_creation :: proc(b : ^Button) {
	if b._draw_mode != .Default && !b._added_in_draw_list {
		append(&b.parent._cdraw_childs, b.handle)
	}
	set_subclass(b, btn_wnd_proc)
}

// Create the Button Hwnd
// create_button :: proc(btn : ^Button)
// {	
// 	_global_ctl_id += 1
// 	btn.control_id = _global_ctl_id
// 	if btn._draw_mode == .Default do check_initial_color_change(btn)	
// 	btn.handle = CreateWindowEx(  btn._ex_style, 
// 									WcButtonW, //to_wstring("Button"), 
// 									to_wstring(btn.text),
//                                     btn._style, 
// 									i32(btn.xpos), 
// 									i32(btn.ypos), 
//                                     i32(btn.width), 
// 									i32(btn.height),
//                                     btn.parent.handle, 
// 									direct_cast(btn.control_id, Hmenu), 
// 									app.h_instance, 
// 									nil )
	
// 	if btn.handle != nil 
// 	{
// 		btn._is_created = true
// 		if btn._draw_mode != .Default && !btn._added_in_draw_list 
// 		{
// 			append(&btn.parent._cdraw_childs, btn.handle)
// 		}
// 		set_subclass(btn, btn_wnd_proc)
// 		setfont_internal(btn) 		
		
// 	}	
// }

// Create more than one buttons. It's handy when you need to create plenty of buttons.
//create_buttons :: proc(btns : ..^Button) { for b in btns do create_button(b) }

@private check_initial_color_change :: proc(btn : ^Button) 
{
	// There is a chance to user set back/fore color just before creating handle.
	// In that case, we need to check for color changes.
	if btn.fore_color != 0 
	{
		if btn.back_color != 0 
		{
			btn._draw_mode = ButtonDrawMode.Text_And_Bg
		} 
		else do btn._draw_mode = ButtonDrawMode.Text_Only
	} 

	if btn.back_color != 0 
	{
		if btn.fore_color != 0 
		{
			btn._draw_mode = ButtonDrawMode.Text_And_Bg
		} 
		else do btn._draw_mode = ButtonDrawMode.Bg_Only
	} 		
}

@private set_fore_color_internal :: proc(btn : ^Button, ncd : ^NMCUSTOMDRAW) -> Lresult 
{			
	cref := get_color_ref(btn.fore_color)
	btxt := to_wstring(btn.text)		
	SetTextColor(ncd.hdc, cref)	
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
			if (nmcd.uItemState & mouse_clicked) == mouse_clicked 
			{				
				cref := get_color_ref(btn.back_color)
				draw_back_color(nmcd.hdc, &nmcd.rc, cref, -1)												
			} 
			
			// Note that above if statement must separate from this one. 
			// Otherwise, button's click action look weird.
			if (nmcd.uItemState & mouse_over) == mouse_over 	// color change when mouse is over the btn
			{	cref := change_color(btn.back_color, 1.2)
				draw_back_color(nmcd.hdc, &nmcd.rc, cref, -1)
				draw_frame(nmcd.hdc, &nmcd.rc, btn.back_color, 1) 

			} 
			else  // Default button color.
			{ 				
				cref := get_color_ref(btn.back_color)
				draw_back_color(nmcd.hdc, &nmcd.rc, cref, -1)
				draw_frame(nmcd.hdc, &nmcd.rc, btn.back_color, 1)								
			}
			return  CDRF_DODEFAULT			
	}
	return Lresult(0)	
}

@private draw_back_color :: proc(hd : Hdc, rct : ^Rect, clr : ColorRef, rc_size : i32 = -3) 
{	
	hbr := CreateSolidBrush(clr)
	SelectObject(hd, to_hgdi_obj(hbr))	
	tmp_rct : ^Rect = rct
	if rc_size != 0 do InflateRect(tmp_rct, rc_size, rc_size)	
	FillRect(hd, tmp_rct, hbr)
	DeleteObject(to_hgdi_obj(hbr))
}

@private draw_frame :: proc(hd : Hdc, rct : ^Rect, clr : uint, pen_width : i32, rc_size : i32 = 1) 
{
	trc : ^Rect = rct
	InflateRect(trc, rc_size, rc_size )
	clr := change_color(clr, 0.5) //  find a way to get the color which is matching to button back color.
	frame_pen := CreatePen(PS_SOLID, pen_width, clr)
	SelectObject(hd, to_hgdi_obj(frame_pen))
	Rectangle(hd, trc.left, trc.top, trc.right, trc.bottom)
	DeleteObject(to_hgdi_obj(frame_pen))
}

@private set_button_forecolor :: proc(btn : ^ Button, clr : uint) 
{	// Public version of this function is in control.odin
	if btn._draw_mode == .Default && btn._is_created
	{
		append(&btn.parent._cdraw_childs, btn.handle)
		btn._added_in_draw_list = true
	}
	#partial switch btn._draw_mode 
	{
		case .Bg_Only : btn._draw_mode = .Text_And_Bg
		case .Gradient : btn._draw_mode = .Grad_And_Text
		case : btn._draw_mode = .Text_Only
	}
	btn.fore_color = clr	
	if btn._is_created do InvalidateRect(btn.handle, nil, true)	
}

@private set_button_backcolor :: proc(btn : ^Button, clr : uint) 
{  // Public version of this function is in control.odin
	if btn._draw_mode == .Default && btn._is_created
	{
		append(&btn.parent._cdraw_childs, btn.handle)
		btn._added_in_draw_list = true
	}
	#partial switch btn._draw_mode 
	{
		case .Text_Only : btn._draw_mode = .Text_And_Bg
		case .Gradient : btn._draw_mode = .Bg_Only
		case .Grad_And_Text : btn._draw_mode = .Text_And_Bg
		case .Text_And_Bg : btn._draw_mode = .Text_And_Bg
		case : btn._draw_mode = .Bg_Only
	}
	btn.back_color = clr	
	if btn._is_created do InvalidateRect(btn.handle, nil, true)
}

// Set gradient colors for a button.
set_button_gradient :: proc(btn : ^Button, clr1, clr2 : uint, style : GradientStyle = .Top_To_Bottom) 
{
	if btn._draw_mode == .Default && btn._is_created 
	{
		append(&btn.parent._cdraw_childs, btn.handle)
		btn._added_in_draw_list = true
	}
	#partial switch btn._draw_mode 
	{
		case .Text_Only : btn._draw_mode = .Grad_And_Text		
		case .Grad_And_Text : btn._draw_mode = .Grad_And_Text
		case : btn._draw_mode = .Gradient
	}
    btn._gradient_color.color1 = new_rgb_color(clr1)
    btn._gradient_color.color2 = new_rgb_color(clr2)   
    btn._gradient_style = style	
    if btn._is_created do InvalidateRect(btn.handle, nil, true)
	//print("draw mode in sgb func - ", btn._draw_mode)
}

@private set_gradient_internal :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> Lresult 
{	
	switch nmcd.dwDrawStage 
	{		
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.		
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:	
			//draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, -1, 1)		
			if (nmcd.uItemState & mouse_clicked) == mouse_clicked 
			{	
				draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, -1, 1)
				paint_with_gradient_brush(btn._gradient_color, btn._gradient_style, nmcd.hdc, nmcd.rc, -2)
				return  CDRF_DODEFAULT			
			} 
			
			// Note that above if statement must separate from this one. 
			// Otherwise, button's click action look weird.
			if (nmcd.uItemState & mouse_over) == mouse_over 
			{	// color change when mouse is over the btn
				draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, 0, 1)
				ngc := change_gradient_color(btn._gradient_color, 1.2)
				paint_with_gradient_brush(ngc, btn._gradient_style, nmcd.hdc, nmcd.rc, -1)				
				return  CDRF_DODEFAULT
			} 
			else 
			{	
				draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, 0, 1)
				paint_with_gradient_brush(btn._gradient_color, btn._gradient_style, nmcd.hdc, nmcd.rc, -1)				
				return  CDRF_DODEFAULT
			}						
	}
	return CDRF_DODEFAULT
}

@private 
paint_with_gradient_brush :: proc(grc : GradientColors, grs : GradientStyle, hd : Hdc, rc : Rect, rc_size : i32) 
{
	rct : Rect = rc
	if rc_size != 0 do InflateRect(&rct, rc_size, rc_size)
	gr_brush := create_gradient_brush(grc, grs, hd, rct)
	FillRect(hd, &rct, gr_brush)
	DeleteObject(to_hgdi_obj(gr_brush))
}

@private 
draw_frame_gr :: proc (hd : Hdc, rc : Rect, rgbc : RgbColor, rc_size : i32, pw : i32 = 2) 
{
	rct := rc
	if rc_size != 0 do InflateRect(&rct, rc_size, rc_size )	
	clr := change_color_get_uint(rgbc, 0.5)
	frame_pen := CreatePen(PS_SOLID, pw, clr)	
	select_gdi_object(hd, frame_pen)	
	Rectangle(hd, rct.left, rct.top, rct.right, rct.bottom)
	delete_gdi_object(frame_pen)
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
		
		case CM_NOTIFY:		//{default, Text_Only, Bg_Only, Text_And_Bg, gradient, Grad_And_Text}	
			if btn._draw_mode != .Default 
			{	
				nmcd := direct_cast(lp, ^NMCUSTOMDRAW)			
				#partial switch btn._draw_mode 
				{
					case .Text_Only :						
						return set_fore_color_internal(btn, nmcd)						
					case .Bg_Only :
						return set_back_color_internal(btn, nmcd)
					case .Text_And_Bg :
						set_back_color_internal(btn, nmcd)
						return set_fore_color_internal(btn, nmcd)
					case .Gradient :						
						return set_gradient_internal(btn, nmcd)	
					case .Grad_And_Text :						
						set_gradient_internal(btn, nmcd)
						return set_fore_color_internal(btn, nmcd)						
				}
			}

		case WM_DESTROY:
			remove_subclass(btn)

		case : return DefSubclassProc(hw, msg, wp, lp)
			
			
	}
	return DefSubclassProc(hw, msg, wp, lp)
}
