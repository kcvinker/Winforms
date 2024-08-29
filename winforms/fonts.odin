package winforms
import "core:mem"
import "base:runtime"

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
}

new_font_1 :: proc() -> Font
{
	// context = ctx
	f : Font
	// print("alloc error in font ", ae, " user index : ", ctx.user_index)
	f.name = _def_font_name
	f.size = _def_font_size
	f.weight = FontWeight.Normal
	f.underline = false
	f.italics = false
	f._defFontChanged = false
	return f
}

new_font_2 :: proc(fn : string , fs : int, fw : FontWeight = .Normal, 
							fi : bool = false, fu : bool = false) -> Font
{
	f : Font
	f.name = fn
	f.size = fs
	f.weight = fw
	f.underline = fu
	f.italics = fi
	f._defFontChanged = true
	return f
}

new_font :: proc {new_font_1, new_font_2} // Overloaded proc

CreateFont_handle :: proc(this : ^Font) 
{
	fsiz:= i32(app.scaleFactor * f64(this.size))
	iHeight : i32 = -MulDiv(fsiz , app.sysDPI, 72)
	wfname : []u16 = utf8_to_utf16(this.name)

	lf : LOGFONT
	lf.lfItalic = cast(byte)this.italics
	lf.lfUnderline = cast(byte)this.underline
	copy(lf.lfFaceName[:], wfname) 
	lf.lfHeight = iHeight
	lf.lfWeight = cast(LONG)this.weight
	lf.lfCharSet = DEFAULT_CHARSET
	lf.lfOutPrecision = OUT_DEFAULT_PRECIS
	lf.lfClipPrecision = CLIP_DEFAULT_PRECIS
	lf.lfQuality = DEFAULT_QUALITY
	lf.lfPitchAndFamily = DEFAULT_PITCH
	this.handle = CreateFontIndirect(&lf)
	// for w in wfname {
	// 	ptf("f digit : %d", w)
	// }

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

FontWeight :: enum 
{
	Light = 300,
    Normal = 400,
    Medium = 500,
    Semi_Bold = 600,
    Bold = 700,
    Extra_Bold = 800,
    Ultra_Bold = 900,
}
