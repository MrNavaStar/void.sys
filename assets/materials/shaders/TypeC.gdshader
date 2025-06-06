shader_type spatial;
render_mode  blend_mix, depth_draw_always, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_albedo : source_color;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 vec4_albedo = texture(tex_albedo, UV);
	vec3 base_albedo = vec3(vec4_albedo.xyz);

	float positional_map = 0.4 * sin(TIME * 2.0 + 4.0 * world_pos.y) + 1.0;
	float wireframe_map =  clamp(positional_map, 0, 1);

	ALBEDO = base_albedo;
	//ALPHA = wireframe_map;
}