package winforms

import "base:runtime"
import "core:fmt"
import "core:strconv"
import "core:strings"
import api "core:sys/windows"

// Constants ----------
    is_np_inited : bool = false
    ICC_UPDOWN_CLASS :: 0x10
    WcNumPickerW : wstring = L("msctls_updown32")

    UD_MAXVAL :: 0x7fff
    UD_MINVAL :: (-UD_MAXVAL)

    UDS_WRAP :: 0x1
    UDS_SETBUDDYINT :: 0x2
    UDS_ALIGNRIGHT :: 0x4
    UDS_ALIGNLEFT :: 0x8
    UDS_AUTOBUDDY :: 0x10
    UDS_ARROWKEYS :: 0x20
    UDS_HORZ :: 0x40
    UDS_NOTHOUSANDS :: 0x80
    UDS_HOTTRACK :: 0x100

    EN_UPDATE :: 1024
    UDN_FIRST :: (UINT_MAX - 721)
    UDN_DELTAPOS :: (UDN_FIRST - 1)
    swp_flag : DWORD: SWP_SHOWWINDOW | SWP_NOACTIVATE | SWP_NOZORDER

// Constants

NumberPicker :: struct {
    using control : Control,
    buttonOnLeft: bool,
    textAlignment : SimpleTextAlignment,
    minRange, maxRange : f32,
    hasSeparator : bool,
    autoRotate : bool, // use UDS_WRAP style
    hideCaret : bool,
    value : f32,
    formatString : string,
    decimalPrecision : int,
    trackMouseLeave : bool,
    step : f32,

    _buddyHandle : HWND,
    _buddyStyle : DWORD,
    _buddyExStyle : DWORD,
    _buddySubclsID : int,
    _buddyWinProc : SUBCLASSPROC,
    _bkBrush : HBRUSH,
    _borderBrush : HBRUSH,
    _borderPen : HPEN,
    _tbrc : RECT,
    _udrc : RECT,
    _myrc : RECT,
    _updatedTxt : string,

    _topEdgeFlag : DWORD,
    _botEdgeFlag : DWORD,
    _txtPos : SimpleTextAlignment,
    _bgcRef : COLORREF,
    _lineX : i32,

    // Events
    onButtonPaint,
    onTextPaint : PaintEventHandler,
    onValueChanged : EventHandler,
}

StepOprator :: enum {Add, Sub}
ButtonAlignment :: enum {Right, Left}
NMUPDOWN :: struct {
    hdr : NMHDR,
    iPos : i32,
    iDelta : i32,
}


@private np_ctor :: proc(p : ^Form, x, y, w, h : int) -> ^NumberPicker
{
    if !is_np_inited { // Then we need to initialize the date class control.
        is_np_inited = true
        app.iccx.dwIcc = ICC_UPDOWN_CLASS
        InitCommonControlsEx(&app.iccx)
    }
    this := new(NumberPicker)
    this.kind = .Number_Picker
    this.parent = p
    this.font = p.font
    this.width = w
    this.height = h
    this.xpos = x
    this.ypos = y
    this.step = 1
    this.backColor = app.clrWhite
    this.foreColor = app.clrBlack
    this.minRange = 0
    this.maxRange = 100
    this.decimalPrecision = 0
    this.formatString = "%d"
    this._clsName = WcNumPickerW
	this._fp_beforeCreation = cast(CreateDelegate) np_before_creation
	this._fp_afterCreation = cast(CreateDelegate) np_after_creation

    this._style =  WS_VISIBLE | WS_CHILD | UDS_ALIGNRIGHT | UDS_ARROWKEYS | UDS_AUTOBUDDY | UDS_HOTTRACK
    this._buddyStyle = WS_CHILD | WS_VISIBLE | ES_NUMBER | WS_TABSTOP | WS_BORDER
    this._buddyExStyle = WS_EX_LTRREADING | WS_EX_LEFT
    this._exStyle = 0x00000000
    this._topEdgeFlag = BF_TOPLEFT
    this._botEdgeFlag = BF_BOTTOM
    append(&p._controls, this)
    return this
}

@private np_ctor1 :: proc(parent : ^Form, autoc: b8 = false) -> ^NumberPicker
{
    np := np_ctor(parent,10, 10, 80, 25 )
    if autoc do create_control(np)
    return np
}

@private np_ctor2 :: proc(parent : ^Form, x, y : int, autoc: b8 = false, deciPrec: int = 0, step: f32 = 1) -> ^NumberPicker
{
    np := np_ctor(parent, x, y, 80, 25)
    numberpicker_set_decimal_precision(np, deciPrec)
    np.step = step
    if autoc do create_control(np)
    return np
}

@private np_ctor3 :: proc(parent : ^Form, x, y, w, h : int, autoc: b8 = false, deciPrec: int = 0, step: f32 = 1) -> ^NumberPicker
{
    np := np_ctor(parent, x, y, w, h)
    numberpicker_set_decimal_precision(np, deciPrec)
    np.step = step
    if autoc do create_control(np)
    return np
}

new_numberpicker :: proc{np_ctor1, np_ctor2, np_ctor3}

@private set_np_styles :: proc(np : ^NumberPicker)
{
    if np.buttonOnLeft {
        np._style ~= UDS_ALIGNRIGHT
        np._style |= UDS_ALIGNLEFT
        np._topEdgeFlag = BF_TOP
        np._botEdgeFlag = BF_BOTTOMRIGHT
        if np._txtPos == SimpleTextAlignment.Left {np._txtPos = SimpleTextAlignment.Right}
    }
    switch np.textAlignment {
        case .Left : np._buddyStyle |= ES_LEFT
        case .Center : np._buddyStyle |= ES_CENTER
        case .Right : np._buddyStyle |= ES_RIGHT
    }
    clr : Color = new_color(0xABABAB) // Gray color for edit control border
    np._borderBrush = CreateSolidBrush(clr.ref)
}

numberpicker_set_range :: proc(np : ^NumberPicker, max_val, min_val : int)
{
    np.maxRange = f32(max_val)
    np.minRange = f32(min_val)
    if np._isCreated {
        wpm := dir_cast(min_val, WPARAM)
        lpm := dir_cast(max_val, LPARAM)
        SendMessage(np.handle, UDM_SETRANGE32, wpm, lpm)
    }
}

numberpicker_set_decimal_precision :: proc(this: ^NumberPicker, value: int)
{
    this.decimalPrecision = value
    if value == 0 {
        this.formatString = "%d"
    } else if value > 0 {        
        this.formatString = fmt.tprintf("%%.%df", value)
    } else {
        print("numberpicker_set_decimal_precision: Value must be greater than zero...!")
    }

    if this._isCreated do np_display_value_internal(this)
}

@private np_set_range_internal :: proc(np : ^NumberPicker)
{
    wpm := dir_cast(i32(np.minRange), WPARAM)
    lpm := dir_cast(i32(np.maxRange), LPARAM)
    SendMessage(np.handle, UDM_SETRANGE32, wpm, lpm)
}

@private np_set_value_internal :: proc(np : ^NumberPicker, idelta : i32)
{
    new_val : f32 = np.value + (f32(idelta) * np.step)
    if np.autoRotate {
        if new_val > np.maxRange {  // 100.25 > 100.00
            np.value = np.minRange
        } else if new_val < np.minRange {
            np.value = np.maxRange
        } else {
            np.value = new_val
        }
    } else {
        np.value = clamp(new_val, np.minRange, np.maxRange)
    }
    np_display_value_internal(np)
}

@private np_display_value_internal :: proc(np : ^NumberPicker)
{
    val_str : string
    if np.decimalPrecision == 0 {
        val_str = fmt.tprintf(np.formatString, cast(int)np.value)
    } else {        
        val_str = fmt.tprintf(np.formatString, np.value)
    }    
    SetWindowText(np._buddyHandle, to_wchar_ptr(val_str))               
}

@private set_rects_and_size :: proc(np : ^NumberPicker)
{
    /* Mouse leave from a number picker is big problem. Since it is a combo control,
     * So here, we are trying to solve it somehow.
     * There is no magic in it. We just create a big RECT. It can comprise the edit & updown.
     * So, we will map the mouse points into parent's client rect size. Then we will
     * check if those points are inside our big rect. If yes, mouse is on us. Otherwise mouse leaved. */
    SetRect(&np._myrc, i32(np.xpos), i32(np.ypos), i32(np.xpos + np.width), i32(np.ypos + np.height))
    np._tbrc = get_rect(np._buddyHandle) // Textbox rect
    np._udrc = get_rect(np.handle) // Updown btn rect
}

@private resize_buddy :: proc(np : ^NumberPicker)
{
    // Here we are adjusting the edit control near to updown control.
    if np.buttonOnLeft {
        SetWindowPos(np._buddyHandle, nil, i32(np.xpos) + np._udrc.right, i32(np.ypos), np._tbrc.right, np._tbrc.bottom, swp_flag)
        np._lineX = np._tbrc.left
    } else {
        SetWindowPos(np._buddyHandle, nil, i32(np.xpos), i32(np.ypos), np._tbrc.right - 2, np._tbrc.bottom, swp_flag)
        np._lineX = np._tbrc.right - 3
    }
}

@private np_hide_selection :: proc(np : ^NumberPicker)
{
    wpm : i32 = -1
    SendMessage(np._buddyHandle, EM_SETSEL, WPARAM(wpm), 0)
}



@private np_before_creation :: proc(np : ^NumberPicker)
{
    if !is_np_inited {
        icex : INITCOMMONCONTROLSEX
        icex.dwSize = size_of(icex)
        icex.dwIcc = ICC_UPDOWN_CLASS
        InitCommonControlsEx(&icex)
        is_np_inited = true
    }
    set_np_styles(np)
    np._bgcRef = get_color_ref(np.backColor)
}



@private np_after_creation :: proc(np : ^NumberPicker)
{
    ctl_id : UINT= globalCtlID // Use global control ID & update it.
    globalCtlID += 1
    np._buddyHandle = CreateWindowEx( np._buddyExStyle,
                                        to_wstring("Edit"),
                                        nil,
                                        np._buddyStyle,
                                        i32(np.xpos),
                                        i32(np.ypos),
                                        i32(np.width),
                                        i32(np.height),
                                        np.parent.handle,
                                        dir_cast(ctl_id, HMENU),
                                        app.hInstance,
                                        nil )

    
    if np.handle != nil && np._buddyHandle != nil {
        // HWND oldBuddy = HWND(SendMessage(np.handle, UDM_SETBUDDY, convert_to(WPARAM, np._buddyHandle), 0))
        set_np_subclass(np, np_wnd_proc, buddy_wnd_proc)
        if np.font.handle != np.parent.font.handle || np.font.handle == nil do CreateFont_handle(&np.font, np._buddyHandle)
        SendMessage(np._buddyHandle, WM_SETFONT, WPARAM(np.font.handle), LPARAM(1))

        usb := SendMessage(np.handle, UDM_SETBUDDY, WPARAM(np._buddyHandle), 0)
        oldBuddy : HWND = dir_cast(usb, HWND)
        SendMessage(np.handle, UDM_SETRANGE32, WPARAM(np.minRange), LPARAM(np.maxRange))

        set_rects_and_size(np)
        resize_buddy(np)
        if oldBuddy != nil do SendMessage(oldBuddy, CM_BUDDY_RESIZE, 0, 0)
        np_display_value_internal(np)
    }
}

@private numberpicker_property_setter :: proc(this: ^NumberPicker, prop: NumberPickerProps, value: $T)
{
	switch prop {
        case .Button_On_Left: break
        case .Text_Alignment: break
        case .Min_Range:
            when T == int {
                this.minRange = value
                if this._isCreated {
                    SendMessage(this.handle, UDM_SETRANGE32, WPARAM(int(this.minRange)), LPARAM(int(this.maxRange)))
                }
            }
        case .Max_Range:
            when T == int {
                this.maxRange = value
                if this._isCreated {
                    SendMessage(this.handle, UDM_SETRANGE32, WPARAM(int(this.minRange)), LPARAM(int(this.maxRange)))
                }
            }

        case .Has_Separator: break
        case .Auto_Rotate: break
        case .Hide_Caret: break
        case .Value:
            if this._isCreated {
                when T == f32 {
                    this.value = value
                } else when T == int {
                    this.value = f32(value)
                }
                np_display_value_internal(this)
            }
        case .Format_String: break
        case .Decimal_Precision:
            when T == int do numberpicker_set_decimal_precision(this, value)

        case .Track_Mouse_Leave: break
        case .Step: break
    }
}

@private np_paint_buddy_border :: proc(this: ^NumberPicker, hdc: HDC)
{
    /*======================================================================
    Edit control needs WS_BORDER style to place the text properly aligned.
	But if we use that style, it will draw a border on 4 sides of the edit.
	That will separate our updown control and edit control into two parts.
	And that's ugly. So we need to erase all the borders. But it is tricky.	
	First, we will draw a frame over the current border with updown's border color.
	Then, we will erase the right/left side border by drawing a line.
	This line has the same back color of edit control. So the border is hidden. 
	And the control will look like the one in .NET.  
    ===========================================================================*/
    FrameRect(hdc, &this._tbrc, this._borderBrush)
    fpen: HPEN = CreatePen(PS_SOLID, 2, get_color_ref(this.backColor))
    defer delete_gdi_object(fpen)
    SelectObject(hdc, HGDIOBJ(fpen) )
    MoveToEx(hdc, this._lineX, 1, nil)
    LineTo(hdc, this._lineX, this._tbrc.bottom - 2)
}


@private np_finalize :: proc(np: ^NumberPicker, scid: UINT_PTR)
{
    delete_gdi_object(np._bkBrush)
    RemoveWindowSubclass(np.handle, np_wnd_proc, scid)
    delete_gdi_object(np._borderBrush)
    free(np)
}


@private np_wnd_proc :: proc "fast" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                        sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context //runtime.default_context()
    
    //display_msg(msg)
    switch msg {
        case WM_DESTROY : 
            np := control_cast(NumberPicker, ref_data)
            np_finalize(np, sc_id)
            return 0

        case WM_PAINT :
            np := control_cast(NumberPicker, ref_data)
            if np.paint != nil {
                ps : PAINTSTRUCT
                hdc := BeginPaint(hw, &ps)
                pea := new_paint_event_args(&ps)
                np.onButtonPaint(np, &pea)
                EndPaint(hw, &ps)
                return 0
            }
            // return 0

        case WM_CONTEXTMENU:
            np := control_cast(NumberPicker, ref_data)
		    if np.contextMenu != nil do contextmenu_show(np.contextMenu, lp)
            return 0

        case CM_NOTIFY :
            np := control_cast(NumberPicker, ref_data)
            nm := dir_cast(lp, ^NMUPDOWN)
            if nm.hdr.code == UDN_DELTAPOS {
                tbstr : string = get_ctrl_text_internal(np._buddyHandle)
                new_val, _ := strconv.parse_f32(tbstr)
                np.value = new_val
                defer delete(tbstr)                
                np_set_value_internal(np, nm.iDelta)                
            }

            if np.onValueChanged != nil {
                ea := new_event_args()
                np.onValueChanged(np, &ea)
            }
            return 0

        case WM_MOUSEMOVE :
            np := control_cast(NumberPicker, ref_data)
            if np._isMouseEntered {
                if np.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    np.onMouseMove(np, &mea)
                }
            }
            else {
                np._isMouseEntered = true
                if np.onMouseEnter != nil  {
                    ea := new_event_args()
                    np.onMouseEnter(np, &ea)
                }
            }
            return 0

        case WM_MOUSELEAVE :
            np := control_cast(NumberPicker, ref_data)
            if np.trackMouseLeave {
                if !is_mouse_on_me(np) {
                    np._isMouseEntered = false
                    ea := new_event_args()
                    np.onMouseLeave(np, &ea)
                }
            }
            return 0

        case WM_ENABLE :
            np := control_cast(NumberPicker, ref_data)
            api.EnableWindow(hw, auto_cast(wp))
            api.EnableWindow(np._buddyHandle, auto_cast(wp))
            return 0

        //case WM_CANCELMODE : print("WM_CANCELMODE")

        case : return DefSubclassProc(hw, msg, wp, lp)

    }
    return DefSubclassProc(hw, msg, wp, lp)
}

@private buddy_wnd_proc :: proc "fast" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                            sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context //runtime.default_context()
    
    // display_msg(msg)
    switch msg {
        case WM_DESTROY: RemoveWindowSubclass(hw, buddy_wnd_proc, sc_id)
        case WM_PAINT :
            // if tb.paint != nil {
            //     ps : PAINTSTRUCT
            //     hdc := BeginPaint(hw, &ps)
            //     pea := new_paint_event_args(&ps)
            //     tb.onTextPaint(tb, &pea)
            //     EndPaint(hw, &ps)
            //     return 0
            // }
            /* We are drawing the edge line over the edit border.
             * Because, we need our edit & updown look like a single control. */
            tb := control_cast(NumberPicker, ref_data)
            res := DefSubclassProc(hw, msg, wp, lp)
            hdc : HDC = GetWindowDC(hw)
            defer ReleaseDC(hw, hdc)
            np_paint_buddy_border(tb, hdc)
            // DrawEdge(hdc, &tb._tbrc, BDR_SUNKENOUTER, tb._topEdgeFlag) // Right code
            // DrawEdge(hdc, &tb._tbrc, BDR_RAISEDINNER, tb._botEdgeFlag )
            // fpen : HPEN = CreatePen(PS_SOLID, 1, tb._bgcRef) // We use Edit's back color.
            // SelectObject(hdc, HGDIOBJ(fpen))
            // MoveToEx(hdc, tb._lineX, 1, nil)
            // LineTo(hdc, tb._lineX, tb.height - 1)
            // ReleaseDC(hw, hdc)
            // DeleteObject(HGDIOBJ(fpen))

            return res

        case CM_CTLLCOLOR :
            tb := control_cast(NumberPicker, ref_data)
            if tb.foreColor != def_fore_clr || tb.backColor != def_back_clr {
                dc_handle := dir_cast(wp, HDC)
                SetBkMode(dc_handle, Transparent)

                if tb.foreColor != 0x000000 do SetTextColor(dc_handle, get_color_ref(tb.foreColor))
                if tb._bkBrush == nil do tb._bkBrush = CreateSolidBrush(get_color_ref(tb.backColor))
                return toLRES(tb._bkBrush)
            }

        case EM_SETSEL: return 1

        case WM_KEYDOWN :
            tb := control_cast(NumberPicker, ref_data)
            kea := new_key_event_args(wp)
            if tb.onKeyDown != nil {
                tb.onKeyDown(tb, &kea)
            }

        case CM_CTLCOMMAND :
            tb := control_cast(NumberPicker, ref_data)
            ncode := HIWORD(wp)
            if ncode == EN_UPDATE {
                if tb.hideCaret do HideCaret(hw)
            }

        case WM_KEYUP :
            tb := control_cast(NumberPicker, ref_data)
            kea := new_key_event_args(wp)
            if tb.onKeyUp != nil {
                tb.onKeyUp(tb, &kea)
            }
            SendMessage(hw, CM_TBTXTCHANGED, 0, 0)
            return 0

        case WM_CHAR :
            tb := control_cast(NumberPicker, ref_data)
            if tb.onKeyPress != nil {
                kea := new_key_event_args(wp)
                tb.onKeyPress(tb, &kea)
                return 0
            }

        case CM_TBTXTCHANGED :
            tb := control_cast(NumberPicker, ref_data)
             if tb.onValueChanged != nil {
                ea:= new_event_args()
                tb.onValueChanged(tb, &ea)
            }

        case WM_MOUSEMOVE :
            tb := control_cast(NumberPicker, ref_data)
            //print("mouse moved on buddy ")
             if tb._isMouseEntered {
                if tb.onMouseMove != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    tb.onMouseMove(tb, &mea)
                }
            }
            else {
                tb._isMouseEntered = true
                if tb.onMouseEnter != nil  {
                    ea := new_event_args()
                    tb.onMouseEnter(tb, &ea)
                }
            }

        case WM_MOUSELEAVE :
            tb := control_cast(NumberPicker, ref_data)
            if tb.trackMouseLeave {
                if !is_mouse_on_me(tb) {
                    tb._isMouseEntered = false
                    ea := new_event_args()
                    tb.onMouseLeave(tb, &ea)
                }
            }

        case CM_BUDDY_RESIZE: 
            tb := control_cast(NumberPicker, ref_data)
            resize_buddy(tb)


        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return 0 // DefSubclassProc(hw, msg, wp, lp)
}

// Special subclassing for NumberPicker control. Remove_subclass is written in dtor
@private set_np_subclass :: proc(np : ^NumberPicker, np_func, buddy_func : SUBCLASSPROC )
{
	np_dwp := cast(DWORD_PTR)(cast(UINT_PTR) np)
	SetWindowSubclass(np.handle, np_func, UINT_PTR(globalSubClassID), np_dwp )
	globalSubClassID += 1

	SetWindowSubclass(np._buddyHandle, buddy_func, UINT_PTR(globalSubClassID), np_dwp )
	globalSubClassID += 1
}

@private is_mouse_on_me :: proc(np : ^NumberPicker) -> bool
{
    // If this returns False, onMouseLeave event will triggered
    // Since, updown control is a combo of an edit and button controls...
    // we have no better options to control the mouse enter & leave mechanism.
    // Now, we create an imaginary rect over the bondaries of these two controls.
    // If mouse is inside that rect, there is no mouse leave. Perfect hack.
    // fmt.println(np.parent.handle)
    pt : POINT
    GetCursorPos(&pt)
    ScreenToClient(np.parent.handle, &pt)
    return bool(PtInRect(&np._myrc, pt))
}



