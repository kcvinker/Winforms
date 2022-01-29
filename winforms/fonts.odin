package winforms
// import "core:fmt"

_def_font_name :: "Calibri"
_def_font_size :: 12

Font :: struct
{
	name : string,
	size : int,
	bold : bool,
	underline : bool,
	italics : bool,
	handle : Hfont,
	_weight : int,
	_def_font_changed : bool,


}

new_font_1 :: proc() -> Font 
{
	f : Font
	f.name = _def_font_name
	f.size = _def_font_size
	f._weight = 400
	f.bold = false
	f.underline = false
	f.italics = false
	f._def_font_changed = false
	return f
}

new_font_2 :: proc(fn : string , fs : int, fb: bool = false, fw : int = 400, fi : bool = false, fu : bool = false) -> Font 
{
	f : Font
	f.name = fn
	f.size = fs
	f._weight = fw
	f.bold = fb
	f.underline = fu
	f.italics = fi
	f._def_font_changed = true
	return f
}

new_font :: proc {new_font_1, new_font_2} // Overloaded proc



create_font_handle :: proc(fnt : ^Font, hw : Hwnd = nil)
{	
	if fnt.bold {fnt._weight = 600}
	dc_hwnd : Hdc = get_dc(hw)
	font_height : i32 = mul_div(i32(fnt.size), get_device_caps(dc_hwnd, LOGPIXELSY), 72)
	release_dc(hw, dc_hwnd)
	b_value := bool(false)
	fnt.handle = create_font(font_height, 0, 0, 0, i32(fnt._weight), Dword(fnt.italics),
								Dword(fnt.underline), 
								Dword(b_value), 
								Dword(1),
								OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
								DEFAULT_QUALITY, DEFAULT_PITCH, to_wstring(fnt.name))
	
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


DEFAULT_QUALITY :: 0
DRAFT_QUALITY :: 1
PROOF_QUALITY :: 2
NONANTIALIASED_QUALITY :: 3
ANTIALIASED_QUALITY :: 4

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