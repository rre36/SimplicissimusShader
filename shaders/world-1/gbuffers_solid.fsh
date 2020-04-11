/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/math.glsl"
#include "/lib/common.glsl"

uniform sampler2D tex;
uniform sampler2D lightmap;

varying vec2 coord;
varying vec2 lmap;

varying vec3 normal;
varying vec3 vpos;
varying vec3 wpos;
varying vec3 cpos;

varying vec3 torchlightColor;

varying vec4 tint;

uniform float far;

void main() {
	vec4 scenecol 	= texture2D(tex, coord)*vec4(tint.rgb, 1.0);

	#ifndef translucency
		if(scenecol.a < 0.1) discard;
	#endif

		scenecol.rgb = pow(scenecol.rgb, vec3(2.2));

	vec3 lmapcol 	= texture2D(lightmap, vec2(lmap.x, 0.0)).rgb;
		lmapcol 	= pow(lmapcol, vec3(2.2)) * vec3(1.2, 0.8, 0.6);
	vec3 lmaps 		= texture2D(lightmap, vec2(0.0, lmap.y)).rgb;
		lmaps 		= pow(lmapcol, vec3(2.2));

	vec3 lighting 	= lmaps;
		lighting 	= max(lighting, lmapcol*torchlightColor);

	scenecol.rgb   *= lighting;

    #ifndef translucency
    float ao        = pow2(tint.a);
    scenecol.rgb   *= ao;
    #endif

	scenecol.rgb 	= compressHDR(scenecol.rgb);

	#ifdef isHand
		vec4 ret1 	= vec4(1.0, 0.0, 0.0, 1.0);
	#else
		vec4 ret1 	= vec4(0.0, 0.0, 0.0, 1.0);
	#endif

	/*DRAWBUFFERS:02*/
	gl_FragData[0] = scenecol;
	gl_FragData[1] = ret1;
}