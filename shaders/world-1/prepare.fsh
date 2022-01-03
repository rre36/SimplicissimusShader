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
#include "/settings.glsl"

uniform vec3 fogColor;

void main() {

    /*DRAWBUFFERS:0*/
    gl_FragData[0]  = vec4(compressHDR(pow(fogColor, vec3(2.2)) * 0.66), 1.0);
}