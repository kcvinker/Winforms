// Created on : 19-May-22 08:03:33 AM
// This module handles the image list section

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
	size_x, size_y : int,
	color_depth : int,
    color_option : ColorOptions,
    initial_size : int,
    grow_size : int,
    use_mask, use_mirrored, use_strip : bool,
    image_type : ImageTypes,
    handle : HimageList,	
}

ColorOptions :: enum {
    Default_Color, 
    Color_4 = 4, 
    Color_8 = 8, 
    Color_16 = 
    16, 
    Color_24 = 24 , 
    Color32 = 32, 
    Color_DDB = 0x000000FE,
}

ImageTypes :: enum {Normal_Image, Small_Image, State_Image}


// Create an ImageList struct with default initialization.
new_image_list :: proc() -> ImageList {
    img : ImageList
    img.size_x = 16
    img.size_y = 16    
    img.initial_size = 4
    img.grow_size = 4
    img.color_option = .Default_Color  
    img.image_type = .Normal_Image  
    img.use_mask = true    
    return img
}


// Create an ImageList handle. 
image_list_create_handle :: proc(img : ^ImageList) {
    uFlag : u32 = ILC_MASK
    if !img.use_mask do uFlag ~= ILC_MASK
    if img.use_mirrored do uFlag |= ILC_MIRROR
    if img.use_strip do uFlag |= ILC_PERITEMMIRROR
    uFlag |= cast(u32) img.color_option
    img.handle = ImageList_Create(img.size_x,
                                    img.size_y,
                                    uFlag,
                                    img.initial_size,
                                    img.grow_size)                                    
    
}

image_list_add_icon :: proc(img : ImageList, fPath : string, indx : int, smIcon : bool = true) -> i32 {
	hIco : Hicon
    defer DestroyIcon(hIco)
	uRet : u32
	if smIcon {
		uRet = ExtractIconEx(to_wstring(fPath), i32(indx), nil, &hIco, 1)
	} else do uRet = ExtractIconEx(to_wstring(fPath), i32(indx), &hIco, nil, 1)
	if uRet == 0 do return -1
	iRet := ImageList_ReplaceIcon(img.handle, -1, hIco)	
	return iRet
}

// image_list_destroy_handle :: proc(hImg : HimageList) {
//     ImageList_Destroy(hImg)
// }

// image_list_add_image :: proc(handle : HimageList, hbImg : Hbitmap, hbMask : Hbitmap = nil) {
//     ImageList_Add(handle, hbImg, hbMask)
// }

