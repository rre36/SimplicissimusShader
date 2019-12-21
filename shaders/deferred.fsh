#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


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
