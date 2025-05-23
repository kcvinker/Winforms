package winforms
import "core:mem"
import "base:runtime"
import api "core:sys/windows"

_def_font_name :: "DejaVu Sans Condensed"
_def_font_size :: 12

Font :: struct
{
	name : string,
	size : int,
	weight : FontWeight,
	underline : bool,
	italics : bool,
	handle : HFONT,
	_defFontChanged : bool,
	// _wtext: ^WideString,
}

new_font_1 :: proc() -> Font
{
	return new_font_2(def_font_name, def_font_size)
}

new_font_2 :: proc(fname : string , fs : int, fw : FontWeight = .Normal, 
							fi : bool = false, fu : bool = false) -> Font
{
	this : Font
	this.name = fname
	this.size = fs
	this.weight = fw
	this.underline = fu
	this.italics = fi
	this._defFontChanged = true
	// this._wtext = new_widestring(fname)
	return this
}

new_font :: proc {new_font_1, new_font_2} // Overloaded proc

@private font_fill_logfont :: proc(this : ^Font, plf: ^LOGFONT) 
{
	fsiz:= i32(app.scaleFactor * f64(this.size))
	iHeight : i32 = -MulDiv(fsiz , app.sysDPI, 72)		
	widestring_fill_buffer(plf.lfFaceName[:], this.name)
	plf.lfItalic = cast(byte)this.italics
	plf.lfUnderline = cast(byte)this.underline
	plf.lfHeight = iHeight
	plf.lfWeight = cast(LONG)this.weight
	plf.lfCharSet = DEFAULT_CHARSET
	plf.lfOutPrecision = OUT_DEFAULT_PRECIS
	plf.lfClipPrecision = CLIP_DEFAULT_PRECIS
	plf.lfQuality = DEFAULT_QUALITY
	plf.lfPitchAndFamily = DEFAULT_PITCH
}

font_create_handle :: proc(this: ^Font, usePrimary: b32 = false) {
	lf : LOGFONT
	plf : ^LOGFONT = &app.lfont if usePrimary else &lf
	if !usePrimary {
		font_fill_logfont(this, plf)
	} else {
		if this.handle != nil do delete_gdi_object(this.handle)
	}	
	this.handle = CreateFontIndirect(plf)
}

@private font_clone_handle :: proc(this: ^Font, srcHandle: HFONT) {
	if srcHandle != nil {
		lf : LOGFONT
        x := api.GetObjectW(HANDLE(srcHandle), size_of(lf), cast(LPVOID)&lf)
        if x > 0 {
			this.handle = CreateFontIndirect(&lf)
		} else {
			ptf("Proc: font_clone_handle, Error : %d", GetLastError())
		}
	}
}

font_clone_parent_handle :: proc(this: ^Font, pHandle: HFONT) {
	if pHandle == nil {
        this.handle = CreateFontIndirect(&app.lfont)
	} else {
        font_clone_handle(this, pHandle)
	}
}

font_clone :: proc(src: ^Font, dst: ^Font, id : int = 0)
{
	dst.name = src.name
	dst.size = src.size
	dst.weight = src.weight
	dst.underline = src.underline
	dst.italics = src.italics
	dst._defFontChanged = src._defFontChanged	
	font_clone_handle(dst, src.handle)
}	

font_change_font :: proc(this: ^Font, fname : string , fs : int, fw : FontWeight = .Normal)
{
	this.name = fname
	this.size = fs
	this.weight = fw
	this.underline = false
	this.italics = false
	font_create_handle(this)
}



font_destroy :: #force_inline proc(this: ^Font,id: int = 0)
{
	if this.handle != nil {
		// ptf("deleting font %s", this.name)
		delete_gdi_object(this.handle)
		this.handle = nil
	}
}


OUT_DEFAULT_PRECIS :: 0
OUT_STRING_PRECIS :: 1
OUT_CHARACTER_PRECIS :: 2
OUT_STROKE_PRECIS :: 3
OUT_TT_PRECIS :: 4
OUT_DEVICE_PRECIS :: 5
OUT_RASTER_PRECIS :: 6
OUT_TT_ONLY_PRECIS :: 7
OUT_OUTLINE_PRECIS :: 8
OUT_SCREEN_OUTLINE_PRECIS :: 9
OUT_PS_ONLY_PRECIS :: 10

CLIP_DEFAULT_PRECIS   :: 0
CLIP_CHARACTER_PRECIS :: 1
CLIP_STROKE_PRECIS    :: 2
CLIP_MASK             :: 15
CLIP_LH_ANGLES        :: 16
CLIP_TT_ALWAYS        :: 32
CLIP_DFA_DISABLE      :: 64
CLIP_EMBEDDED         :: 128

DEFAULT_CHARSET :: 1

DEFAULT_QUALITY :: 0
DRAFT_QUALITY :: 1
PROOF_QUALITY :: 2
NONANTIALIASED_QUALITY :: 3
ANTIALIASED_QUALITY :: 4
CLEARTYPE_QUALITY :: 5
CLEARTYPE_NATURAL_QUALITY :: 6

DEFAULT_PITCH  :: 0
FIXED_PITCH    :: 1
VARIABLE_PITCH :: 2
MONO_FONT      :: 8
FF_DONTCARE    :: 0
FF_ROMAN       :: 16
FF_SWISS       :: 32
FF_SCRIPT      :: 64
FF_MODERN      :: 48
FF_DECORATIVE  :: 80

LOGPIXELSY :: 90


