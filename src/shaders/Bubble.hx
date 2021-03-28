package shaders;

class Bubble extends h3d.shader.ScreenShader {
    static var SRC = {
        @param var texture : Sampler2D;

		@param var backgroundColor : Vec4 = vec4(0,0,0,1);
		@param var curvature : Vec2 = vec2(4,4);
		
        function fragment() {
			
			// suppose to do the screen distortion
			// doesn't look good.

			var step1 = input.uv * 2 - 1;
			var offset = abs(step1.yx) / curvature;
			var step2 = step1 + step1 * offset * offset;
			var step3 = step2 * 0.5 + 0.5;

			pixelColor = texture.get(step3);
			
			// set a little bit of a "bleed" so we don't get a weird edge.
			if (step3.x < 0.02 || step3.y < 0.02 || step3.y > 0.98 || step3.x > 0.98) {
				pixelColor = backgroundColor;
			} else {
            	pixelColor = texture.get(step3);
			}
			

        }
    }
}