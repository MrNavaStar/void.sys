shader_type spatial;
render_mode  unshaded, blend_mix, depth_draw_never, cull_disabled;

uniform sampler2D animation_frames[103];
uniform float fps = 60.0;
uniform float time_offset = 0.0;

void fragment() {
    float time = TIME;
    int total_frames = 103;
    int current_frame = int(mod(time * fps, float(total_frames)));
	
    vec2 uv = UV;
	uv.x = uv.x * 5.0;
	uv.y += 0.1;
	
	vec4 tex = texture(animation_frames[current_frame], uv);
    ALBEDO = tex.rgb;
	ALPHA = tex.a;
}