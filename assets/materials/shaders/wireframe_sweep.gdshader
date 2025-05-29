shader_type spatial;
render_mode  wireframe;

uniform vec3 color : source_color;
varying vec3 world_pos;

void vertex() {
	world_pos = (vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// scanner sweep effect
	float positional_map = 0.8 * sin(TIME * 2.0 + 0.1 * world_pos.y) + 0.4;
	float wireframe_map =  clamp(positional_map, 0, 1);

	ALBEDO = color;
	EMISSION = color;
	ALPHA = wireframe_map;
}
