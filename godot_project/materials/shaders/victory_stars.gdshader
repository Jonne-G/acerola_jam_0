shader_type canvas_item;

uniform sampler2D colour_texture;
uniform float star_scale;
uniform float time_scale = 0.1;
uniform float alpha = 1.0;

void fragment() {
	float time = TIME * time_scale;
	vec2 coords = SCREEN_UV * star_scale + vec2(time);
	
	COLOR = texture(colour_texture, fract(coords));
	COLOR.a = alpha;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
