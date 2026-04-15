/*===========================NumberPicker Docs==============================
    NumberPicker struct
        Constructor : new_numberpicker() -> ^NumberPicker
        Properties:
            All properties from Control struct
            buttonOnLeft        : bool
            textAlignment       : SimpleTextAlignment - An enum in this file.
            minRange            : f32
            maxRange            : f32
            hasSeparator        : bool
            autoRotate          : bool - Value become min value after max value and vice versa.
            hideCaret           : bool
            value               : f32
            formatString        : string
            decimalPrecision    : int
            trackMouseLeave     : bool - Set true if you want to subscribe mouse leave event.
            step                : f32        

        Functions:
            numberpicker_set_range
            numberpicker_set_decimal_precision
             
        Events:
            EventHandler type events - proc(^Control, ^EventArgs)
                onValueChanged 
            PaintEventHandler type events - proc(^Control, ^PaintEventArgs)
                onButtonPaint
                onTextPaint    
===============================================================================*/

package winforms

import "base:runtime"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:math"
import api "core:sys/windows"


is_np_inited : bool = false    
wcnNumPick := L("msctls_updown32") 
NP_STYLES : u32 = UDS_ALIGNRIGHT | UDS_ARROWKEYS | UDS_AUTOBUDDY | UDS_HOTTRACK   

//MAX_VALUE :: 16 // Increase this value if you need more than 15 digits on 

NumberPicker :: struct 
{
    using control : Control,
    textAlignment : SimpleTextAlignment,
    minRange: f32,
    maxRange : f32,
    value : f32,
    step : f32,
    buttonOnLeft: bool,
    hasSeparator : bool,
    autoRotate : bool, // use UDS_WRAP style
    hideCaret : bool,
    trackMouseLeave : bool,
    formatString : string,
    decimalPrecision : int,    

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
    _npRect: RECT,
    _updatedTxt : string,
    _topEdgeFlag : DWORD,
    _botEdgeFlag : DWORD,
    _txtPos : SimpleTextAlignment,
    _bgcRef : COLORREF,
    _lineX : i32,
    _hoverTriggered: bool,
    _hoverTimer : ^Timer,
     _lastMpos: POINT,
    _disValArr: [dynamic]WCHAR,  

    // Events
    onButtonPaint,
    onTextPaint : PaintEventHandler,
    onValueChanged : EventHandler,
}

// Create new NumberPicker
new_numberpicker :: proc{np_ctor1, np_ctor2, np_ctor3}

// Set the max & min ranges for this NumberPicker
numberpicker_set_range :: proc(this : ^NumberPicker, max_val, min_val : int)
{
    this.maxRange = f32(max_val)
    this.minRange = f32(min_val)
    if this._isCreated {
        wpm := dir_cast(min_val, WPARAM)
        lpm := dir_cast(max_val, LPARAM)
        SendMessage(this.handle, UDM_SETRANGE32, wpm, lpm)
        new_arr_size := calc_value_array_size(this)
        if new_arr_size > len(this._disValArr) do resize(&this._disValArr, new_arr_size)
    }
}

// Set the decimal precision. Default is zero.
numberpicker_set_decimal_precision :: proc(this: ^NumberPicker, value: int)
{
    set_decimal_precision(this, value)
    new_arr_size := calc_value_array_size(this)
    if new_arr_size > len(this._disValArr) do resize(&this._disValArr, new_arr_size)
}




//===================================================================Private Functions======================
@private np_ctor :: proc(p : ^Form, x, y, w, h : int) -> ^NumberPicker
{
    if !is_np_inited { // Then we need to initialize the date class control.
        is_np_inited = true
        app.iccx.dwIcc = ICC_UPDOWN_CLASS
        InitCommonControlsEx(&app.iccx)
    }
    this := new(NumberPicker)
    init_control(this, p, x, y, w, h, .Number_Picker, COMM_CTRL_STYLES | NP_STYLES, 0, 
                    wcnNumPick, TXTABLE, FONTABLE)
    this.step = 1
    this._hasFont = true
    this.backColor = app.clrWhite
    this.foreColor = app.clrBlack
    this.minRange = 0
    this.maxRange = 100
    this.decimalPrecision = 0
    this.formatString = "%d"
	this._fp_beforeCreation = cast(CreateDelegate) np_before_creation
	this._fp_afterCreation = cast(CreateDelegate) np_after_creation
    this._buddyStyle = WS_CHILD | WS_VISIBLE | ES_NUMBER | WS_TABSTOP | WS_BORDER
    this._buddyExStyle = WS_EX_LTRREADING | WS_EX_LEFT
    this._topEdgeFlag = BF_TOPLEFT
    this._botEdgeFlag = BF_BOTTOM
    return this
}

@private np_ctor1 :: proc(parent : ^Form) -> ^NumberPicker
{
    np := np_ctor(parent,10, 10, 80, 25 )
    alloc_value_array(np)
    if parent.createChilds do create_control(np)
    return np
}

@private np_ctor2 :: proc(parent : ^Form, x, y : int, deciPrec: int = 0, step: f32 = 1) -> ^NumberPicker
{
    np := np_ctor(parent, x, y, 80, 25)
    set_decimal_precision(np, deciPrec)
    alloc_value_array(np)
    np.step = step
    if parent.createChilds do create_control(np)
    return np
}

@private np_ctor3 :: proc(parent : ^Form, x, y, w, h : int, deciPrec: int = 0, step: f32 = 1) -> ^NumberPicker
{
    np := np_ctor(parent, x, y, w, h)
    set_decimal_precision(np, deciPrec)
    alloc_value_array(np)
    np.step = step
    if parent.createChilds do create_control(np)
    return np
}

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

    // We are filling our static wchar array with what va_str contains.
    utf8_to_utf16_with_array(val_str, np._disValArr[:])
    SetWindowText(np._buddyHandle, &np._disValArr[0])               
}

@private set_decimal_precision :: proc(this: ^NumberPicker, value: int)
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

@private calc_value_array_size :: proc(this: ^NumberPicker) -> int
{
    val_digits := int(math.log10(this.maxRange)) + 1
    return val_digits + this.decimalPrecision + 2
}

@private alloc_value_array :: proc(this: ^NumberPicker) 
{
    // Let's calculate the size of our array to hold the value string.
    val_digits := int(math.log10(this.maxRange)) + 1
    arr_len := val_digits + this.decimalPrecision + 2
    this._disValArr = make([dynamic]u16, arr_len)
    // ptf("array size %d", arr_len)
}

@private set_rects_and_size :: proc(np : ^NumberPicker)
{
    /* Mouse leave from a number picker is big problem. Since it is a combo control,
     * So here, we are trying to solve it somehow.
     * There is no magic in it. We just create a big RECT. It can comprise the edit & updown.
     * So, we will map the mouse points into parent's client rect size. Then we will
     * check if those points are inside our big rect. If yes, mouse is on us. Otherwise mouse leaved. */
    
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

@private np_after_creation :: proc(this : ^NumberPicker)
{
    ctl_id : UINT= globalCtlID // Use global control ID & update it.
    globalCtlID += 1
    this._buddyHandle = CreateWindowEx( this._buddyExStyle,
                                        to_wstring("Edit"),
                                        nil,
                                        this._buddyStyle,
                                        i32(this.xpos),
                                        i32(this.ypos),
                                        i32(this.width),
                                        i32(this.height),
                                        this.parent.handle,
                                        dir_cast(ctl_id, HMENU),
                                        app.hInstance,
                                        nil )

    
    if this.handle != nil && this._buddyHandle != nil {
        // HWND oldBuddy = HWND(SendMessage(this.handle, UDM_SETBUDDY, convert_to(WPARAM, this._buddyHandle), 0))
        set_np_subclass(this, np_wnd_proc, buddy_wnd_proc)
        if this.font.handle != this.parent.font.handle || this.font.handle == nil {
            font_create_handle(&this.font)
        }
        SendMessage(this._buddyHandle, WM_SETFONT, WPARAM(this.font.handle), LPARAM(1))

        usb := SendMessage(this.handle, UDM_SETBUDDY, WPARAM(this._buddyHandle), 0)
        oldBuddy : HWND = dir_cast(usb, HWND)
        SendMessage(this.handle, UDM_SETRANGE32, WPARAM(this.minRange), LPARAM(this.maxRange))

        set_rects_and_size(this)
        resize_buddy(this)
        if oldBuddy != nil do SendMessage(oldBuddy, CM_BUDDY_RESIZE, 0, 0)
        SetRect(&this._myrc, i32(this.xpos), i32(this.ypos), i32(this.xpos + this.width), i32(this.ypos + this.height))
        np_display_value_internal(this)
    }
}

@private nump_set_hover_timer :: proc(this: ^NumberPicker)
{
    this._hoverTimer = new_timer_internal(this.handle, 400)
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
    hOldObj := SelectObject(hdc, HGDIOBJ(fpen) )
    MoveToEx(hdc, this._lineX, 1, nil)
    LineTo(hdc, this._lineX, this._tbrc.bottom - 2)
    SelectObject(hdc, hOldObj)
}

// Special subclassing for NumberPicker control. Remove_subclass is written in dtor
@private set_np_subclass :: proc(np : ^NumberPicker, np_func, buddy_func : SUBCLASSPROC )
{
	np_dwp := cast(DWORD_PTR)(cast(UINT_PTR) np)
	api.SetWindowSubclass(np.handle, np_func, UINT_PTR(globalSubClassID), np_dwp )
	globalSubClassID += 1

	api.SetWindowSubclass(np._buddyHandle, buddy_func, UINT_PTR(globalSubClassID), np_dwp )
	globalSubClassID += 1
}

@private nump_mouse_move_handler :: proc(this: ^NumberPicker, hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM) 
{
    if this.onMouseMove != nil {
        mea := new_mouse_event_args(msg, wp, lp)
        this.onMouseMove(this, &mea)
    }
    
    if SpecialMouseEvents.Mouse_Hover in this._mouseEvents {
        this._lastMpos.x = cast(i32)LOWORD(lp)
        this._lastMpos.y = cast(i32)HIWORD(lp)
        timer_restart(this._hoverTimer)
        this._hoverTriggered = true
    }

    if SpecialMouseEvents.Mouse_Enter in this._mouseEvents && !this._isMouseEntered {
        this._isMouseEntered = true
        ea := new_event_args()
        this.onMouseEnter(this, &ea)
    }       
}

@private nump_mouse_leave_handler :: proc(this: ^NumberPicker) 
{
    /*-----------------------------------------------------------------------------
        Mouse leave event in NumberPicker control is a bit tricky. It's a combination
        of a text box and button. And if we use UDS_HOTTRACK style, the
        control internally uses TrackMouseEvent function to track the mouse movement
        in the rect of the arrow button only. So we have to create an imaginary rect over 
        the bondaries of these two controls. If mouse is inside that rect, 
        there is no mouse leave. A perfect hack!
    ----------------------------------------------------------------------------------*/
    if mouse_leave_or_hover_set(this._tmeFlags) {
        if this._isMouseEntered || this._isMouseTracking || this._hoverTriggered {
            pt : POINT = {}
            GetCursorPos(&pt)
            ScreenToClient(this.parent.handle, &pt)        
            inside := PtInRect(&this._myrc, pt)
            if !inside {        
                this._isMouseEntered = false
                this._isMouseTracking = false
                if this._hoverTriggered {
                    this._hoverTriggered = false
                    timer_stop(this._hoverTimer)
                }

                if this.onMouseLeave != nil do this.onMouseLeave(this, &gea)
            }
        }
    }
}


@private np_finalize :: proc(this: ^NumberPicker, scid: UINT_PTR)
{
    delete_gdi_object(this._bkBrush)
    delete_gdi_object(this._borderBrush)
    font_destroy(&this.font)
    if SpecialMouseEvents.Mouse_Hover in this._mouseEvents do timer_dtor(this._hoverTimer)
    RemoveWindowSubclass(this.handle, np_wnd_proc, scid)  
    delete(this._disValArr)  
    free(this)
}


@private np_wnd_proc :: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                        sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context 
    nump := control_cast(NumberPicker, ref_data)
    
    res := ctrl_common_msg_handler(nump, hw, msg, wp, lp) 
    #partial switch res {
        case .Call_Def_Proc: return DefSubclassProc(hw, msg, wp, lp)
        case .Immediate_Return: return 1
    }

    switch msg {
        case WM_TIMER:
        if nump.onMouseHover != nil {
            timer_stop(nump._hoverTimer)
            nump.onMouseHover(nump, &gea)
            return 0
        }
    case WM_DESTROY :             
        np_finalize(nump, sc_id)
        return 0

    case WM_PAINT :
        if nump.onPaint != nil {
            ps : PAINTSTRUCT
            hdc := BeginPaint(hw, &ps)
            pea := new_paint_event_args(&ps)
            nump.onButtonPaint(nump, &pea)
            EndPaint(hw, &ps)
            return 0
        }
        
    case CM_NOTIFY :
        nm := dir_cast(lp, ^NMUPDOWN)
        if nm.hdr.code == UDN_DELTAPOS {
            tbstr : string = get_ctrl_text_internal(nump._buddyHandle)
            new_val, _ := strconv.parse_f32(tbstr)
            nump.value = new_val
            defer delete(tbstr)                
            np_set_value_internal(nump, nm.iDelta)                
        }

        if nump.onValueChanged != nil {
            ea := new_event_args()
            nump.onValueChanged(nump, &ea)
        }
        return 0       

    case WM_ENABLE :
        api.EnableWindow(hw, auto_cast(wp))
        api.EnableWindow(nump._buddyHandle, auto_cast(wp))
        return 0

    case : 
        return DefSubclassProc(hw, msg, wp, lp)

    }
    return DefSubclassProc(hw, msg, wp, lp)
}

@private buddy_wnd_proc :: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                            sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context
    nump := control_cast(NumberPicker, ref_data)

    res := ctrl_common_msg_handler(nump, hw, msg, wp, lp) 
    #partial switch res {
        case .Call_Def_Proc: return DefSubclassProc(hw, msg, wp, lp)
        case .Immediate_Return: return 1
    }

    switch msg {
        case WM_DESTROY: RemoveWindowSubclass(hw, buddy_wnd_proc, sc_id)
        case WM_PAINT:
            /* 
             * We are drawing the edge line over the edit border.
             * Because, we need our edit & updown look like a single control. 
             */            
            res := DefSubclassProc(hw, msg, wp, lp)
            hdc : HDC = GetWindowDC(hw)
            defer ReleaseDC(hw, hdc)
            np_paint_buddy_border(nump, hdc)           
            return res  

        case CM_EDIT_COLOR:
            if nump.foreColor != def_fore_clr || nump.backColor != def_back_clr {
                dc_handle := dir_cast(wp, HDC)
                api.SetBkMode(dc_handle, api.BKMODE.TRANSPARENT)
                if nump.foreColor != 0x000000 do SetTextColor(dc_handle, get_color_ref(nump.foreColor))
                if nump._bkBrush == nil do nump._bkBrush = CreateSolidBrush(get_color_ref(nump.backColor))
                return toLRES(nump._bkBrush)
            }

        case EM_SETSEL: return 1

        case WM_KEYDOWN:
            kea := new_key_event_args(wp)
            if nump.onKeyDown != nil {
                nump.onKeyDown(nump, &kea)
            }

        case CM_CTLCOMMAND:
            ncode := HIWORD(wp)
            if ncode == EN_UPDATE {
                if nump.hideCaret do HideCaret(hw)
            }

        case WM_KEYUP:
            kea := new_key_event_args(wp)
            if nump.onKeyUp != nil {
                nump.onKeyUp(nump, &kea)
            }
            SendMessage(hw, CM_TBTXTCHANGED, 0, 0)
            return 0

        case WM_CHAR:
            if nump.onKeyPress != nil {
                kea := new_key_event_args(wp)
                nump.onKeyPress(nump, &kea)
                return 0
            }

        case CM_TBTXTCHANGED:
             if nump.onValueChanged != nil {
                ea:= new_event_args()
                nump.onValueChanged(nump, &ea)
            }

        case CM_BUDDY_RESIZE: 
            resize_buddy(nump)
            SetRect(&nump._myrc, i32(nump.xpos), i32(nump.ypos), 
                    i32(nump.xpos + nump.width), i32(nump.ypos + nump.height))

        case : return DefSubclassProc(hw, msg, wp, lp)
    }
    return 0 // DefSubclassProc(hw, msg, wp, lp)
}





