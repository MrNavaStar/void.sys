shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_albedo : source_color;
uniform sampler2D tex_emission : source_color;

void fragment() {
	vec4 vec4_albedo = texture(tex_albedo, UV);
	vec4 vec4_emission = texture(tex_emission, UV);

	float blink_timing = clamp(0.5 * (sin(2.0 * TIME) + 0.8), 0, 1);

	ALBEDO = vec3(vec4_albedo.xyz) * blink_timing;
	EMISSION = vec3(vec4_emission.xyz) * blink_timing;
}
