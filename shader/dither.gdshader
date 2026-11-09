/* 
This shader is under MIT license. Feel free to use, improve and 
change this shader according to your needs and consider sharing 
the modified result to godotshaders.com.
*/

shader_type canvas_item;

// uniform sampler2D u_dither_tex;
// uniform sampler2D u_color_tex;

// uniform int u_bit_depth;
// uniform float u_contrast;
// uniform float u_offset;
uniform int u_dither_size;

void fragment() {
	// sample the screen texture at the desired output resolution (according to u_dither_size)
	// this will effectively pixelate the resulting output
	vec2 screen_size = vec2(textureSize(TEXTURE, 0)) / float(u_dither_size);
	vec2 screen_sample_uv = floor(UV * screen_size) / screen_size;
	vec4 screen_col = texture(TEXTURE, screen_sample_uv);
	COLOR = screen_col;
}