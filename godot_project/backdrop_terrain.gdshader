shader_type spatial;

uniform sampler2D colour_gradient;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(colour_gradient, vec2(1.0 - COLOR.b)).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
