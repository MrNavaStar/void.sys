shader_type spatial;
render_mode wireframe;

uniform vec3 color : source_color;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// scanner sweep effect
	float positional_map = -1.0 * sin(TIME * 2.0 + 4.0 * world_pos.y) + 0.4;
	float wireframe_map = clamp(positional_map, 0, 1);

	ALBEDO = color;
	EMISSION = color * wireframe_map;
	ALPHA = wireframe_map;
}
