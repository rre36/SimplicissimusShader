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

//#define promoOutline_enabled

/*
const int colortex0Format   = RGB16;
const int colortex1Format   = RGB16;
const int colortex2Format   = RGB16;
*/

uniform sampler2D colortex0;
uniform sampler2D depthtex1;

const float shadowDistance      = 128.0;
const float sunPathRotation 	= -5.0; 	//[25.0 20.0 15.0 10.0 5.0 0.0 -5.0 -10.0 -15.0 -20.0 -25.0]

varying vec2 coord;

#ifdef promoOutline_enabled
uniform float aspectRatio;
uniform float far, near;

float depth_lin(float depth) {
    return (2.0*near) / (far+near-depth * (far-near));
}

/* ------ promo-outline effect from CaptTatsu's BSL shaders ------ */

vec2 promooutlineoffset[4] = vec2[4](vec2(-1.0,1.0),vec2(0.0,1.0),vec2(1.0,1.0),vec2(1.0,0.0));

float promooutline(sampler2D depth){
	float ph = 1.0/1080.0;
	float pw = ph/aspectRatio;

	float outlinec = 1.0;
	float z = depth_lin(texture2D(depth,coord.xy).r)*far;
	float totalz = 0.0;
	float maxz = 0.0;
	float sampleza = 0.0;
	float samplezb = 0.0;

	for (int i = 0; i < 4; i++){
		sampleza = depth_lin(texture2D(depth,coord.xy+vec2(pw,ph)*promooutlineoffset[i]).r)*far;
		maxz = max(sampleza,maxz);

		samplezb = depth_lin(texture2D(depth,coord.xy-vec2(pw,ph)*promooutlineoffset[i]).r)*far;
		maxz = max(samplezb,maxz);

		outlinec*= clamp(1.0-((sampleza+samplezb)-z*2.0)*32.0/z,0.0,1.0);

		totalz += sampleza+samplezb;
	}
	float outlinea = 1.0-clamp((z*8.0-totalz)*64.0-0.08*z,0.0,1.0)*(clamp(1.0-(z*8.0-totalz)*16.0/z,0.0,1.0));
	float outlineb = clamp(1.0+32.0*(z-maxz)/z,0.0,1.0);
	float outline = (0.25*(outlinea*outlineb)+0.75)*(0.75*(1.0-outlinec)*outlineb+1.0);
	return outline;
}
#endif

void main() {
	vec3 scenecolor 	= texture2D(colortex0, coord).rgb;
    #ifdef promoOutline_enabled
		scenecolor 		= decompressHDR(scenecolor.rgb);
		scenecolor 	    = pow(scenecolor, vec3(0.25));
		scenecolor 	   *= max(promooutline(depthtex1), 0.95);
		scenecolor 		= pow(scenecolor, vec3(4.0));
		scenecolor 	    = compressHDR(scenecolor.rgb);
    #endif
    
	/*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(scenecolor, 1.0);
}
