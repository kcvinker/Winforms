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
    orientation : enum {horizontal, vertical},
    direction : enum {down_side, up_side, left_side, right_side, both_side},
    max_position : enum {right, left},
    no_ticks : bool,
    enable_sel_range : bool,
    fixed_length : bool,
    thumb_color,
    channel_color,
    tic_color : uint,
    tic_width : int,
    jump_distance : int,
    min_range, max_range : int,
    frequency : int,
    default_tics : bool,
    value : int,

    _bk_brush : Hbrush,
    _lb_down : bool,
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
    tkb.kind = .track_bar
    tkb.parent = f
    tkb.font = f.font
    tkb.xpos = x
    tkb.ypos = y
    tkb.width = w
    tkb.height = h
    tkb.back_color = f.back_color
    tkb.thumb_color = 0x00DF00
    tkb.channel_color = light_steel_blue
    tkb.tic_color = 0x000000
    tkb.tic_width = 1
    tkb.min_range = 0
    tkb.max_range = 100
    tkb.frequency = 10
    tkb.jump_distance = 1
    tkb._style = WS_CHILD | WS_VISIBLE | TBS_AUTOTICKS | TBS_BOTTOM
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
    // TODO
    if tkb.orientation == .vertical {
        tkb._style |= TBS_VERT
        if tkb.direction == .left_side {
            tkb._style |= TBS_LEFT        
        } else do tkb._style |= TBS_RIGHT
    }

}

@private tkb_set_range_internal :: proc(tkb : ^TrackBar) {
    SendMessage(tkb.handle, TBM_SETRANGEMIN, Wparam(1), Lparam(i32(tkb.min_range)))
    SendMessage(tkb.handle, TBM_SETRANGEMAX, Wparam(1), Lparam(i32(tkb.max_range)))
   // SendMessage(tkb.handle, TBM_SETPAGESIZE, Wparam(0), Lparam(20))
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
    first_x := crc.left + 5
    last_x := crc.right - 5
    tics_to_draw := t._tic_count - 2
    tlength := last_x - first_x // distance between first & last tics
    distance := tlength / tics_to_draw
    extra_pts := tlength %% tics_to_draw

    // Draw first tic. This tic is longer than other tics
    MoveToEx(dch, first_x, trc.bottom - 7, nil)
    LineTo(dch, first_x, trc.bottom - 2 )

    start_point := first_x + distance    

    xp : i32 = start_point
    for _ in 0 ..< tics_to_draw {          
        if extra_pts > 0 {
            xp += 1
            extra_pts -= 1
        }
        MoveToEx(dch, xp, trc.bottom - 5, nil)
        LineTo(dch, xp, trc.bottom - 2 ) 
        xp += distance       
    }    

    // Draw last tic. This tic is longer than other tics
    MoveToEx(dch, last_x, trc.bottom - 7, nil)
    LineTo(dch, last_x, trc.bottom - 2 )    
}



create_trackbar :: proc(tkb : ^TrackBar) {
    _global_ctl_id += 1
    tkb.control_id = _global_ctl_id 
    //tkb_adjust_styles(tkb)
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
        
        // ret := SendMessage(tkb.handle, TBM_GETTIC, 0, 0)
        print("track bar hwnd - ", tkb.handle)
        
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

