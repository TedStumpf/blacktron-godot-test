shader_type canvas_item;

uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform sampler2D noise_shading;
uniform sampler2D noise_visibility;

void fragment() {
	float shading = texture(noise_shading, UV).x;
	float visibility = texture(noise_visibility, UV).x;
	float vis = visibility * visibility;
	vis = clamp(mix(-0.3, 0.8, vis), 0, 1);
	// Output
	vec4 col = mix(color1, color2, shading);
	COLOR.rgb = col.rgb;
	COLOR.a = vis;
}