shader_type spatial;

void fragment() {
	float offset = COLOR.r * 1.0 + COLOR.g * 5.0 + COLOR.b * 10.0;
	
	ALBEDO = vec3(0.2);
	EMISSION = COLOR.rgb * (sin(TIME + offset) * 0.5 + 0.6);
	
}