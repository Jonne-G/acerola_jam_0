shader_type spatial;
render_mode blend_add, unshaded, world_vertex_coords;

uniform bool use_vertex_colour = false;
uniform vec3 colour = vec3(1.0, 0.0, 0.0);
uniform vec2 fade_bounds = vec2(4.0, 5.5);

varying vec3 WSPos;

void vertex() {
	WSPos = VERTEX;
}

void fragment() {
	if(use_vertex_colour)
		ALBEDO = COLOR.rgb;
	else
		ALBEDO = colour;
	
	float distance = length(WSPos);
	
	float blend = (distance - fade_bounds.y) / (fade_bounds.x - fade_bounds.y);
	
	ALPHA = clamp(blend, 0.0, 1.0);
}
