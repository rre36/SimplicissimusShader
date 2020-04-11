#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/common.glsl"

const float bloomIntensity  = 0.02;

uniform sampler2D colortex0;    //scene color
uniform sampler2D colortex2;

uniform float viewHeight;
uniform float viewWidth;

varying vec2 coord;

float vec3avg(vec3 x) {
    return (x.x+x.y+x.z)/3.0;
}

vec3 bloomExpand(vec3 x) {
    return x * x * x * x * 16.0;
}
vec3 bloom() {
    vec3 blur1 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,2.0) + vec2(0.0,0.0)).rgb);
    vec3 blur2 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,3.0) + vec2(0.3,0.0)).rgb)*0.95;
    vec3 blur3 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,4.0) + vec2(0.0,0.3)).rgb)*0.9;
    vec3 blur4 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,5.0) + vec2(0.1,0.3)).rgb)*0.85;
    vec3 blur5 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,6.0) + vec2(0.2,0.3)).rgb)*0.8;
    vec3 blur6 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,7.0) + vec2(0.3,0.3)).rgb)*0.75;
    vec3 blur7 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,8.0) + vec2(0.4,0.3)).rgb)*0.7;
	
    vec3 blur = (blur1 + blur2 + blur3 + blur4 + blur5 + blur6 + blur7);
    float blurLuma = vec3avg(blur);
    blur *= blurLuma*blurLuma;

    return blur/7.0;
}

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);

        scenecol += bloom()*bloomIntensity;

        scenecol 	    = compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
    gl_FragData[0]  = vec4(scenecol, 1.0);
}