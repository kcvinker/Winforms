/*
    Created on : 03-Feb-2022 6:39:51 PM
    Name : TrackBar type.
*/

package winforms
import "core:runtime"
//import "core:fmt"

// Constants 
    TBS_AUTOTICKS :: 0x1
    TBS_VERT :: 0x2
    TBS_HORZ :: 0x0
    TBS_TOP :: 0x4
    TBS_BOTTOM :: 0x0
    TBS_LEFT :: 0x4
    TBS_RIGHT :: 0x0
    TBS_BOTH :: 0x8
    TBS_NOTICKS :: 0x10
    TBS_ENABLESELRANGE :: 0x20
    TBS_FIXEDLENGTH :: 0x40
    TBS_NOTHUMB :: 0x80
    TBS_TOOLTIPS :: 0x100
    TBS_REVERSED :: 0x200
    TBS_DOWNISLEFT :: 0x400

    TbTestCdraw := direct_cast( 0x0, DwordPtr)
    TkbTicsCdraw  := direct_cast(0x1, DwordPtr)
    TkbThumbCdraw := direct_cast( 0x2, DwordPtr)
    TkbChannelCdraw := direct_cast( 0x3, DwordPtr)
    TkbItemPrePaint := direct_cast(65537, DwordPtr)

    
// Constants End

WcTrackbarClassW : wstring
_def_tkb_width :: 150
_def_tkb_height :: 30

TrackBar :: struct {
    using control : Control,
    orientation : enum {Horizontal, Vertical},
    tic_pos : enum {Down_Side, Up_Side, Left_Side, Right_Side, Both_Side},
    reverse_start_pos :bool,
    no_ticks : bool,
    enable_sel_range : bool,
       
    channel_color,
    tic_color : uint,
    tic_width : int,
    jump_distance : int,
    min_range, max_range : int,
    frequency : int,
    default_tics : bool,
    value : int,

    _bk_brush : Hbrush,    
    _tic_count : i32,

    value_changed : EventHandler,
}

new_trackbar :: proc{new_tbar1, new_tbar2, new_tbar3}

@private tbar_ctor :: proc(f : ^Form, x, y, w, h : int) -> TrackBar {
    if WcTrackbarClassW == nil {
        WcTrackbarClassW = to_wstring("msctls_trackbar32")
        app.iccx.dwIcc = 0x4
        InitCommonControlsEx(&app.iccx)
    }

    tkb : TrackBar
    tkb.kind = .Track_Bar
    tkb.parent = f
    tkb.font = f.font
    tkb.xpos = x
    tkb.ypos = y
    tkb.width = w
    tkb.height = h
    tkb.back_color = f.back_color   
    tkb.channel_color = light_steel_blue
    tkb.tic_color = 0x000000
    tkb.tic_width = 1
    tkb.min_range = 0
    tkb.max_range = 100
    tkb.frequency = 10
    tkb.jump_distance = 1
    tkb._style = WS_CHILD | WS_VISIBLE | TBS_AUTOTICKS 
    tkb._ex_style = 0
    tkb.text = "my track"
    return tkb
}

@private new_tbar1 :: proc(parent : ^Form) -> TrackBar {
    tkb := tbar_ctor(parent, 10, 10, _def_tkb_width, _def_tkb_height)
    return tkb
}

@private new_tbar2 :: proc(parent : ^Form, x, y : int) -> TrackBar {
    tkb := tbar_ctor(parent, x, y, _def_tkb_width, _def_tkb_height)
    return tkb
}

@private new_tbar3 :: proc(parent : ^Form, x, y, w, h : int) -> TrackBar {
    tkb := tbar_ctor(parent, x, y, w, h)
    return tkb
}

@private tkb_adjust_styles :: proc(tkb : ^TrackBar) {    
    if tkb.orientation == .Vertical {
        tkb._style |= TBS_VERT
        #partial switch tkb.tic_pos {
            case .Right_Side :
                tkb._style |= TBS_RIGHT
            case .Left_Side :
                tkb._style |= TBS_LEFT
            case .Both_Side :
                tkb._style |= TBS_BOTH 
            case : 
                tkb._style |=  TBS_LEFT
                tkb.tic_pos = .Left_Side  
                 
        }
    } else {        
        #partial switch tkb.tic_pos {
            case .Down_Side :
                tkb._style |= TBS_BOTTOM
            case .Up_Side :
                tkb._style |= TBS_TOP  
            case .Both_Side :
                tkb._style |= TBS_BOTH          
        }
    }


}

@private tkb_set_range_internal :: proc(tkb : ^TrackBar) {
    SendMessage(tkb.handle, TBM_SETRANGEMIN, Wparam(1), Lparam(i32(tkb.min_range)))
    SendMessage(tkb.handle, TBM_SETRANGEMAX, Wparam(1), Lparam(i32(tkb.max_range)))
    SendMessage(tkb.handle, TBM_SETPAGESIZE, Wparam(0), Lparam(tkb.frequency))
   // SendMessage(tkb.handle, TBM_SETLINESIZE, Wparam(0), Lparam(20))
    SendMessage(tkb.handle, TBM_SETTICFREQ, Wparam(i32(tkb.frequency)), Lparam(0))
    SendMessage(tkb.handle, TBM_SETLINESIZE, 0, Lparam(i32(tkb.jump_distance)))


}

@private draw_tic_marks :: proc(t : ^TrackBar, dch : Hdc) {
    t._tic_count = i32((t.max_range - t.min_range) / t.frequency )
    cref := get_color_ref(t.tic_color)
    cpen := CreatePen(PS_SOLID, i32(t.tic_width), cref)    
    select_gdi_object(dch, cpen)    
    defer delete_gdi_object(cpen)
    crc : Rect // to store Channel rect
    SendMessage(t.handle, TBM_GETCHANNELRECT, 0, direct_cast(&crc, Lparam))
    trc := get_rect(t.handle) // We need track bar's rect also
    tics_to_draw := t._tic_count - 2
    if t.orientation == .Horizontal {
        first_x : i32 = crc.left + 5
        last_x : i32 = crc.right - 5
        tlength := last_x - first_x // distance between first & last tics
        distance := tlength / tics_to_draw
        extra_pts := tlength %% tics_to_draw 
        #partial switch t.tic_pos {            
            case .Down_Side :  
                draw_single_tic(dch, first_x, trc.bottom - 5, trc.bottom - 2)
                draw_multi_tics(dch, first_x, tics_to_draw, extra_pts, distance, trc.bottom - 5, trc.bottom - 2)
                draw_single_tic(dch, last_x, trc.bottom - 5, trc.bottom - 2)
            case .Up_Side :                               
                draw_single_tic(dch, first_x, trc.top + 2, trc.top + 5 )
                draw_multi_tics(dch, first_x, tics_to_draw, extra_pts, distance, trc.top + 2, trc.top + 5)
                draw_single_tic(dch, last_x, trc.top + 2, trc.top + 5)
            case .Both_Side :
                draw_single_tic(dch, first_x, trc.bottom - 5, trc.bottom - 2)
                draw_multi_tics(dch, first_x, tics_to_draw, extra_pts, distance, trc.bottom - 5, trc.bottom - 2)
                draw_single_tic(dch, last_x, trc.bottom - 5, trc.bottom - 2)

                draw_single_tic(dch, first_x, trc.top + 2, trc.top + 5 )
                draw_multi_tics(dch, first_x, tics_to_draw, extra_pts, distance, trc.top + 2, trc.top + 5)
                draw_single_tic(dch, last_x, trc.top + 2, trc.top + 5)

        }
    } else {     // drawing tics in vertical style.
        
        first_x : i32 = trc.left + 2        
        first_y := trc.top + 13
        last_y := trc.bottom - 13
        tlength := last_y - first_y // distance between first & last tics
        distance := tlength / tics_to_draw
        extra_pts := tlength %% tics_to_draw 
        
        print("tic to dra - ", tics_to_draw)
        #partial switch t.tic_pos {            
            case .Left_Side :
                draw_single_tic_vertical(dch, first_x, first_y)
                draw_multi_tics_vertical(dch, tics_to_draw, distance, extra_pts, first_x, first_y)
                draw_single_tic_vertical(dch, first_x, last_y)
            case .Right_Side :
                first_x = trc.right - 7                
                draw_single_tic_vertical(dch, first_x, first_y)
                draw_multi_tics_vertical(dch, tics_to_draw, distance, extra_pts, first_x, first_y)
                draw_single_tic_vertical(dch, first_x, last_y)
            case .Both_Side :
                draw_single_tic_vertical(dch, first_x, first_y)
                draw_multi_tics_vertical(dch, tics_to_draw, distance, extra_pts, first_x, first_y)
                draw_single_tic_vertical(dch, first_x, last_y)

                right_x := trc.right - 7                
                draw_single_tic_vertical(dch, right_x, first_y)
                draw_multi_tics_vertical(dch, tics_to_draw, distance, extra_pts, right_x, first_y)
                draw_single_tic_vertical(dch, right_x, last_y)

        }
    }      
}

@private draw_single_tic :: proc(dch : Hdc, p1, p2, p3 : i32) {
    MoveToEx(dch, p1, p2, nil)
    LineTo(dch, p1, p3 )
}

@private draw_single_tic_vertical :: proc(dch : Hdc, x1, y1 : i32) {
    MoveToEx(dch, x1, y1, nil)
    LineTo(dch, x1 + 5, y1 )
}

@private draw_multi_tics :: proc(dch : Hdc, first_p, count, ex_p, dist, last_p1, last_p2 : i32 ) {     
    xp : i32 = first_p + dist
    extras := ex_p 
    for _ in 0 ..< count {          
        if extras > 0 {
            xp += 1
            extras -= 1
        }

        MoveToEx(dch, xp, last_p1, nil)
        LineTo(dch, xp, last_p2 ) 
        xp += dist       
    }     
}

@private draw_multi_tics_vertical :: proc(dch : Hdc, count, dist, ex_p, fx, fy : i32 ) {     
    yp : i32 = fy + dist
    extras := ex_p 
    for _ in 0 ..< count {          
        if extras > 0 {
            yp += 1
            extras -= 1
        }

        MoveToEx(dch, fx, yp, nil)
        LineTo(dch, fx + 5, yp ) 
        yp += dist       
    }     
}



create_trackbar :: proc(tkb : ^TrackBar) {
    _global_ctl_id += 1
    tkb.control_id = _global_ctl_id 
    tkb_adjust_styles(tkb)
    tkb.handle = CreateWindowEx(   tkb._ex_style, 
                                    WcTrackbarClassW, 
                                    to_wstring(tkb.text),
                                    tkb._style, 
                                    i32(tkb.xpos), 
                                    i32(tkb.ypos), 
                                    i32(tkb.width), 
                                    i32(tkb.height),
                                    tkb.parent.handle, 
                                    direct_cast(tkb.control_id, Hmenu), 
                                    app.h_instance, 
                                    nil )
    
    if tkb.handle != nil {
        tkb._is_created = true
        set_subclass(tkb, tkb_wnd_proc) 
        //setfont_internal(tkb)
        // SendMessage(tkb.handle, TBM_SETTHUMBLENGTH, Wparam(i32(100)), 0)
        tkb_set_range_internal(tkb)
       
        
    }
}




@private tkb_wnd_proc :: proc "std" (hw: Hwnd, msg: u32, wp: Wparam, lp: Lparam, sc_id: UintPtr, ref_data: DwordPtr) -> Lresult {      
    context = runtime.default_context()   
    tkb := control_cast(TrackBar, ref_data)
   // display_msg(msg)
    switch msg {
        case WM_DESTROY :
            delete_gdi_object(tkb._bk_brush)
            remove_subclass(tkb)

        case WM_HSCROLL :
            tkb.value = int(SendMessage(hw, TBM_GETPOS, 0, 0))
            if tkb.value_changed != nil {
                ea := new_event_args()
                tkb.value_changed(tkb, &ea)
            }
            

        case CM_CTLLCOLOR :            
            hdc := direct_cast(wp, Hdc)              
            SetTextColor(hdc, get_color_ref(red))
            tkb._bk_brush = CreateSolidBrush(get_color_ref(tkb.back_color))                 
            return direct_cast(tkb._bk_brush, Lresult)  

        case CM_NOTIFY :                  
            nmcd := direct_cast(lp, ^NMCUSTOMDRAW)                       
            if nmcd.hdr.code == NM_CUSTOMDRAW {
                switch nmcd.dwDrawStage {                
                    case CDDS_PREPAINT :
                            return CDRF_NOTIFYITEMDRAW
                     case CDDS_ITEMPREPAINT :
                        switch nmcd.dwItemSpec { // We only altering channel & tics.
                            case TkbTicsCdraw :
                                if tkb.default_tics {
                                    return CDRF_DODEFAULT
                                } else {                                    
                                    draw_tic_marks(tkb, nmcd.hdc)
                                    return CDRF_SKIPDEFAULT
                                }                            
                                
                            case TkbChannelCdraw :                                
                                ch_brush := create_hbrush(tkb.channel_color) 
                                FillRect(nmcd.hdc, &nmcd.rc, ch_brush) 
                                return CDRF_SKIPDEFAULT                            
                        }
                }
            } 

         case WM_LBUTTONDOWN:
           // tkb._draw_focus_rct = true
            tkb._mdown_happened = true
            if tkb.left_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.left_mouse_down(tkb, &mea)
                return 0
            }
            

        case WM_RBUTTONDOWN :
            tkb._mrdown_happened = true
            if tkb.right_mouse_down != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.right_mouse_down(tkb, &mea)
            }
            
        case WM_LBUTTONUP :
            if tkb.left_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.left_mouse_up(tkb, &mea)
            }
            if tkb._mdown_happened do SendMessage(tkb.handle, CM_LMOUSECLICK, 0, 0)

        case CM_LMOUSECLICK :
            tkb._mdown_happened = false
            if tkb.mouse_click != nil {
                ea := new_event_args()
                tkb.mouse_click(tkb, &ea)
                return 0
            }
        
        case WM_LBUTTONDBLCLK :
            if tkb.double_click != nil {
                ea := new_event_args()
                tkb.double_click(tkb, &ea)
                return 0
            }

        case WM_RBUTTONUP :
            if tkb.right_mouse_up != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.right_mouse_up(tkb, &mea)
            }
            if tkb._mrdown_happened do SendMessage(tkb.handle, CM_LMOUSECLICK, 0, 0) 
            
        case CM_RMOUSECLICK :
            tkb._mrdown_happened = false
            if tkb.right_click != nil {
                ea := new_event_args()
                tkb.right_click(tkb, &ea)
                return 0
            }

        case WM_MOUSEHWHEEL:
            if tkb.mouse_scroll != nil {
                mea := new_mouse_event_args(msg, wp, lp)
                tkb.mouse_scroll(tkb, &mea)
            }	
        case WM_MOUSEMOVE : // Mouse Enter & Mouse Move is happening here.
            if tkb._is_mouse_entered {
                if tkb.mouse_move != nil {
                    mea := new_mouse_event_args(msg, wp, lp)
                    tkb.mouse_move(tkb, &mea)
                }
            }
            else {
                tkb._is_mouse_entered = true
                if tkb.mouse_enter != nil  {
                    ea := new_event_args()
                    tkb.mouse_enter(tkb, &ea)
                }
            }
        
        case WM_MOUSELEAVE :
            tkb._is_mouse_entered = false
            if tkb.mouse_leave != nil {
                ea := new_event_args()
                tkb.mouse_leave(tkb, &ea)
            }
    
    }       
    return DefSubclassProc(hw, msg, wp, lp)
}

