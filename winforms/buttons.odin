
package winforms

import "core:fmt"
import "core:runtime"


// print :: fmt.println // Its easy to use. Delete after finishing this module.
txtFlag : UINT= DT_SINGLELINE | DT_VCENTER | DT_CENTER | DT_HIDEPREFIX
transparent : i32 : 1
WcButtonW : wstring
_buttonCount : int

MOUSE_CLICKED :: 0b1
MOUSE_OVER :: 0b1000000
BTN_FOCUSED :: 0b10000
ROUND_FACTOR : i32 : 5

ButtonStyle :: enum {Default, Flat, Gradient,}
ButtonDrawMode :: enum {Default, Text_Only, Bg_Only, Text_And_Bg, Gradient, Grad_And_Text}

Button :: struct
{
	using control : Control,
	style : ButtonStyle,
	_drawNeeded : bool,
	_fclrChanged, _bclr_changed : bool,
	_fdraw : FlatDraw,
	_gdraw : GradDraw,
	_addedInDrawList : b64,
}

FlatDraw :: struct // To manage flat color button drawing
{
	defBrush : HBRUSH,
	hotBrush : HBRUSH,
	defPen : HPEN,
	hotPen : HPEN,
}

GradColor :: struct
{
	c1 : Color,
	c2 : Color,
}

GradDraw :: struct  // To manage gradient drawing
{
	gcDef : GradColor,
	gcHot : GradColor,
	defBrush : HBRUSH,
	hotBrush : HBRUSH,
	defPen : HPEN,
	hotPen : HPEN,
}

// create new Button type
new_button :: proc{new_button1, new_button2, new_button3, new_button4}

// Set gradient colors for this button.
button_set_gradient_colors :: proc(btn : ^Button, clr1, clr2 : uint)
{
	if (btn._drawFlag & 4) != 1 do btn._drawFlag += 4
	gradDrawSetData(&btn._gdraw, clr1, clr2)
    if btn._isCreated do InvalidateRect(btn.handle, nil, false)
}

@private flatDrawSetData :: proc(fd: ^FlatDraw, c: uint)
{
	fd.defBrush = get_solid_brush(c)
	fd.hotBrush = CreateSolidBrush(change_color_get_ref(c, 1.2))
	fd.defPen = CreatePen(PS_SOLID, 1, change_color_get_ref(c, 0.6))
	fd.hotPen = CreatePen(PS_SOLID, 1, change_color_get_ref(c, 0.3))
}

@private flatDrawDtor :: proc(fd: FlatDraw)
{
	if fd.defBrush != nil do delete_gdi_object(fd.defBrush)
	if fd.hotBrush != nil do delete_gdi_object(fd.hotBrush)
	if fd.defPen != nil do delete_gdi_object(fd.defPen)
	if fd.hotPen != nil do delete_gdi_object(fd.hotPen)
	// print("flatdraw freed")
}

@private gradDrawSetData :: proc(gd: ^GradDraw, c1, c2: uint)
{
	gd.gcDef.c1 = new_color(c1)
	gd.gcDef.c2 = new_color(c2)
	hadj1: f64 = 1.5 if is_dark_color(gd.gcDef.c1) else 1.2
	hadj2: f64 = 1.5 if is_dark_color(gd.gcDef.c2) else 1.2
	gd.gcHot.c1 = change_color_rgb(gd.gcDef.c1, hadj1)
	gd.gcHot.c2 = change_color_rgb(gd.gcDef.c2, hadj2)
	gd.defPen = CreatePen(PS_SOLID, 1, change_color_get_ref(gd.gcDef.c1, 0.6))
	gd.hotPen = CreatePen(PS_SOLID, 1, change_color_get_ref(gd.gcHot.c1, 0.3))
}

@private gradDrawDtor :: proc(gd: GradDraw)
{
	if gd.defBrush != nil do delete_gdi_object(gd.defBrush)
	if gd.hotBrush != nil do delete_gdi_object(gd.hotBrush)
	if gd.defPen != nil do delete_gdi_object(gd.defPen)
	if gd.hotPen != nil do delete_gdi_object(gd.hotPen)
	print("gradDraw freed")
}

@private buttonCtor :: proc(p : ^Form, txt : string, x, y, w, h : int) -> ^Button
{
	if WcButtonW == nil do WcButtonW = to_wstring("Button")
	_buttonCount += 1
	this := new(Button)
	this.kind = .Button
	this.text = txt == "" ? concat_number("Button_", _buttonCount) : txt
	this.width = w
	this.height = h
	this.xpos = x
	this.ypos = y
	this.parent = p
	this.font = p.font
	this._exStyle = 0
	this._style = WS_CHILD | WS_TABSTOP | WS_VISIBLE | BS_NOTIFY
	this._clsName = WcButtonW
	this._drawFlag = 0
	this.foreColor = p.foreColor
	this.backColor = p.backColor
	this._fp_beforeCreation = cast(CreateDelegate) btn_before_creation
	this._fp_afterCreation = cast(CreateDelegate) btn_after_creation
	append(&p._controls, this)
	return this
}

@private new_button1 :: proc(parent : ^Form, autoc : b8 = false) -> ^Button
{
	btn := buttonCtor(parent, "", 10, 10, 120, 35)
	if autoc do create_control(btn)
	return btn
}

@private new_button2 :: proc(parent : ^Form, txt : string, autoc : b8 = false) -> ^Button
{
	btn := buttonCtor(parent, txt, 10, 10, 120, 35)
	if autoc do create_control(btn)
	return btn
}

@private new_button3 :: proc(parent : ^Form, txt : string, x, y : int, autoc : b8 = false) -> ^Button
{
	btn := buttonCtor(parent, txt, x, y, 120, 35)
	if autoc do create_control(btn)
	return btn
}

@private new_button4 :: proc(parent : ^Form, txt : string, x, y, w, h: int, autoc : b8 = false) -> ^Button
{
	btn := buttonCtor(parent, txt, x, y, w, h)
	if autoc do create_control(btn)
	return btn
}

@private btn_before_creation :: proc(b : ^Button) {if b._drawFlag > 0 do check_initial_color_change(b)}

@private btn_after_creation :: proc(b : ^Button)
{
	// if b._draw_mode != .Default && !b._addedInDrawList {
	// 	append(&b.parent._cdraw_childs, b.handle)
	// }
	set_subclass(b, btn_wnd_proc)
}

@private check_initial_color_change :: proc(btn : ^Button)
{
	// There is a chance to user set back/fore color just before creating handle.
	// In that case, we need to check for color changes.
	// if btn.foreColor.value != btn.parent.foreColor.value do btn._drawFlag += 1
	if btn.backColor != btn.parent.backColor {
		flatDrawSetData(&btn._fdraw, btn.backColor)
	}
}

@private set_fore_color_internal :: proc(btn : ^Button, ncd : ^NMCUSTOMDRAW) -> LRESULT
{
	btxt := to_wstring(btn.text)
	SetTextColor(ncd.hdc, get_color_ref(btn.foreColor))
	SetBkMode(ncd.hdc, 1)
	DrawText(ncd.hdc, btxt, -1, &ncd.rc, txtFlag)
	return CDRF_NOTIFYPOSTPAINT
}

@private set_back_color_internal :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> LRESULT
{
	switch nmcd.dwDrawStage
	{
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:
			// We need to change color when user clicks the button with  mouse.
			// But that is only working when we write code in pre-paint stage.
			// It won't work in other stages.
			if (nmcd.uItemState & MOUSE_CLICKED) == MOUSE_CLICKED {
				paint_flat_button(nmcd.hdc, nmcd.rc, btn._fdraw.defBrush, btn._fdraw.hotPen)
			} else if (nmcd.uItemState & MOUSE_OVER) == MOUSE_OVER 	{
				paint_flat_button(nmcd.hdc, nmcd.rc, btn._fdraw.hotBrush, btn._fdraw.hotPen)
			} else  {
				paint_flat_button(nmcd.hdc, nmcd.rc, btn._fdraw.defBrush, btn._fdraw.defPen)
			}
			return  CDRF_DODEFAULT
	}
	return LRESULT(0)
}

@private paint_flat_button :: proc(hdc : HDC, rc : RECT, hbr: HBRUSH, pen: HPEN)
{
	SelectObject(hdc, to_hgdi_obj(hbr))
	SelectObject(hdc, to_hgdi_obj(pen))
	RoundRect(hdc, rc.left, rc.top, rc.right, rc.bottom, ROUND_FACTOR, ROUND_FACTOR)
	FillPath(hdc)
}

@private btn_forecolor_control :: proc(btn : ^ Button, clr : uint)
{	// Public version of this function is in control.odin

	if (btn._drawFlag & 1) != 1 do btn._drawFlag += 1
	btn.foreColor = clr
	if btn._isCreated do InvalidateRect(btn.handle, nil, false)
}

@private btn_backcolor_control :: proc(btn : ^Button, clr : uint)
{  // Public version of this function is in control.odin
	if (btn._drawFlag & 2) != 2 do btn._drawFlag += 2
	btn.backColor = clr
	flatDrawSetData(&btn._fdraw, btn.backColor)
	if btn._isCreated {
		InvalidateRect(btn.handle, nil, false)
	}
}

@private draw_gradient_bkg :: proc(btn : ^Button, nmcd : ^NMCUSTOMDRAW) -> LRESULT
{
	switch nmcd.dwDrawStage
	{
		case CDDS_PREERASE:	// Note: This return value is critical. Otherwise we don't get below notifications.
			return  CDRF_NOTIFYPOSTERASE
		case CDDS_PREPAINT:
			//draw_frame_gr(nmcd.hdc, nmcd.rc, btn._gradient_color.color1, -1, 1)
			if (nmcd.uItemState & MOUSE_CLICKED) == MOUSE_CLICKED {
				paint_gradient_button(btn, nmcd.hdc, nmcd.rc, btn._gdraw.gcDef, btn._gdraw.defPen)
			} else if (nmcd.uItemState & MOUSE_OVER) == MOUSE_OVER {	// color change when mouse is over the btn
				paint_gradient_button(btn, nmcd.hdc, nmcd.rc, btn._gdraw.gcHot, btn._gdraw.hotPen)
			} else {
				paint_gradient_button(btn, nmcd.hdc, nmcd.rc, btn._gdraw.gcDef, btn._gdraw.defPen)
			}
	}
	return CDRF_DODEFAULT
}

@private paint_gradient_button :: proc(btn: ^Button, hdc: HDC, rc: RECT, gc : GradColor, pen: HPEN)
{
	gr_brush : HBRUSH = create_gradient_brush(hdc, rc, gc.c1, gc.c2)
	defer delete_gdi_object(gr_brush)
	select_gdi_object(hdc, pen)
	select_gdi_object(hdc, gr_brush)
	RoundRect(hdc, rc.left, rc.top, rc.right, rc.bottom, ROUND_FACTOR, ROUND_FACTOR)
	FillPath(hdc)
}

@private btn_wmnotify_handler :: proc(btn: ^Button, lpm: LPARAM) -> LRESULT
{
	ret : LRESULT = CDRF_DODEFAULT
	// print("draw flg ", btn._drawFlag)
	if btn._drawFlag > 0 {

		nmcd := direct_cast(lpm, ^NMCUSTOMDRAW)
		switch btn._drawFlag {
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

@private btn_finalize :: proc(btn: ^Button, scid: UINT_PTR)
{
	switch btn._drawFlag {
		case 2, 3: flatDrawDtor(btn._fdraw)
		case 4, 5: gradDrawDtor(btn._gdraw)
	}

	RemoveWindowSubclass(btn.handle, btn_wnd_proc, scid)
	free(btn)
}

//mc : int = 1
@private btn_wnd_proc :: proc "std" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM,
									sc_id : UINT_PTR, ref_data : DWORD_PTR) -> LRESULT
{
	// context = runtime.default_context()
	context = global_context
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
            if btn.onGotFocus != nil
            {
                ea := new_event_args()
                btn.onGotFocus(btn, &ea)
                return 0
            }

        case WM_KILLFOCUS:
            //btn._draw_focus_rct = false
            if btn.onLostFocus != nil
            {
                ea := new_event_args()
                btn.onLostFocus(btn, &ea)
                return 0
            }
			return 0  // Avoid this if you want to show the focus rectangle (....)



		case WM_LBUTTONDOWN:
			btn._mDownHappened = true
			if btn.onMouseDown != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.onMouseDown(btn, &mea)
			}
		case WM_RBUTTONDOWN:
			btn._mRDownHappened = true
			if btn.onRightMouseDown != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.onRightMouseDown(btn, &mea)
			}
		case WM_LBUTTONUP :
			if btn.onMouseUp != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.onMouseUp(btn, &mea)
			}
			if btn._mDownHappened {
				btn._mDownHappened = false
				SendMessage(btn.handle, CM_LMOUSECLICK, 0, 0)
			}

		case CM_LMOUSECLICK :
			btn._mDownHappened = false
			if btn.onMouseClick != nil
			{
				ea := new_event_args()
				btn.onMouseClick(btn, &ea)
				return 0
			}

		case WM_RBUTTONUP :

			if btn.onRightMouseUp != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.onRightMouseUp(btn, &mea)
			}
			if btn._mRDownHappened {
				btn._mRDownHappened = false
				SendMessage(btn.handle, CM_RMOUSECLICK, 0, 0)
			}

		case CM_RMOUSECLICK :
			btn._mRDownHappened = false
			if btn.onRightClick != nil
			{
				ea := new_event_args()
				btn.onRightClick(btn, &ea)
				return 0
			}

		case WM_MOUSEHWHEEL:
			if btn.onMouseScroll != nil
			{
				mea := new_mouse_event_args(msg, wp, lp)
				btn.onMouseScroll(btn, &mea)
			}
		case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
			if btn._isMouseEntered
			{
                if btn.onMouseMove != nil
                {
                    mea := new_mouse_event_args(msg, wp, lp)
                    btn.onMouseMove(btn, &mea)
                }
            }
            else {
                btn._isMouseEntered = true
                if btn.onMouseEnter != nil
                {
                    ea := new_event_args()
                    btn.onMouseEnter(btn, &ea)
                }
            }

		case WM_MOUSELEAVE :
			btn._isMouseEntered = false
            if btn.onMouseLeave != nil
            {
                ea := new_event_args()
                btn.onMouseLeave(btn, &ea)
            }

		case CM_NOTIFY:	return btn_wmnotify_handler(btn, lp)
		case WM_DESTROY: btn_finalize(btn, sc_id)

		case : return DefSubclassProc(hw, msg, wp, lp)


	}
	return DefSubclassProc(hw, msg, wp, lp)
}
