shader_type particles;
render_mode disable_velocity;

uniform float instance_rows    : hint_range(1, 1000, 1) = 40;
uniform float instance_spacing : hint_range(0.0, 2.0) = 0.1;
uniform float instance_scale_x = 1.0;
uniform float instance_scale_y = 1.0;
uniform float instance_scale_z = 1.0;
uniform float instance_scale_randomize = 1.0;
uniform float instance_pos_randomize : hint_range(0.0, 50.0, 0.5) = 2.0;
uniform float instance_scale_min = 0.2;
uniform float instance_scale_max = 1.2;

void start() {
	// get position.
	vec3 pos = vec3(0.0);
	pos.z = float(INDEX);
	pos.x = mod(pos.z, instance_rows);
	pos.z = (pos.z - pos.x) / instance_rows;

	// center the emitter.
	pos.x -= instance_rows * 0.5;
	pos.z -= instance_rows * 0.5;

	// apply instance spacing;
	pos *= instance_spacing;

	// center on position of emitter.
	pos.x += EMISSION_TRANSFORM[3][0] - mod(EMISSION_TRANSFORM[3][0], instance_spacing);
	pos.z += EMISSION_TRANSFORM[3][2] - mod(EMISSION_TRANSFORM[3][2], instance_spacing);

	TRANSFORM[3][0] = pos.x;
	TRANSFORM[3][1] = pos.y;
	TRANSFORM[3][3] = pos.z;
}

void process() {
	// Called every frame on existing particles (according to the Fixed FPS property).
}
