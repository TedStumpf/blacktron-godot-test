shader_type canvas_item;

uniform float speedFullness : hint_range(0.0, 1.0);
uniform float rotationFullness : hint_range(-1.0, 1.0);

uniform vec4 mainRingColor : hint_color;
uniform vec4 backgroundColor : hint_color;
uniform vec4 speedColor : hint_color;
uniform vec4 rotationColor : hint_color;

uniform float ringSegments : hint_range(1, 8, 1);
uniform float mainRingRadius : hint_range(0.0, 1.0);
uniform float mainRingThickness : hint_range(0.0, 0.2);
uniform float innerRingThickness : hint_range(0.0, 0.2);
uniform float dividerThickness : hint_range(0.0, 0.5);

void vertex() {
// Output:0

}

float CalcRingMask(vec2 pos, float radius, float thickness) {
	float dist = sqrt(pow(pos.x, 2.0) + pow(pos.y, 2.0)) - radius;
	if (abs(dist) <= thickness){
		return 1.0;
	}
	return 0.0;
}

void fragment() {
	vec2 centeredUV = (UV - vec2(0.5)) * vec2(2.0);

	//	Main Ring
	float mainRingMask = CalcRingMask(centeredUV, mainRingRadius, mainRingThickness);
	vec3 mainRing = mainRingColor.rgb * vec3(mainRingMask);
	
	//	Starts facing right, CCW
	float angle = mod(-(degrees(atan(centeredUV.x, centeredUV.y)) + 270.0), 360.0);
	
	//	Segment Mask
	float segmentSep = 360.0 / (ringSegments * 2.0);
	float dividerSize = segmentSep * dividerThickness;
	float segmentDist = mod(angle + 90.0, segmentSep);
	segmentDist = min(segmentDist, segmentSep - segmentDist);
	float segmentMask = 0.0;
	if (segmentDist > dividerSize) {
		segmentMask = 1.0;
	}
	segmentMask *= CalcRingMask(centeredUV, mainRingRadius, innerRingThickness);
	vec3 innerSegments = backgroundColor.rgb * vec3(segmentMask);
	
	if (centeredUV.x < 0.0) {
		float speedFullAng = (270.0 - dividerSize) - (180.0 - dividerSize * 2.0) * speedFullness;
		if (angle >= speedFullAng) {
			innerSegments = speedColor.rgb * vec3(segmentMask);
		}
	} else {
		if (rotationFullness >= 0.0) {
			float rotationFullAngle = (90.0 - dividerSize * 2.0) * rotationFullness + dividerSize;
			if (angle <= rotationFullAngle) {
				innerSegments = rotationColor.rgb * vec3(segmentMask);
			}
		} else {
			float rfa = (360.0 - dividerSize) - (90.0 - dividerSize * 2.0) * abs(rotationFullness);
			if (angle >= rfa) {
				innerSegments = rotationColor.rgb * vec3(segmentMask);
			}
		}
	}

	// Output
	COLOR.rgb = mainRing * (1.0 - segmentMask) + innerSegments;
	COLOR.a = mainRingMask;
}

void light() {
// Output:0

}
