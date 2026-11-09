shader_type spatial;

uniform sampler2D img_tex;
uniform float img_size;
uniform float tex_scale;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 scaled_uv = fract(UV * tex_scale);
	vec2 sampled_uv = floor(scaled_uv * img_size) / img_size;
	ALBEDO = texture(img_tex, sampled_uv).rgb;
}
