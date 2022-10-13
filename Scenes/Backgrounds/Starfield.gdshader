shader_type canvas_item;

uniform sampler2D starData;
uniform int starCount : hint_range(0, 10000);
uniform float radius;

void fragment() {
	float pix = 0.0;
	float minDist = radius + 1.0;
	for (int i = 0; i < starCount; i++) {
		float dist = distance(texture(starData, vec2(float(i) / float(starCount), 0.5)).xy, UV);
		dist = min(minDist, dist);
		if (dist <= radius) {
			pix = 1.0;
			break;
		}
	}
	// Output
	COLOR.rgb = vec3(pix);
	COLOR.a = 1.0;
}