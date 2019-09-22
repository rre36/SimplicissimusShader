#version 120
#include "/lib/math.glsl"

const int RGB16 = 0;
const int RGBA16 = 0;
const int colortex0Format   = RGB16;
const int colortex2Format 	= RGBA16;
const int colortex5Format   = RGB16;

uniform sampler2D colortex0;

const int shadowMapResolution   = 4096;
const float shadowDistance      = 128.0;
const float sunPathRotation 	= -5.0;

varying vec2 coord;

void main() {
	vec3 scenecolor 	= texture2D(colortex0, coord).rgb;

	/*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(scenecolor, 1.0);
}
