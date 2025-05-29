shader_type spatial;
render_mode  blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D tex_albedo : source_color;
uniform sampler2D tex_emission : source_color;

void fragment() {
	vec4 vec4_albedo = texture(tex_albedo, UV);
	vec4 vec4_emission = texture(tex_emission, UV);
	vec3 base_albedo = vec3(vec4_albedo.xyz);
	vec3 base_emission = vec3(vec4_emission.xyz);

	ALBEDO = base_albedo;
	EMISSION = base_emission;
}