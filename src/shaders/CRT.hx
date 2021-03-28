package shaders;

class CRT extends h3d.shader.ScreenShader {
    static var SRC = {
        @param var texture : Sampler2D;

		@param var screenWidth : Int;
		@param var screenHeight : Int;
		@param var strength : Float = 0.2;
		@param var scanStrength : Float = 0.4;
		
        function fragment() {
			pixelColor = texture.get(input.uv);

			var xpos = (input.position.x + 1) / 2 * screenWidth;
			var ypos = (input.position.y + 1) / 2 * screenHeight;

			var rx = xpos % 3;
			var ry = ypos % 3;

			if (rx <= 1) {
				pixelColor.g *= (1-strength);
				pixelColor.b *= (1-strength);
			} else if (rx <= 2) {
				pixelColor.r *= (1-strength);
				pixelColor.b *= (1-strength);
			} else {
				pixelColor.r *= (1-strength);
				pixelColor.g *= (1-strength);
			}

			if (ry <=1) {
				pixelColor *= scanStrength;
				pixelColor.a = 1;
			}
		}
    }
}