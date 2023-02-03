
package winforms
import "core:fmt"

Color :: struct {
   red: uint,
   green: uint,
   blue : uint,
   value: uint,
   ref: ColorRef,

}

clip :: proc(value: uint) -> uint { return clamp(value, 0, 255) }

@private color_from_uint :: proc(clr : uint) -> Color {
   return _get_color(clr)
}
@private color_from_rgb :: proc(r, g, b: uint) -> Color {
   rc : Color
   rc.red = r
   rc.green = g
   rc.blue = b
   rc.value = (rc.red << 16) | (rc.green << 8) | rc.blue
   rc.ref = ColorRef((rc.blue << 16) | (rc.green << 8) | rc.red)
   return rc
}



new_color :: proc{color_from_uint, color_from_rgb}


_get_color :: proc(clr : uint) -> Color {
   rc : Color
   rc.red = clr >> 16
   rc.green = (clr & 0x00ff00) >> 8
   rc.blue = clr & 0x0000ff
   rc.value = clr
   rc.ref = ColorRef((rc.blue << 16) | (rc.green << 8) | rc.red)
   return rc
}


@private get_color_ref1 :: proc(clr : uint) -> ColorRef {
	rc := _get_color(clr)
	rst := (rc.blue << 16) | (rc.green << 8) | rc.red
	return cast(ColorRef) rst
}
@private get_color_ref2 :: proc(r, g, b : uint) -> ColorRef {
	return ColorRef((b << 16) | (g << 8) | r)
	//return cast(ColorRef) rst
}

@private get_color_ref3 :: proc(rc : Color) -> ColorRef {
	return ColorRef((rc.blue << 16) | (rc.green << 8) | rc.red)
	//return cast(ColorRef) rst
}

get_color_ref :: proc{get_color_ref1, get_color_ref2, get_color_ref3}
get_solid_brush :: proc(clr : uint) -> Hbrush { return CreateSolidBrush(get_color_ref(clr))}
//---------------------------------------------------------

change_color_uint :: proc(clr : uint, adj : f64) -> Color {
   rc := new_color(clr)
   rc.red = clip(cast(uint) (f64(rc.red) * adj))
   rc.green = clip(cast(uint) (f64( rc.green) * adj))
   rc.blue = clip(cast(uint) (f64( rc.blue) * adj))
   return rc
}

change_color :: proc(clr : uint, adj : f64) -> ColorRef {
   rc := change_color_uint(clr, adj)
   crf := get_color_ref(rc)
   return crf
}

change_color_rgb :: proc(rc : Color, adj : f64) -> Color {
   nrc : Color
   nrc.red = clip(cast(uint) (f64(rc.red) * adj))
   nrc.green = clip(cast(uint) (f64( rc.green) * adj))
   nrc.blue = clip(cast(uint) (f64( rc.blue) * adj))
   return nrc
}

change_color_to_ref1 :: proc(c : uint, adj : f64) -> ColorRef {
   rc : Color = new_color(c)
   r : uint = clip(cast(uint) (f64(rc.red) * adj))
   g : uint = clip(cast(uint) (f64( rc.green) * adj))
   b : uint = clip(cast(uint) (f64( rc.blue) * adj))
   return ColorRef((b << 16) | (g << 8) | r)
}

change_color_to_ref2 :: proc(rc : Color, adj : f64) -> ColorRef {
   r : uint = clip(cast(uint) (f64(rc.red) * adj))
   g : uint = clip(cast(uint) (f64( rc.green) * adj))
   b : uint = clip(cast(uint) (f64( rc.blue) * adj))
   return ColorRef((b << 16) | (g << 8) | r)
}

change_color_get_ref :: proc{change_color_to_ref1, change_color_to_ref2}

// change_gradient_color :: proc(gc : GradientColors, adj : f64) -> GradientColors {
//    ngc : GradientColors = gc
//    change_color_rgb(&ngc.color1, adj)
//    change_color_rgb(&ngc.color2, adj)
//    return ngc
// }

is_dark_color :: proc(c: Color) -> b64 {
   x: f64 = (cast(f64)c.red * 0.2126) + (cast(f64)c.green * 0.7152) + (cast(f64)c.blue * 0.0722)
	return x < 40
}




print_rgb:: proc(rc : Color)
{
   fmt.println("red - ", rc.red)
   fmt.println("green - ", rc.green)
   fmt.println("blue - ", rc.blue)
}

@private rgb_to_uint1 :: proc(rc : Color) -> uint {
   clr : uint = ((rc.red & 0xff) << 16) + ((rc.green & 0xff) << 8) + (rc.blue & 0xff)
   return clr
}

@private rgb_to_uint2 :: proc(r, g, b : int) -> uint {
   ur := cast(uint) r
   ug := cast(uint) g
   ub := cast(uint) b
   clr : uint = ((ur & 0xff) << 16) + ((ug & 0xff) << 8) + (ub & 0xff)
   return clr
}

rgb_to_uint :: proc{rgb_to_uint1, rgb_to_uint2}

print_color_uint :: proc(rc :Color){
   clr : uint = ((rc.red & 0xff) << 16) + ((rc.green & 0xff) << 8) + (rc.blue & 0xff)
   fmt.printf("Rgb Value - %x\n",clr)
}

print_rgb_2 :: proc(r, g, b : uint) {
   print("red = ", r)
   print("green = ", g)
   print("blue = ", b)
   print("---------------------------")
}


// Later install Ouput colorizer & Bookmarks extensions