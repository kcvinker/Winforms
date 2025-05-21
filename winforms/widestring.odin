// Created on 11-May-2025 20:25

package winforms


WideString :: struct {
	ptr : [^]WCHAR,
	buffLen : i32,
	strLen : i32,
    txt : string,
}

new_widestring :: proc(text : string) -> ^WideString
{
	// print(text)
	this := new(WideString)
    // ptf("ws ptr %d, text - %s", int(uintptr(this)), text)
    this.txt = text
	this.strLen = i32(len(text))
	barr := transmute([]byte)text	
    cstr := raw_data(barr)
	wn := MultiByteToWideChar(CP_UTF8, 0, cstr, this.strLen, nil, 0)
    if wn == 0 do return nil
	this.ptr = make([^]WCHAR, (wn + 1), context.allocator)	
    wn2 := MultiByteToWideChar(CP_UTF8, 0, cstr, this.strLen, this.ptr, wn)    
    this.ptr[wn] = 0
    for wn >= 1 && this.ptr[wn - 1] == 0 { wn -= 1 }	
	this.buffLen = wn	
    // ptf("new wstr %s, wn %d, wn2 %d", text, wn, wn2)
	return this
} //No Entry Point,  Format Options

widestring_clone :: proc(src: ^WideString, dest: ^^WideString, id: int = 0) 
{
    if src == nil || src.ptr == nil do return
	if dest^ == nil {
        dest^ = new(WideString)
    //    if id > 0 {
	// 	ptf("dest ptr %d, user_index - %d", int(uintptr(dest^)), context.user_index)
	//    }
    }

    srclen := src.buffLen
	if dest^.ptr != nil && dest^.buffLen < srclen {
		// dest memory is lower than src memory
		free(dest^.ptr)
		dest^.ptr = nil
		dest^.buffLen = 0
	}

	if dest^.ptr == nil do dest^.ptr = make([^]WCHAR, srclen + 1, context.allocator) // +1 for null terminator
    for i in 0..<srclen {
        dest^.ptr[i] = src.ptr[i]
    }
    dest^.ptr[srclen] = 0 // ensure null-termination
    dest^.buffLen  = src.buffLen
    dest^.strLen = src.strLen   
    // ptf("cloned %d", dest^.buffLen) 
}

widestring_update :: proc(this: ^^WideString, txt: string)
{
    // print(" did")
	newlen := i32(len(txt))
	barr := transmute([]byte)txt	
    cstr := raw_data(barr)
	wn := MultiByteToWideChar(CP_UTF8, 0, cstr, newlen, nil, 0)
	if wn == 0 do return
	if wn >= this^.buffLen {
		free(this^.ptr)
		this^.ptr = nil
		this^.ptr = make([^]WCHAR, (wn + 1), context.allocator)    
	} 
	wn2 := MultiByteToWideChar(CP_UTF8, 0, cstr, newlen, this^.ptr, wn)
	this^.ptr[wn] = 0
    for wn >= 1 && this^.ptr[wn - 1] == 0 { wn -= 1 }	
	this^.buffLen = wn	
    this^.strLen = newlen
}

widestring_fill_buffer :: proc(buffer: []WCHAR, txt: string) {
	newlen := i32(len(txt))
	barr := transmute([]byte)txt	
    cstr := raw_data(barr)
	wn := MultiByteToWideChar(CP_UTF8, 0, cstr, newlen, nil, 0)
	if wn == 0 do return
	wn2 := MultiByteToWideChar(CP_UTF8, 0, cstr, newlen, &buffer[0], wn)
	buffer[wn] = 0
}

// widestring_has_space :: proc(this: ^WideString, txt: string) -> b64
// {
// 	newlen := i32(len(txt))
// 	barr := transmute([]byte)txt	
//     cstr := raw_data(barr)
// 	wn := MultiByteToWideChar(CP_UTF8, 0, cstr, newlen, nil, 0)
// 	return this.buffLen > wn
// }


widestring_destroy :: proc(this: ^WideString, id: int = 0)
{
    // if id > 0 do ptf("wstr dtor special - %d", int(uintptr(this)))
	free(this.ptr)
	this.ptr = nil
	free(this)
	
}