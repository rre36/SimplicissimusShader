#version 120
/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"
#include "/lib/common.glsl"

varying vec2 coord;
varying vec2 lmap;

varying vec4 tint;

uniform sampler2D tex;
uniform sampler2D lightmap;

void main() {
    vec4 scenecol 	= texture2D(tex, coord)*tint;

    scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));

    scenecol.rgb   *= 3.0;

    scenecol.rgb 	= compressHDR(scenecol.rgb);

    vec4 ret1 	= vec4(0.0, 0.0, 0.0, 1.0);

	/*DRAWBUFFERS:02*/
	gl_FragData[0] = scenecol;
	gl_FragData[1] = ret1;
}