shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform sampler2D animation_frames[103];
uniform float fps = 240.0;

instance uniform float line_length = 0.2;

void fragment() {
    float time = TIME;
    int total_frames = 103;
    int current_frame = int(mod(time * fps, float(total_frames)));

    vec2 uv = UV;
	uv.y = uv.y * 4.0 * line_length * 5.0;

	vec4 tex = texture(animation_frames[current_frame], uv);
    ALBEDO = tex.rgb;
	ALPHA = tex.a;
}