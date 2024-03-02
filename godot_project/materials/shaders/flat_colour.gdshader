shader_type spatial;
render_mode blend_add, unshaded;

uniform vec3 colour = vec3(1.0, 0.0, 0.0);

void fragment() {
	ALBEDO = colour;
}
