// Created on: 17-Mar-2026 02:49 PM
// Purpose: PictureBox control for displaying images in WinForms applications.

package winforms

import "core:fmt"
import "base:runtime"
import "core:time"
import api "core:sys/windows"

_pbxCount : int
_pbxclass := [?]WCHAR {'W','i','n','f','o', 'r', 'm', 's', '_','P','i','c','t','u','r','e','B','o','x', 0}
_isPbxRegistered : bool



PictureBox :: struct {
    using control : Control,
    image : ^Image,
    sizeMode : PictureSizeMode,
    
    _rect : RECT,
    _size : SIZE,
    _imgPath: string,

}

new_picturebox :: proc(p: ^Form, x, y, w, h: int, 
                        imgPath: string, picSizeMode: PictureSizeMode) -> ^PictureBox 
{
    this := pbox_ctor(p, x, y, w, h)
    this.sizeMode = picSizeMode
    this._imgPath = imgPath
    return this
}

// Either pass an image path as string or an Image ptr.
pbox_set_image :: proc{pbox_set_image_string, pbox_set_image_imgptr}

pbox_set_sizemode :: proc(this: ^PictureBox, smode: PictureSizeMode)
{
    if this.sizeMode == smode do return
    this.sizeMode = smode
    if (smode == .Auto_Size && this.image != nil) {
        pbox_adjust_size_to_image(this)
    } else {
        pbox_update_client_rect(this)
    }   
}

// Set picture box size, You can keep the old value by passing a zero.
pbox_set_size :: proc(this: ^PictureBox, w, h: int)
{
    if w > 0 do this.width = w 
    if h > 0 do this.height = h 
    if this._isCreated do pbox_update_client_rect(this)
}

@private pbox_set_image_string :: proc(this: ^PictureBox, imgPath: string) 
{
    if this.image != nil do image_destroy(this.image)
    this._imgPath = imgPath
    if len(imgPath) > 0 do this.image = new_image(imgPath)
    if this.sizeMode == .Auto_Size {        
        this.width = cast(int)this.image.width
        this.height = cast(int)this.image.height        
    }
    pbox_update_client_rect(this)
}

@private pbox_set_image_imgptr :: proc(this: ^PictureBox, img: ^Image)
{
    if this.image != nil do image_destroy(this.image)
    this.image = img 
    this._imgPath = img.imgPath
    if this.sizeMode == .Auto_Size {        
        this.width = cast(int)this.image.width
        this.height = cast(int)this.image.height        
    }
    pbox_update_client_rect(this)
}

pbox_clear_image :: proc(this: ^PictureBox)
{
    if this.image != nil {
        image_destroy(this.image)
        this._imgPath = ""
        this.width = 0
        this.height = 0
    }

}





@private register_picturebox_class :: proc() {
    wc : WNDCLASSEXW
    wc.cbSize = size_of(wc)
    wc.style = CS_HREDRAW | CS_VREDRAW
    wc.lpfnWndProc = pbx_window_proc
    wc.cbClsExtra = 0
    wc.cbWndExtra = 0
    wc.hInstance = GetModuleHandle(nil)
    wc.hIcon = nil
    wc.hCursor = LoadCursor(nil, IDC_ARROW)
    wc.hbrBackground = nil
    wc.lpszMenuName = nil
    wc.lpszClassName = &_pbxclass[0]
    wc.hIconSm = nil

    atom := RegisterClassEx(&wc)
    if atom == 0 {
        ptf("Failed to register PictureBox class. Error: %d", GetLastError())
        return
    }
    _isPbxRegistered = true
}

@private pbox_ctor:: proc(p: ^Form, x, y, w, h: int) -> ^PictureBox 
{
    if !_isPbxRegistered do register_picturebox_class()
   
    this:= new(PictureBox)
    this.kind = .Picture_Box
    this.parent = p
    this.width = w
    this.height = h
    this.xpos = x
    this.ypos = y
    this.backColor = app.clrWhite
    this.foreColor = app.clrBlack
    this._style = WS_VISIBLE | WS_CHILD | WS_TABSTOP
    this._exStyle = 0
    this._clsName = cast([^]WCHAR)&_pbxclass[0]
	this._fp_beforeCreation = cast(CreateDelegate) pbox_before_creation
	this._fp_afterCreation = cast(CreateDelegate) pbox_after_creation
    append(&p._controls, this)
    return this
}

@private pbox_before_creation :: proc(this: ^PictureBox) 
{
    this._size = SIZE{cast(i32)this.width, cast(i32)this.height}
    if len(this._imgPath) > 0 do pbox_set_image(this, this._imgPath)
    
}

@private pbox_after_creation :: proc(this: ^PictureBox) 
{
    SetWindowLongPtr(this.handle, GWLP_USERDATA, cast(LONG_PTR) cast(UINT_PTR) this)
    GetClientRect(this.handle, &this._rect)
}

@private pbox_update_client_rect :: proc(this: ^PictureBox) 
{
    pbox_compute_dest_rect(this)
    if this.handle != nil do InvalidateRect(this.handle, nil, true)
}

@private pbox_compute_dest_rect :: proc(this: ^PictureBox)
{
    // Start here
    cw : i32 = this._rect.right - this._rect.left
    ch : i32 = this._rect.bottom - this._rect.top;
    if this.image == nil do this._rect = RECT{0, 0, 0, 0}
    imgW : i32 = cast(i32)this.image.width
    imgH : i32 = cast(i32)this.image.height
    if (imgW == 0 || imgH == 0) do this._rect = RECT{0, 0, 0, 0}
    switch this.sizeMode {
        case .Normal:
            this._rect = RECT{0, 0, imgW, imgH}

        case .Center: 
            x : i32 = (cw - imgW) / 2
            y : i32 = (ch - imgH) / 2
            this._rect = RECT{x, y, x + imgW, y + imgH}
            
        case .Stretch:
            // ptf("Stretch mode: control size =", cw, "x", ch);
            this._rect = RECT{0, 0, cw, ch}

        case .Zoom: 
            ratioImg : f32 = cast(f32)imgW / cast(f32)imgH
            ratioCtl : f32 = cast(f32)cw / cast(f32)ch
            w, h: i32
            if ratioImg > ratioCtl {
                w = cw
                h = cast(i32)(cast(f32)cw / ratioImg)
            } else {
                h = ch
                w = cast(i32)(cast(f32)ch * ratioImg)
            }

            x : i32 = (cw - w) / 2
            y : i32 = (ch - h) / 2
            this._rect = RECT{x, y, x + w, y + h}

        case .Auto_Size:
            // AutoSize already adjusted the control, so image fits exactly
            this._rect = RECT{0, 0, imgW, imgH}

        case:
            this._rect = RECT{0, 0, 0, 0}
    }

}

@private pbox_adjust_size_to_image :: proc(this: ^PictureBox) 
{
    if this.image != nil {
        this.width = cast(int)this.image.width
        this.height = cast(int)this.image.height
    }
}

@private pbox_finalize :: proc(this: ^PictureBox) {
    if this.image != nil do image_destroy(this.image)
    free(this, context.allocator)
}


@private
pbx_window_proc :: proc "stdcall" (hw : HWND, msg : u32, wp : WPARAM, lp : LPARAM ) -> LRESULT
{
	context = global_context
	switch msg {
        case WM_NCDESTROY:
            pbx := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^PictureBox)
            pbox_finalize(pbx)

        case WM_PAINT:
            ps: PAINTSTRUCT
            pbx := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^PictureBox)
            hdc: HDC = BeginPaint(hw, &ps) 
            defer EndPaint(hw, &ps)             
            if pbx.image != nil { 
                image_draw(pbx.image, hdc, pbx._rect.left, pbx._rect.top, 
                                pbx._rect.right - pbx._rect.left, 
                                pbx._rect.bottom - pbx._rect.top)
            } else {
                // If no image, fill with background color
                // print("No image to draw, filling with background color");
                hbr: HBRUSH = CreateSolidBrush(get_color_ref(pbx.backColor))
                defer delete_gdi_object(hbr)
                api.FillRect(hdc, &ps.rcPaint, hbr);
                
            }
            return 0

        case WM_ERASEBKGND:
            // We handle everything in WM_PAINT, so suppress background erase
            return 1;

        case WM_SIZE:        
            // ptf("PictureBox resized, new size: %d x %d", LOWORD(lParam), HIWORD(lParam));
            pbx := dir_cast(GetWindowLongPtr(hw, GWLP_USERDATA), ^PictureBox)
            if (pbx != nil) {
                if pbx.sizeMode != .Auto_Size do InvalidateRect(hw, nil, true)
            }

        case :
            return DefWindowProc(hw, msg, wp, lp)
    }
    return DefWindowProc(hw, msg, wp, lp)
}
