
package winforms
import "core:fmt"

RgbColor :: struct {red, green, blue : uint,}

@private rgb_color_uint :: proc(clr : uint) -> RgbColor {
   return _get_rgb_color(clr)
}
@private rgb_color_3value :: proc(r, g, b: uint) -> RgbColor {
   rc : RgbColor
   rc.red = r
   rc.green = g
   rc.blue = b
   return rc
}

@private rgb_from_clrref :: proc(clr : ColorRef) -> RgbColor {
   rc : RgbColor

   return rc
}

new_rgb_color :: proc{rgb_color_uint, rgb_color_3value, rgb_from_clrref}


_get_rgb_color :: proc(clr : uint) -> RgbColor {
   rc : RgbColor
   rc.red = clr >> 16
   rc.green = (clr & 0x00ff00) >> 8
   rc.blue = clr & 0x0000ff
   return rc
}


@private get_color_ref1 :: proc(clr : uint) -> ColorRef {
	rc := _get_rgb_color(clr)
	rst := (rc.blue << 16) | (rc.green << 8) | rc.red
	return cast(ColorRef) rst
}
@private get_color_ref2 :: proc(r, g, b : uint) -> ColorRef {
	return ColorRef((b << 16) | (g << 8) | r)
	//return cast(ColorRef) rst
}

@private get_color_ref3 :: proc(rc : RgbColor) -> ColorRef {
	return ColorRef((rc.blue << 16) | (rc.green << 8) | rc.red)
	//return cast(ColorRef) rst
}

get_color_ref :: proc{get_color_ref1, get_color_ref2, get_color_ref3}
get_solid_brush :: proc(clr : uint) -> Hbrush { return CreateSolidBrush(get_color_ref(clr))}
//---------------------------------------------------------

change_color_uint :: proc(clr : uint, adj : f64) -> RgbColor {
   rc := new_rgb_color(clr)
   rc.red = cast(uint) (f64(rc.red) * adj)
   rc.green = cast(uint) (f64( rc.green) * adj)
   rc.blue = cast(uint) (f64( rc.blue) * adj)
   if rc.red > 255 do rc.red = 255
   if rc.green > 255 do rc.green = 255
   if rc.blue > 255 do rc.blue = 255
   return rc
}

change_color :: proc(clr : uint, adj : f64) -> ColorRef {
   rc := change_color_uint(clr, adj)
   crf := get_color_ref(rc)
   return crf
}

change_color_rgb :: proc(rc : ^RgbColor, adj : f64) {
   rc.red = cast(uint) (f64(rc.red) * adj)
   rc.green = cast(uint) (f64( rc.green) * adj)
   rc.blue = cast(uint) (f64( rc.blue) * adj)
   if rc.red > 255 do rc.red = 255
   if rc.green > 255 do rc.green = 255
   if rc.blue > 255 do rc.blue = 255

}

change_color_get_uint :: proc(rgbc : RgbColor, adj : f64) -> ColorRef {
   rc := rgbc
   rc.red = cast(uint) (f64(rc.red) * adj)
   rc.green = cast(uint) (f64( rc.green) * adj)
   rc.blue = cast(uint) (f64( rc.blue) * adj)
   if rc.red > 255 do rc.red = 255
   if rc.green > 255 do rc.green = 255
   if rc.blue > 255 do rc.blue = 255
   crf := get_color_ref(rc)
   return crf

}

change_gradient_color :: proc(gc : GradientColors, adj : f64) -> GradientColors {
   ngc : GradientColors = gc
   change_color_rgb(&ngc.color1, adj)
   change_color_rgb(&ngc.color2, adj)
   return ngc
}





print_rgb:: proc(rc : RgbColor)
{
   fmt.println("red - ", rc.red)
   fmt.println("green - ", rc.green)
   fmt.println("blue - ", rc.blue)
}

@private rgb_to_uint1 :: proc(rc : RgbColor) -> uint {
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

print_color_uint :: proc(rc :RgbColor){
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