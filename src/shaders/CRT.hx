package shaders;

class CRT extends h3d.shader.ScreenShader {
    static var SRC = {
        @param var screenWidth : Int;
        @param var screenHeight : Int;

        @param var texture : Sampler2D;

        // how strong is the color R,G,B effect of the pixels.
		@param var strength : Float = 0.2;
        // how strong is the black line that seperates the pixels?
		@param var scanStrength : Float = 0.3;
		
        function fragment() { 
            pixelColor = texture.get(input.uv);

            // determines what pixel position
            var xpos = floor(input.uv.x * screenWidth);
            var ypos = floor(input.uv.y * screenHeight);

            // gets the remained so we can determine how to color
            // the pixel.
            var rx = mod(xpos, 3.0);
            var ry = mod(ypos, 3.0);

            if (rx == 1) { 

                pixelColor.g *= (1 - strength);
                pixelColor.b *= (1 - strength);

            } else if (rx == 2) {

                pixelColor.r *= (1 - strength);
                pixelColor.b *= (1 - strength);

            } else {

                pixelColor.r *= (1 - strength);
                pixelColor.g *= (1 - strength);

            }

            if (ry == 1) {
                pixelColor.r *= (1 - scanStrength);
                pixelColor.g *= (1 - scanStrength);
                pixelColor.b *= (1 - scanStrength);
            }

		}
    }
}