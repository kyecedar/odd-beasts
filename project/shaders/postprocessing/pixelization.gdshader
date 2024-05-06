shader_type spatial;
render_mode unshaded;

// MIT License. Made by Leo Peltola. Adapted by ARez.
// Inspired by https://threejs.org/examples/webgl_postprocessing_pixel.html

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

uniform bool disable_shader = false;
uniform float MAX_DEPTH : hint_range(0.0, 10000.0, 1.0) = 1000.0;

uniform float pixel_size : hint_range(1.0, 16.0, 1.0) = 1.0;

uniform bool shadows_enabled = true;
uniform bool highlights_enabled = true;
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float highlight_strength : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec3 highlight_color : source_color = vec3(0.45);
uniform vec3 shadow_color : source_color = vec3(0.0);



float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_proj_mat) {
	float raw_depth = texture(depth_texture, screen_uv)[0];
	vec3 normalized_device_coords = vec3(screen_uv * 2.0 - 1.0, raw_depth);
	vec4 view_space = inv_proj_mat * vec4(normalized_device_coords, 1.0);
	view_space.xyz /= view_space.w;
	return -view_space.z;
}

float normalIndicator(vec3 normal_edge_bias, vec3 base_normal, vec3 new_normal, float depth_diff) {
	// credit: https://threejs.org/examples/webgl_postprocessing_pixel.html
	float normal_diff = dot(base_normal - new_normal, normal_edge_bias);
	float normal_indicator = clamp(smoothstep(-0.01, 0.01, normal_diff), 0.0, 1.0);
	float depth_indicator = clamp(sign(depth_diff * 0.25 + 0.0025), 0.0, 1.0);
	return (1.0 - dot(base_normal, new_normal)) * depth_indicator * normal_indicator;
}



void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 ires = VIEWPORT_SIZE.xy;
	vec2 single_pixel_size = 1.0 / ires;
	
	// credit: AivanWorld // https://godotshaders.com/shader/pixelate-3d-effect
	float x = FRAGCOORD.x - mod(FRAGCOORD.x, pixel_size);
	float y = FRAGCOORD.y - mod(FRAGCOORD.y, pixel_size);
	
	ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) * single_pixel_size).rgb;
	
	//vec2 cell_size = float(pixel_size) * single_pixel_size;
	//vec2 e = cell_size;
	//vec2 uv = cell_size * round(SCREEN_UV / cell_size);
	//vec2 orig_uv = SCREEN_UV;
	//
	//// SHADOWS ////
	//float depth_diff = 0.0;
	//float neg_depth_diff = 0.0;
	//if(shadows_enabled) {
		//// get depth around the pixel to add ambient occlusion.
		//float depth = getDepth(uv, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//if(depth > MAX_DEPTH) discard;
		//
		//// (up, right, down, left)
		//float du = getDepth(uv + vec2( 0.0,-1.0) * e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float dr = getDepth(uv + vec2( 1.0, 0.0) * e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float dd = getDepth(uv + vec2( 0.0, 1.0) * e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//float dl = getDepth(uv + vec2(-1.0, 0.0) * e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		//
		//depth_diff += clamp(du - depth, 0.0, 1.0);
		//depth_diff += clamp(dd - depth, 0.0, 1.0);
		//depth_diff += clamp(dr - depth, 0.0, 1.0);
		//depth_diff += clamp(dl - depth, 0.0, 1.0);
		//
		//neg_depth_diff += depth - du;
		//neg_depth_diff += depth - dd;
		//neg_depth_diff += depth - dr;
		//neg_depth_diff += depth - dl;
		//
		//neg_depth_diff = clamp(neg_depth_diff, 0.0, 1.0);
		//neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff) * 10.0, 0.0, 1.0);
		//
		//depth_diff = smoothstep(0.2, 0.3, depth_diff);
		//// ALBEDO = vec3(depth_diff);
	//}
	//
	//// HIGHLIGHTS ////
	//float normal_diff = 0.0;
	//if(highlights_enabled) {
		//// get normals to highlight edge.
		//vec2 uv_use = max(uv, orig_uv);
		//vec3 normal = texture(NORMAL_TEXTURE, uv_use).rgb * 2.0 - 1.0;
		//
		//// (up, right, down, left)
		//vec3 nu = texture(NORMAL_TEXTURE, uv_use + vec2( 0.0,-1.0) * e).rgb * 2.0 - 1.0;
		//vec3 nr = texture(NORMAL_TEXTURE, uv_use + vec2( 1.0, 0.0) * e).rgb * 2.0 - 1.0;
		//vec3 nd = texture(NORMAL_TEXTURE, uv_use + vec2( 0.0, 1.0) * e).rgb * 2.0 - 1.0;
		//vec3 nl = texture(NORMAL_TEXTURE, uv_use + vec2(-1.0, 0.0) * e).rgb * 2.0 - 1.0;
		//
		//vec3 normal_edge_bias = vec3(1.0, 1.0, 1.0);
		//
		//normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		//normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		//normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		//normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
		//
		//normal_diff = smoothstep(0.2, 0.8, normal_diff);
		//normal_diff = clamp(normal_diff - neg_depth_diff, 0.0, 1.0);
		//
		//// ALBEDO = vec3(normal_diff);
	//}
	//
	//vec3 original_color = ALBEDO;
	//original_color = texture(SCREEN_TEXTURE, uv).rgb;
	//vec3 final_highlight_color = mix(original_color, highlight_color, highlight_strength);
	//vec3 final_shadow_color = mix(original_color, shadow_color, shadow_strength);
	//vec3 final = original_color;
	//
	//if(highlights_enabled) {
		//final = mix(final, final_highlight_color, normal_diff);
	//}
	//
	//if(shadows_enabled) {
		//final = mix(final, final_shadow_color, depth_diff);
	//}
	//
	//ALBEDO = vec3(normal_diff);
	//ALBEDO = final;
	//
	//float alpha_mask = depth_diff * float(shadows_enabled) + normal_diff * float(highlights_enabled);
	//ALPHA = clamp((alpha_mask) * 5.0, 0.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
