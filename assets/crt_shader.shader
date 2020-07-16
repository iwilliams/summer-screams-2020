// https://github.com/hiulit/Godot-3-2D-CRT-Shader

shader_type canvas_item;

uniform float boost : hint_range(1.0, 2.0, 0.01) = float(1.2);
uniform float grille_opacity : hint_range(0.0, 1.0, 0.01) = float(0.85);
uniform float scanlines_opacity : hint_range(0.0, 1.0, 0.01) = float(0.95);
uniform float vignette_opacity : hint_range(0.1, 0.5, 0.01) = float(0.2);
uniform float scanlines_speed : hint_range(0.0, 1.0, 0.01) = float(1.0);
uniform bool show_grille = true;
uniform bool show_scanlines = true;
uniform bool show_vignette = true;
uniform bool show_curvature = true; // Curvature works best on stretch mode 2d.
uniform vec2 screen_size = vec2(320.0, 180.0);
uniform float aberration_amount : hint_range(0.0, 10.0, 1.0) = float(0.0);
uniform bool move_aberration = false;
uniform float aberration_speed : hint_range(0.01, 10.0, 0.01) = float(1.0);

vec2 CRTCurveUV(vec2 uv) {
	if(show_curvature) {
		uv = uv * 2.0 - 1.0;
    // Default values 8.0, 4.0
		vec2 offset = abs(uv.yx) / vec2(8.0, 2.5);
		uv = uv - uv * offset * offset;
		uv = uv * 0.5 + 0.5;
	}
	return uv;
}

void DrawVignette(inout vec3 color, vec2 uv) {
	if(show_vignette) {
		float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vignette = clamp(pow((screen_size.x / 4.0) * vignette, vignette_opacity), 0.0, 1.0);
		color *= vignette;
	} else {
		return;
	}
}

void DrawScanline(inout vec3 color, vec2 uv, float time) {
	float scanline = clamp((scanlines_opacity - 0.05) + 0.05 * sin(3.1415926535 * (uv.y + 0.008 * time) * screen_size.y), 0.0, 1.0);
	float grille = (grille_opacity - 0.15) + 0.15 * clamp(1.5 * sin(3.1415926535 * uv.x * screen_size.x), 0.0, 1.0);

	if (show_scanlines) {
		color *= scanline;
	}

	if (show_grille) {
		color *= grille;
	}

	color *= boost;
}

//Function to get fragment luminosity (B&W)
float luma(vec4 color) {
	return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}

//Dithering code
float dither8x8internal(vec2 position, float brightness) {
	int x = int(mod(position.x, 16.0));
	int y = int(mod(position.y, 16.0));
	int index = x + y * 16;
	float limit = 0.0;

	if (x < 16) {
		if (index == 0) limit = 0.015625;
		if (index == 1) limit = 0.515625;
		if (index == 2) limit = 0.140625;
		if (index == 3) limit = 0.640625;
		if (index == 4) limit = 0.046875;
		if (index == 5) limit = 0.546875;
		if (index == 6) limit = 0.171875;
		if (index == 7) limit = 0.671875;
		if (index == 8) limit = 0.765625;
		if (index == 9) limit = 0.265625;
		if (index == 10) limit = 0.890625;
		if (index == 11) limit = 0.390625;
		if (index == 12) limit = 0.796875;
		if (index == 13) limit = 0.296875;
		if (index == 14) limit = 0.921875;
		if (index == 15) limit = 0.421875;
		if (index == 16) limit = 0.203125;
		if (index == 17) limit = 0.703125;
		if (index == 18) limit = 0.078125;
		if (index == 19) limit = 0.578125;
		if (index == 20) limit = 0.234375;
		if (index == 21) limit = 0.734375;
		if (index == 22) limit = 0.109375;
		if (index == 23) limit = 0.609375;
		if (index == 24) limit = 0.953125;
		if (index == 25) limit = 0.453125;
		if (index == 26) limit = 0.828125;
		if (index == 27) limit = 0.328125;
		if (index == 28) limit = 0.984375;
		if (index == 29) limit = 0.484375;
		if (index == 30) limit = 0.859375;
		if (index == 31) limit = 0.359375;
		if (index == 32) limit = 0.0625;
		if (index == 33) limit = 0.5625;
		if (index == 34) limit = 0.1875;
		if (index == 35) limit = 0.6875;
		if (index == 36) limit = 0.03125;
		if (index == 37) limit = 0.53125;
		if (index == 38) limit = 0.15625;
		if (index == 39) limit = 0.65625;
		if (index == 40) limit = 0.8125;
		if (index == 41) limit = 0.3125;
		if (index == 42) limit = 0.9375;
		if (index == 43) limit = 0.4375;
		if (index == 44) limit = 0.78125;
		if (index == 45) limit = 0.28125;
		if (index == 46) limit = 0.90625;
		if (index == 47) limit = 0.40625;
		if (index == 48) limit = 0.25;
		if (index == 49) limit = 0.75;
		if (index == 50) limit = 0.125;
		if (index == 51) limit = 0.625;
		if (index == 52) limit = 0.21875;
		if (index == 53) limit = 0.71875;
		if (index == 54) limit = 0.09375;
		if (index == 55) limit = 0.59375;
		if (index == 56) limit = 1.0;
		if (index == 57) limit = 0.5;
		if (index == 58) limit = 0.875;
		if (index == 59) limit = 0.375;
		if (index == 60) limit = 0.96875;
		if (index == 61) limit = 0.46875;
		if (index == 62) limit = 0.84375;
		if (index == 63) limit = 0.34375;
	}
	
	return brightness < limit ? 0.0 : 1.0;
}

//Dithering function
vec4 dither8x8(vec2 position, vec4 color) {
	return vec4(color.rgb * dither8x8internal(position, luma(color)), 1.0);
}

void fragment() {
	vec2 screen_crtUV = CRTCurveUV(SCREEN_UV);
	vec3 color = texture(SCREEN_TEXTURE, screen_crtUV).rgb;
	
	if (aberration_amount > 0.0) {
		float adjusted_amount = aberration_amount / screen_size.x;
		
		if (move_aberration == true) {
			adjusted_amount = (aberration_amount / screen_size.x) * cos((2.0 * 3.14159265359) * (TIME / aberration_speed));
		} 
		
		color.r = texture(SCREEN_TEXTURE, vec2(screen_crtUV.x + adjusted_amount, screen_crtUV.y)).r;
		color.g = texture(SCREEN_TEXTURE, screen_crtUV).g;
		color.b = texture(SCREEN_TEXTURE, vec2(screen_crtUV.x - adjusted_amount, screen_crtUV.y)).b;
	}
	
	vec2 crtUV = CRTCurveUV(UV);
	if (crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0) {
		color = vec3(0.0, 0.0, 0.0);
	}
	
	DrawVignette(color, crtUV);
	DrawScanline(color, crtUV, TIME * scanlines_speed);
	
	COLOR = vec4(color, 1.0);
//    COLOR = dither8x8(FRAGCOORD.xy, COLOR);
}