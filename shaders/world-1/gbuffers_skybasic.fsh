#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/math.glsl"
#include "/lib/common.glsl"

varying vec4 tint;

void main() {
    vec4 scenecol       = vec4(vec3(1.0, 0.14, 0.06) * 0.3, 1.0);

	scenecol.rgb 	= compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}