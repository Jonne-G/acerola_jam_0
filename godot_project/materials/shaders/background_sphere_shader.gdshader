shader_type spatial;
render_mode unshaded, world_vertex_coords;

group_uniforms ShaderParameters.NoiseParameters;
uniform sampler3D high_freq_noise;
uniform sampler3D low_freq_noise;

uniform float high_freq_noise_scale = 0.5;
uniform float low_freq_noise_scale = 0.125;

uniform int steps = 10;
group_uniforms;

group_uniforms ShaderParameters.Colour;
uniform sampler2D value_remap;
uniform sampler2D colour_gradient;
group_uniforms;

group_uniforms ShaderParameters.Movement;
uniform float animation_speed = 0.25;
uniform float scale_amount = 0.2;
group_uniforms;

group_uniforms ShaderParameters.Falloff;
uniform float falloff_threshold = 0.1;
uniform vec2 falloff_scale = vec2(0.075, 0.1);
uniform float falloff_pulse_speed = 0.1;
group_uniforms;

varying vec3 WSPos;
varying vec3 WSNormal;

void vertex() {
	WSPos = VERTEX;
	WSNormal = normalize(NORMAL);
}

void fragment() {
	float falloff_timing = sin(TIME * falloff_pulse_speed) * 0.5 + 0.5;
	
	float falloff = dot(WSNormal, mat3(INV_VIEW_MATRIX) * vec3(0.0, 0.0, 1.0));
	falloff += texture( low_freq_noise,  WSPos * mix(falloff_scale.x, falloff_scale.y, falloff_timing) ).x;
	//falloff += falloff_timing;
	
	if(falloff < falloff_threshold)
		discard;
	
	vec3 position = WSPos; //POSITION.xyz;
	vec3 direction = -normalize(CAMERA_POSITION_WORLD - position);//-(vec4(VIEW, 0.0) * INV_VIEW_MATRIX).xyz;
	vec3 offset = vec3(0.0, TIME * animation_speed, 0.0);
	vec3 scale = vec3((1.0 - scale_amount * 0.5) + sin(TIME * animation_speed) * scale_amount);
	
	float distance_travelled = 0.0;

	for(int i = 0; i < steps; i++)
	{
		vec3 high_freq_position = position * high_freq_noise_scale * scale + offset;
		vec3 low_freq_position = position * low_freq_noise_scale * scale - offset;
		
		float high_freq = texture(high_freq_noise, high_freq_position).x;
		float low_freq = texture(low_freq_noise, low_freq_position).x;
		
		float noise_value = sqrt(high_freq * low_freq);
		
		position += direction * noise_value;
		distance_travelled += noise_value;
	}

	float normalized = clamp(distance_travelled / float(steps), 0.0, 1.0);
	float remapped = clamp(texture(value_remap, vec2(normalized)).x, 0.0, 1.0);

	ALBEDO = texture(colour_gradient, vec2(clamp(remapped, 0.0, 1.0))).xyz * falloff;
	
}