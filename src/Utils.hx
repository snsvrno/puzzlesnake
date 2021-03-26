class Utils {
	inline static public function hexToRGB(color : Int) : { r : Int, g : Int, b : Int } {
		var r = color >> 16 & 0xff;
		var g = color >> 8 & 0xff;
		var b = color & 0xff;
		return { r:r, g:g, b:b };
	}

	inline static public function RGBToHex(r : Int, g : Int, b : Int) : Int {
		return (r << 16) | (g << 8) | b;
	}
}