#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/common.glsl"
#include "/lib/math.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;

void main() {
	vec4 scenecol 	= texture2D(texture, texcoord) * texture2D(lightmap, lmcoord) * color;
	scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));
    scenecol.rgb    = colorSaturation(scenecol.rgb, 0.5);
	scenecol.rgb 	= compressHDR(scenecol.rgb);

	/*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}