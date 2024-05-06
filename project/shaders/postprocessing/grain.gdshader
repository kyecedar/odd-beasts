shader_type canvas_item;

// derived from qjpg: https://godotshaders.com/shader/post-processing-and-grain-pp-effect/

uniform float pixel = 1.0;
uniform sampler2D palette;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

const float BIT = 6.0;
const mat4 BAYER = mat4(
	vec4( 1.0,  9.0,  3.0, 11.0),
	vec4(13.0,  5.0, 15.0,  7.0),
	vec4( 4.0, 12.0,  2.0, 10.0),
	vec4(16.0,  8.0, 14.0,  6.0)
);



float bayer(int x, int y) {
	return BAYER[x][y];
}



void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec4 _color = texture(SCREEN_TEXTURE, floor(FRAGCOORD.xy / pixel));
	vec4 color = _color * texture(palette, vec2(_color.r, 1.0));
	
	float b = bayer(int(FRAGCOORD.x) % 4, int(FRAGCOORD.y) % 4);
	vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;
	vec4 col_noise = color;
	vec3 noise = vec3(fract(sin(dot(FRAGCOORD.xy / SCREEN_PIXEL_SIZE, vec2(12.9898, 78.233))) * 43758.5453));
	noise *= 0.1;
	noise.xy *= (b / 16.0) * 1.5;
	col_noise.rgb += noise;
	
	vec4 post = col_noise * floor(col_noise * 4.0) / 4.0;
	
	COLOR *= post;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
