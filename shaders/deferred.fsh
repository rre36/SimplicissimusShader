#version 120
#include "/lib/math.glsl"

/*
const int colortex0Format   = RGB16;
const int colortex1Format   = RGB16;
const int colortex2Format   = RGB16;
*/

uniform sampler2D colortex0;

const float shadowDistance      = 128.0;
const float sunPathRotation 	= -5.0; 	//[25.0 20.0 15.0 10.0 5.0 0.0 -5.0 -10.0 -15.0 -20.0 -25.0]

varying vec2 coord;

void main() {
	vec3 scenecolor 	= texture2D(colortex0, coord).rgb;

	/*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(scenecolor, 1.0);
}
