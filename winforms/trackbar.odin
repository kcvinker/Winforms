/*
    Created on: 03-Feb-2022 6:39:51 PM
    Name: TrackBar type.
*/

/*===========================================TrackBar Docs=========================================================
    TrackBar struct
        Constructor: new_trackbar() -> ^TrackBar
        Properties:
            All props from Control struct
            ticPos         : bool
            TicPosition    : bool
            noTick         : bool
            channelColor   : uint
            ticColor       : uint
            ticWidth       : int
            minRange       : int 
            maxRange       : int
            frequency      : i32
            pageSIze       : int
            lineSize       : int
            ticLength      : i32
            defaultTics    : bool
            value          : int
            vertical       : bool
            reversed       : bool
            selRange       : bool
            noThumb        : bool
            toolTip        : bool
            customDraw     : bool
            freeMove       : bool
            selColor       : uint
            channelStyle   : ChannelStyle - An enum in this file
        Functions:
			trackbar_set_value

        Events:
			All events from Control struct
            EventHandler type [proc(^Control, ^EventARgs)]
                onValueChanged
                onDragging
                onDragged
==============================================================================================================*/


package winforms
import "base:runtime"
import "core:fmt"
import api "core:sys/windows"

// Constants
    


/*-------------------------------------------------------------------------- 
We are converting these literals to dword pointer.
Because, at the custom draw area, we need to check the...
drawing stage with these literals. But odin didn't allow...
us to use dword pointer on lhs and a dword on rhs. So this will fix that problem. 
----------------------------------------------------------------------------------*/
TbTestCdraw:= dir_cast( 0x0, DWORD_PTR)
TkbTicsCdraw := dir_cast(0x1, DWORD_PTR)
TkbThumbCdraw:= dir_cast( 0x2, DWORD_PTR)
TkbChannelCdraw:= dir_cast( 0x3, DWORD_PTR)
TkbItemPrePaint:= dir_cast(65537, DWORD_PTR)

WcTrackbarClassW: wstring = L("msctls_trackbar32")
trkcount: int = 0


TrackBar:: struct 
{
    using control: Control,
    ticPos: TicPosition,
    noTick: bool,
    channelColor,
    ticColor: uint,
    ticWidth: int,
    minRange, maxRange: int,
    frequency: i32,
    pageSIze: int,
    lineSize: int,
    ticLength: i32,
    defaultTics: bool,
    value: int,
    vertical: bool,
    reversed: bool,
    selRange  : bool,
    noThumb  : bool,
    toolTip  : bool,
    customDraw  : bool,
    freeMove  : bool,
    selColor: uint,
    channelStyle: ChannelStyle,

    // Private members
    _bkBrush: HBRUSH,
    _selBrush: HBRUSH,
    _chanPen: HPEN,
    _ticPen: HPEN,
    _ticCount: i32,
    _defTics: bool,
    _chanRC, _thumbRC, _myrc: RECT,
    _ticDataList: [dynamic]TicData,
    _thumbHalf: i32,
    _p1, _p2: i32,
    _range: i32,
    _chanFlag: DWORD,

    // Event Members
    onValueChanged, onDragging, onDragged: EventHandler,
}

// Create new TrackBar
new_trackbar:: proc{new_tbar1, new_tbar2, new_tbar3}

// Set trackbar value
trackbar_set_value:: proc(tk: ^TrackBar, value: int)
{
    if value > tk.maxRange || value < tk.minRange do return
    SendMessage(tk.handle, TBM_SETPOS, WPARAM(1), LPARAM(i32(value)) )
}


// This struct is to hold the tic's physical pos and logical pos.
TicData:: struct
{
    phyPoint: i32,
    logPoint: i32,
}



//=================================================Private Functions===========================
@private new_ticdata:: proc(pp: i32, lp: i32) -> TicData
{
    tc: TicData
    tc.phyPoint = pp
    tc.logPoint = lp
    return tc
}

@private tbar_ctor:: proc(f: ^Form, x, y, w, h: int) -> ^TrackBar
{
    if trkcount == 0
    {
        app.iccx.dwIcc = 0x4
        InitCommonControlsEx(&app.iccx)
    }
    this:= new(TrackBar)
    trkcount += 1
    this.kind = .Track_Bar
    this.parent = f
    this.xpos = x
    this.ypos = y
    this.width = w
    this.height = h
    this.backColor = f.backColor
    this.channelColor = light_steel_blue
    this.ticColor = 0x000000
    this.frequency = 10
    this.ticWidth = 1
    this.ticLength = 4
    this.lineSize = 1
    this.pageSIze = 10
    this.ticPos = TicPosition.Down_Side
    this.channelStyle = ChannelStyle.outline
    this.minRange = 0
    this.maxRange = 100
    this.customDraw = true
    this.channelColor = 0xc2c2a3
    this.selColor = 0x99ff33
    this.ticColor = 0x3385ff

    this._style = WS_CHILD | WS_VISIBLE | TBS_AUTOTICKS
    this._exStyle = 0
    this.text = "my track"
    this._clsName = WcTrackbarClassW
    this._fp_beforeCreation = cast(CreateDelegate) tkb_before_creation
	this._fp_afterCreation = cast(CreateDelegate) tkb_after_creation
    this._chanFlag = BF_RECT | BF_ADJUST
    font_clone(&f.font, &this.font )
    append(&f._controls, this)
    return this
}

@private new_tbar1:: proc(parent: ^Form) -> ^TrackBar
{
    tkb:= tbar_ctor(parent, 10, 10, _def_tkb_width, _def_tkb_height)
    if parent.createChilds do create_control(tkb)
    return tkb
}

@private new_tbar2:: proc(parent: ^Form, x, y: int) -> ^TrackBar
{
    tkb:= tbar_ctor(parent, x, y, _def_tkb_width, _def_tkb_height)
    if parent.createChilds do create_control(tkb)
    return tkb
}

@private new_tbar3:: proc(parent: ^Form, x, y, w, h: int) -> ^TrackBar
{
    tkb:= tbar_ctor(parent, x, y, w, h)
    if parent.createChilds do create_control(tkb)
    return tkb
}

@private tkb_adjust_styles:: proc(tkb: ^TrackBar)
{
    if tkb.vertical {
        tkb._style |= TBS_VERT
        #partial switch tkb.ticPos {
            case .Right_Side: tkb._style |= TBS_RIGHT
            case .Left_Side: tkb._style |= TBS_LEFT
            case .Both_Side: tkb._style |= TBS_BOTH
        }
    } else {
        #partial switch tkb.ticPos {
            case .Down_Side: tkb._style |= TBS_BOTTOM
            case .Up_Side: tkb._style |= TBS_TOP
            case .Both_Side: tkb._style |= TBS_BOTH
        }
    }

    if tkb.selRange{
        tkb._style |= TBS_ENABLESELRANGE
        tkb._chanFlag = BF_RECT | BF_ADJUST | BF_FLAT
        tkb.customDraw = true
    }
    if tkb.reversed do tkb._style |= TBS_REVERSED
    if tkb.noTick do tkb._style |= TBS_NOTICKS
    if tkb.noThumb do tkb._style |= TBS_NOTHUMB
    if tkb.toolTip do tkb._style |= TBS_TOOLTIPS
    tkb._bkBrush = get_solid_brush(tkb.backColor)
}

@private setup_value_internal:: proc(tk: ^TrackBar, value: i32)
{
    if tk.reversed {
        tk.value = int(U16MAX - value)
    } else {
        tk.value = int(value)
    }
}

@private draw_vertical_tics:: proc(hdc: HDC, px: i32, py: i32, ticlen: i32)
{
    MoveToEx(hdc, px, py, nil);
    LineTo(hdc, px + ticlen, py)
}

@private draw_horiz_tics_down:: proc(hdc: HDC, px: i32, py: i32, ticlen: i32)
{
    MoveToEx(hdc, px, py, nil);
    LineTo(hdc, px, py + ticlen)
}

@private draw_horiz_tics_upper:: proc(hdc: HDC, px: i32, py: i32, ticlen: i32)
{
    MoveToEx(hdc, px, py, nil);
    LineTo(hdc, px, py - ticlen)
}

@private draw_tics:: proc(tk: ^TrackBar, hdc: HDC)
{
    SelectObject(hdc, HGDIOBJ(tk._ticPen))
    if tk.vertical {
        #partial switch tk.ticPos {
            case TicPosition.Right_Side, TicPosition.Left_Side:
                for p in tk._ticDataList do draw_vertical_tics(hdc, tk._p1, p.phyPoint, tk.ticLength)
            case TicPosition.Both_Side:
                for p in tk._ticDataList {
                    draw_vertical_tics(hdc, tk._p1, p.phyPoint, tk.ticLength)
                    draw_vertical_tics(hdc, tk._p2, p.phyPoint, tk.ticLength)
                }
        }

    } else {
        #partial switch tk.ticPos {
            case TicPosition.Up_Side, TicPosition.Down_Side:
                for p in tk._ticDataList do draw_horiz_tics_down(hdc, p.phyPoint, tk._p1, tk.ticLength)
            case TicPosition.Both_Side:
                for p in tk._ticDataList {
                    draw_horiz_tics_down(hdc, p.phyPoint, tk._p1, tk.ticLength)
                    draw_horiz_tics_upper(hdc, p.phyPoint, tk._p2, tk.ticLength)
                }
        }
    }
}

@private calculate_tics:: proc(tk: ^TrackBar)
{
    twidth, stpos, enpos,tic, numtics: i32
    pfactor, range, chanlen: f32

    // Collectiing required rects
    GetClientRect(tk.handle, &tk._myrc) // Get Trackbar rect
    SendMessage(tk.handle, TBM_GETTHUMBRECT, 0, dir_cast(&tk._thumbRC, LPARAM)) // Get the thumb rect
    SendMessage(tk.handle, TBM_GETCHANNELRECT, 0, dir_cast(&tk._chanRC, LPARAM)) // Get the channel rect

    //2. Calculate thumb offset
    if tk.vertical {
        twidth = tk._thumbRC.bottom - tk._thumbRC.top
    } else {
        twidth = tk._thumbRC.right - tk._thumbRC.left
    }

    tk._thumbHalf = i32(twidth / 2)

    // Now calculate required variables
    tk._range = i32(tk.maxRange - tk.minRange)
    numtics = tk._range / tk.frequency
    if int(tk._range) %% int(tk.frequency) == 0 do numtics -= 1
    // fmt.printf("tk._range = %d, tk.frequency = %d  modulo = %d\n", tk._range, tk.frequency,  (tk._range %% tk.frequency))
    // fmt.printf("tk._thumbHalf = %d, \n", tk._thumbHalf)
    stpos = tk._chanRC.left + tk._thumbHalf
    enpos = tk._chanRC.right - tk._thumbHalf - 1
    chanlen = f32(enpos - stpos)
    pfactor = chanlen / f32(tk._range)
    // fmt.printf("stpos = %d, enpos = %d, channel len = %d, pFactor = %f \n", stpos, enpos, chanlen, pfactor )

    // Let's fill the tic data array
    tic = i32(tk.minRange + int(tk.frequency))
    append(&tk._ticDataList, new_ticdata(stpos, 0)) // Very first tic
    for i:= 0; i < int(numtics); i += 1 {
        append(&tk._ticDataList, new_ticdata(i32((f32(tic) * pfactor) + f32(stpos)), tic)) // Middle tics
        tic += i32(tk.frequency)
    }
    append(&tk._ticDataList, new_ticdata(enpos, i32(tk._range))) // Last tic

    // Now, set up single point (x/y) for tics.
    if tk.vertical {
        #partial switch tk.ticPos {
            case TicPosition.Left_Side: tk._p1 = tk._thumbRC.left - 5
            case TicPosition.Right_Side: tk._p1 = tk._thumbRC.right + 2
            case TicPosition.Both_Side:
                tk._p1 = tk._thumbRC.right + 2
                tk._p2 = tk._thumbRC.left - 5
        }
    } else {
        #partial switch (tk.ticPos) {
            case TicPosition.Down_Side: tk._p1 = tk._thumbRC.bottom + 1
            case TicPosition.Up_Side: tk._p1 = tk._thumbRC.top - 4
            case TicPosition.Both_Side:
                tk._p1 = tk._thumbRC.bottom + 1
                tk._p2 = tk._thumbRC.top - 3
        }
    }

    // for t in tk._ticDataList {
    //     fmt.printf("phy: %d, log: %d\n", t.phyPoint, t.logPoint)
    // }
}

@private get_thumb_rect:: proc(h: HWND) -> RECT
{
    rc: RECT
    SendMessage(h, TBM_GETTHUMBRECT, 0, dir_cast(&rc, LPARAM))
    return rc
}

@private fill_channel_rect:: proc(tk: ^TrackBar, nm: LPNMCUSTOMDRAW, trc: RECT) -> bool
{
    /*===========================================================================
    If 'show_selection' property is enabled in this trackbar,...
    we need to show the area between thumb and channel starting in diff color.
    But we need to check if the trackbar is reversed or not.
    NOTE: If we change the drawing flags for DrawEdge function in channel drawing area,
    We need to reduce the rect size 1 point. Because, current flags working perfectly...
    Without adsting rect. So change it carefully. 
    =================================================================================*/
    result: bool = false
    rct: RECT

    if tk.vertical {
        rct.left = nm.rc.left
        rct.right = nm.rc.right
        if tk.reversed {
            rct.top = trc.bottom
            rct.bottom = nm.rc.bottom
        } else {
            rct.top = nm.rc.top
            rct.bottom = trc.top
        }
    } else {
        rct.top = nm.rc.top
        rct.bottom = nm.rc.bottom
        if tk.reversed {
            rct.left = trc.right
            rct.right = nm.rc.right
        } else {
            rct.left = nm.rc.left
            rct.right = trc.left
        }
    }

    result = bool(api.FillRect(nm.hdc, &rct, tk._selBrush))
    return result
}

@private send_initial_messages:: proc(tk: ^TrackBar)
{
    if tk.reversed {
        SendMessage(tk.handle, TBM_SETRANGEMIN, WPARAM(1), LPARAM(tk.maxRange * -1))
        SendMessage(tk.handle, TBM_SETRANGEMAX, WPARAM(1), LPARAM(tk.minRange))
    } else {
        SendMessage(tk.handle, TBM_SETRANGEMIN, WPARAM(1), LPARAM(tk.minRange))
        SendMessage(tk.handle, TBM_SETRANGEMAX, WPARAM(1), LPARAM(tk.maxRange))
    }
    SendMessage(tk.handle, TBM_SETTICFREQ, WPARAM(tk.frequency), 0)
    SendMessage(tk.handle, TBM_SETPAGESIZE, 0, LPARAM(tk.pageSIze))
    SendMessage(tk.handle, TBM_SETLINESIZE, 0, LPARAM(tk.lineSize))
}

@private trackbar_backcolor_setter:: proc(this: ^TrackBar, clr: uint)
{
    this.backColor = clr
    if (this._drawFlag & 2) != 2 do this._drawFlag += 2
    if this._isCreated {
        SendMessage(this.handle, TBM_SETRANGEMAX, 1, this.maxRange)
        InvalidateRect(this.handle, nil, false)
    }
}

@private tkb_before_creation:: proc(tkb: ^TrackBar) {tkb_adjust_styles(tkb)}

@private tkb_after_creation:: proc(tkb: ^TrackBar)
{
    // Prepare for custom draw
    tkb._chanPen = CreatePen(PS_SOLID, 1, get_color_ref(tkb.channelColor))
    tkb._ticPen = CreatePen(PS_SOLID, i32(tkb.ticWidth), get_color_ref(tkb.ticColor))

    // Calculate tic positions.
    if tkb.customDraw do calculate_tics(tkb)
    set_subclass(tkb, tkb_wnd_proc)

    // Send some important messages to Wndproc function.
    send_initial_messages(tkb)    
    
    // Prepare our selection range brush if needed.
    // if tkb.selRange do tkb._selBrush = get_solid_brush(tkb.selColor)
}

@private trackbar_property_setter:: proc(this: ^TrackBar, prop: TrackBarProps, value: $T)
{
	switch prop {
        case .Tic_Pos: break
        case .No_Tick: break
        case .Channel_Color: break
        case .Tic_Color: break
        case .Tic_Width: break
        case .Min_Range: break
        case .Frequency: break
        case .Page_S_Ize: break
        case .Line_Size: break
        case .Tic_Length: break
        case .Default_Tics: break
        case .Value: break
        case .Vertical: break
        case .Reversed: break
        case .Sel_Range: break
        case .No_Thumb: break
        case .Tool_Tip: break
        case .Custom_Draw: break
        case .Free_Move: break
        case .Sel_Color: break
        case .Channel_Style: break
	}
}

@private tkb_finalize:: proc(this: ^TrackBar, scid: UINT_PTR)
{
    delete_gdi_object(this._bkBrush)
    delete_gdi_object(this._selBrush)
    font_destroy(&this.font)
    delete(this._ticDataList)
    RemoveWindowSubclass(this.handle, tkb_wnd_proc, scid)
    free(this)
}

@private tkb_wnd_proc:: proc "stdcall" (hw: HWND, msg: u32, wp: WPARAM, lp: LPARAM,
                                        sc_id: UINT_PTR, ref_data: DWORD_PTR) -> LRESULT
{
    context = global_context 
    
    // display_msg(msg)
    switch msg {
        case WM_DESTROY: 
            tkb:= control_cast(TrackBar, ref_data)
            tkb_finalize(tkb, sc_id)

        case WM_CONTEXTMENU:
            tkb:= control_cast(TrackBar, ref_data)
		    if tkb.contextMenu != nil do contextmenu_show(tkb.contextMenu, lp)

        case CM_STATIC_COLOR:
            // hdc:= dir_cast(wp, HDC)
            // SetTextColor(hdc, get_color_ref(tkb.foreColor))
            // tkb._bkBrush = CreateSolidBrush(get_color_ref(tkb.backColor))
            tkb:= control_cast(TrackBar, ref_data)
            // ptf("tkb brush %d", tkb._bkBrush)
            return dir_cast(tkb._bkBrush, LRESULT)

        case CM_NOTIFY:
            nmh:= dir_cast(lp, ^NMHDR)
            if nmh.code == NM_CUSTOMDRAW {
                tkb:= control_cast(TrackBar, ref_data)
                if tkb.customDraw {
                    nmcd:= dir_cast(lp, ^NMCUSTOMDRAW)
                    switch nmcd.dwDrawStage {
                        case CDDS_PREPAINT: 
                            return CDRF_NOTIFYITEMDRAW

                        case CDDS_ITEMPREPAINT:
                            switch nmcd.dwItemSpec {

                                // TkbTicsCdraw is not a magical value. Explanation is given at line 39
                                case TkbTicsCdraw:
                                    if (!tkb.noTick) do draw_tics(tkb, nmcd.hdc)                                       
                                    return CDRF_SKIPDEFAULT

                                // TkbChannelCdraw is not a magical value. Explanation is given at line 39
                                case TkbChannelCdraw:
                                    /*======================================================================== 
                                    In Python project i am using EDGE_SUNKEN style without BF_FLAT.
                                    in D, it gives a strange outline in those flags. So I decided to use...
                                    these flags. But in this case, we don't need to reduce 1 point from...
                                    the coloring rect. It looks perfect without changing rect. 
                                    ==========================================================================*/
                                    if !tkb.selRange {
                                        if tkb.channelStyle == ChannelStyle.classic {
                                            DrawEdge(nmcd.hdc, &nmcd.rc, BDR_SUNKENOUTER, tkb._chanFlag)
                                        } else {
                                            SelectObject(nmcd.hdc, HGDIOBJ(tkb._chanPen))
                                            Rectangle(nmcd.hdc, nmcd.rc.left, nmcd.rc.top, nmcd.rc.right, nmcd.rc.bottom );
                                        }
                                    } else {
                                        /*===================================================
                                        This gives a pleasant look when selRange is enabled.
                                        Without a border(or edge), channel looks ugly. 
                                        =====================================================*/
                                        DrawEdge(nmcd.hdc, &nmcd.rc, BDR_OUTER, BIG_CHANNEL_EDGE)
                                        rc: RECT = get_thumb_rect(hw)
                                        if fill_channel_rect(tkb, nmcd, rc) do InvalidateRect(hw, &nmcd.rc, false)
                                    }
                                    return CDRF_SKIPDEFAULT
                            }
                    }
                } else {
                    return CDRF_DODEFAULT
                }
            }


        case WM_LBUTTONDOWN:
           // tkb._draw_focus_rct = true
           tkb:= control_cast(TrackBar, ref_data)            
            if tkb.onMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tkb.onMouseDown(tkb, &mea)
                return 0
            }

        case WM_RBUTTONDOWN:
            tkb:= control_cast(TrackBar, ref_data)            
            if tkb.onRightMouseDown != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tkb.onRightMouseDown(tkb, &mea)
            }

        case WM_LBUTTONUP:
            tkb:= control_cast(TrackBar, ref_data)
            if tkb.onMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tkb.onMouseUp(tkb, &mea)
            }            
            if tkb.onClick != nil {
                ea:= new_event_args()
                tkb.onClick(tkb, &ea)
                return 0
            }

        case WM_LBUTTONDBLCLK:
            tkb:= control_cast(TrackBar, ref_data)
            if tkb.onDoubleClick != nil {
                ea:= new_event_args()
                tkb.onDoubleClick(tkb, &ea)
                return 0
            }

        case WM_RBUTTONUP:
            tkb:= control_cast(TrackBar, ref_data)
            if tkb.onRightMouseUp != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tkb.onRightMouseUp(tkb, &mea)
            }           
            if tkb.onRightClick != nil {
                ea:= new_event_args()
                tkb.onRightClick(tkb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            tkb:= control_cast(TrackBar, ref_data)
            if tkb.onMouseScroll != nil {
                mea:= new_mouse_event_args(msg, wp, lp)
                tkb.onMouseScroll(tkb, &mea)
            }
        case WM_MOUSEMOVE: // Mouse Enter & Mouse Move is happening here.
            tkb:= control_cast(TrackBar, ref_data)
            if tkb._isMouseEntered {
                if tkb.onMouseMove != nil {
                    mea:= new_mouse_event_args(msg, wp, lp)
                    tkb.onMouseMove(tkb, &mea)
                }
            }
            else {
                tkb._isMouseEntered = true
                if tkb.onMouseEnter != nil  {
                    ea:= new_event_args()
                    tkb.onMouseEnter(tkb, &ea)
                }
            }

        case WM_MOUSELEAVE:
            tkb:= control_cast(TrackBar, ref_data)
            tkb._isMouseEntered = false
            if tkb.onMouseLeave != nil {
                ea:= new_event_args()
                tkb.onMouseLeave(tkb, &ea)
            }

        case WM_HSCROLL, WM_VSCROLL:
            tkb:= control_cast(TrackBar, ref_data)
            lwp:= LOWORD(wp)
            switch lwp {
                case TB_THUMBPOSITION:
                    setup_value_internal(tkb, i32(HIWORD(wp)))
                    if !tkb.freeMove {
                        pos: i32 = i32(tkb.value)
                        half: f32 = f32(tkb.frequency) / 2
                        diff: i32 = pos %% i32(tkb.frequency)

                        if diff >= i32(half) {
                            pos = (i32(tkb.frequency) - diff) + i32(tkb.value)
                        } else if diff < i32(half) {
                            pos =  i32(tkb.value) - diff
                        }

                        if tkb.reversed {
                            SendMessage(hw, TBM_SETPOS, WPARAM(1), LPARAM(pos * -1))
                        } else {
                            SendMessage(hw, TBM_SETPOS, WPARAM(1), LPARAM(pos))
                        }

                        tkb.value = int(pos)
                    }

                    // We need to refresh Trackbar in order to display our new drawings.
                    InvalidateRect(hw, &tkb._chanRC, false)

                    if tkb.onDragged != nil {
                        ea:= new_event_args()
                        tkb.onDragged(tkb, &ea)
                    }

                    if tkb.onValueChanged != nil {
                        ea:= new_event_args()
                        tkb.onValueChanged(tkb, &ea)
                    }

                case THUMB_LINE_HIGH, THUMB_LINE_LOW, THUMB_PAGE_HIGH, THUMB_PAGE_LOW:
                    setup_value_internal(tkb, i32(SendMessage(hw, TBM_GETPOS, 0, 0)))
                    if tkb.onValueChanged != nil {
                        ea:= new_event_args()
                        tkb.onValueChanged(tkb, &ea)
                    }

                case TB_THUMBTRACK:
                    setup_value_internal(tkb, i32(SendMessage(hw, TBM_GETPOS, 0, 0)))
                    if tkb.onDragging != nil {
                        ea:= new_event_args()
                        tkb.onDragging(tkb, &ea)
                    }
            }

        // case: return DefSubclassProc(hw, msg, wp, lp)
    }
    return DefSubclassProc(hw, msg, wp, lp)
}

