shader_type canvas_item;
render_mode unshaded;

#define MAX_COLORS 16

uniform bool enabled = true;
uniform bool dithering = true;
uniform int colors : hint_range(1, MAX_COLORS) = 12;
uniform int dither_size : hint_range(1, 8) = 1;

float ditheringPattern(ivec2 fragcoord) {
	const float pattern[] = {
		0.00, 0.50, 0.10, 0.65,
		0.75, 0.25, 0.90, 0.35,
		0.20, 0.70, 0.05, 0.50,
		0.95, 0.40, 0.80, 0.30
	};
	
	int x = fragcoord.x % 4;
	int y = fragcoord.y % 4;
	
	return pattern[y * 4 + x];
}

float reduceColor(float raw, float dither, int depth) {
	float div = 1.0 / float(depth);
	float val = 0.0;
	int i = 0;
	
	while(i <= MAX_COLORS) {
		if(raw > div * float(i + 1)) {
			i = i + 1;
			continue;
		}
		
		if(raw * float(depth) - float(i) <= dither * 0.999) {
			val = div * float(i);
		} else {
			val = div * float(i + 1);
		}
		
		return val;
		
		i = i + 1; // don't think this'll ever get touched??
	}
	
	return val;
}

void fragment() {
	vec4 raw = texture(TEXTURE, SCREEN_UV);
	ivec2 uv = ivec2(FRAGCOORD.xy / float(dither_size));
	
	if(enabled == true) {
		float dithering_value = 1.0;
		
		if(dithering)
			dithering_value = ditheringPattern(uv);
		
		COLOR.r = reduceColor(raw.r, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
		COLOR.g = reduceColor(raw.g, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
		COLOR.b = reduceColor(raw.b, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
	} else {
		COLOR.rgb = raw.rgb;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
