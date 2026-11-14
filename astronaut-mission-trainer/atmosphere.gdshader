shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never;
// Blue glow at the edge of a slightly larger sphere around Earth. Untested.

uniform vec4 glow_color : source_color = vec4(0.3, 0.55, 1.0, 1.0);
uniform float power = 3.0;        // higher = thinner glow
uniform float intensity = 1.5;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), power);
	ALBEDO = glow_color.rgb * intensity;
	ALPHA = clamp(fresnel, 0.0, 1.0);
}
