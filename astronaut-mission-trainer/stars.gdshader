shader_type sky;
// Procedural starfield, no image needed. Untested: tune the uniforms in the Inspector.

uniform vec3 space_color : source_color = vec3(0.0, 0.0, 0.015);
uniform float scale = 120.0;      // higher = more, smaller stars
uniform float density = 0.985;    // closer to 1.0 = fewer stars
uniform float brightness = 1.5;

float hash(vec3 p) {
	p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void sky() {
	vec3 dir = normalize(EYEDIR) * scale;
	vec3 cell = floor(dir);
	float h = hash(cell);
	float d = length(fract(dir) - 0.5);
	float star = smoothstep(density, 1.0, h) * smoothstep(0.25, 0.0, d);
	COLOR = space_color + vec3(star * brightness);
}
