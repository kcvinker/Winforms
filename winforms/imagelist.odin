// Created on : 19-May-22 08:03:33 AM
// This module handles the image list section  --NOTe - Add gdi plus function for reading jpeg file

package winforms

ILC_MASK :: 0x00000001
ILC_COLOR :: 0x00000000
ILC_COLORDDB :: 0x000000FE
ILC_COLOR4 :: 0x00000004
ILC_COLOR8 :: 0x00000008
ILC_COLOR16 :: 0x00000010
ILC_COLOR24 :: 0x00000018
ILC_COLOR32 :: 0x00000020
ILC_PALETTE :: 0x00000800
ILC_MIRROR :: 0x00002000
ILC_PERITEMMIRROR :: 0x00008000

ILCF_MOVE :: 0x0
ILCF_SWAP :: 0x1

ILD_NORMAL :: 0x00000000
ILD_TRANSPARENT :: 0x00000001
ILD_BLEND25 :: 0x00000002
ILD_BLEND50 :: 0x00000004
ILD_MASK :: 0x00000010
ILD_IMAGE :: 0x00000020
ILD_ROP :: 0x00000040
ILD_OVERLAYMASK :: 0x00000F00

ILS_NORMAL :: 0x00000000
ILS_GLOW :: 0x00000001
ILS_SHADOW :: 0x00000002
ILS_SATURATE :: 0x00000004
ILS_ALPHA :: 0x00000008



ImageList :: struct {
	sizeX, sizeY : int,
	colorDepth : int,
    colorOption : ColorOptions,
    initialSize : int,
    growSize : int,
    useMask, useMirrored, useStrip : bool,
    imageType : ImageTypes,
    handle : HIMAGELIST,
}

ColorOptions :: enum {
    Default_Color,
    Color_4 = 4,
    Color_8 = 8,
    Color_16 = 16,
    Color_24 = 24 ,
    Color32 = 32,
    Color_DDB = 0x000000FE,
}

ImageTypes :: enum {Normal_Image, Small_Image, State_Image}


// Create an ImageList struct with default initialization.
new_image_list :: proc() -> ImageList {
    img : ImageList
    img.sizeX = 16
    img.sizeY = 16
    img.initialSize = 4
    img.growSize = 4
    img.colorOption = .Default_Color
    img.imageType = .Normal_Image
    img.useMask = true
    return img
}


// Create an ImageList handle.
image_list_create_handle :: proc(img : ^ImageList) {
    uFlag : u32 = ILC_MASK
    if !img.useMask do uFlag ~= ILC_MASK
    if img.useMirrored do uFlag |= ILC_MIRROR
    if img.useStrip do uFlag |= ILC_PERITEMMIRROR
    uFlag |= cast(u32) img.colorOption
    img.handle = ImageList_Create(img.sizeX,
                                    img.sizeY,
                                    uFlag,
                                    img.initialSize,
                                    img.growSize)

}

image_list_add_icon :: proc(img : ImageList, fPath : string, indx : int, smIcon : bool = true) -> i32 {
	hIco : HICON
    defer DestroyIcon(hIco)
    //defer // free_all(context.temp_allocator)
	uRet : u32
	if smIcon {
		uRet = ExtractIconEx(to_wstring(fPath), i32(indx), nil, &hIco, 1)
	} else do uRet = ExtractIconEx(to_wstring(fPath), i32(indx), &hIco, nil, 1)
	if uRet == 0 do return -1
	iRet := ImageList_ReplaceIcon(img.handle, -1, hIco)
	return iRet
}

// image_list_destroy_handle :: proc(hImg : HIMAGELIST) {
//     ImageList_Destroy(hImg)
// }

// image_list_add_image :: proc(handle : HIMAGELIST, hbImg : HBITMAP, hbMask : HBITMAP = nil) {
//     ImageList_Add(handle, hbImg, hbMask)
// }

