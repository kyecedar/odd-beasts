shader_type spatial;

varying vec4 affine_uv;

void vertex() {
	vec4 view_space = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	affine_uv = vec4(UV * VERTEX.z, VERTEX.z, 0);
	// Called for every vertex the material is visible on.
}

void fragment() {
	//ALBEDO = texture(TEXTURE)
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
