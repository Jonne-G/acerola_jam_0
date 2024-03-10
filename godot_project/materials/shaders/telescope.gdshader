shader_type spatial;

render_mode unshaded, blend_add;

uniform sampler2D fade_gradient;

instance uniform vec3 colour = vec3(1.0, 0.0, 0.0);
instance uniform float size = 505;
uniform float total_size = 505;
uniform float alpha_multiplier = 0.8;

varying vec3 LocalPos;

void vertex() {
	LocalPos = VERTEX;
	
}

void fragment() {
	float gradient = clamp((LocalPos.y + total_size * 0.5) / size, 0.0, 0.99);
	ALBEDO = vec3(colour);
	ALPHA = texture(fade_gradient, vec2(gradient)).x * alpha_multiplier;
}
