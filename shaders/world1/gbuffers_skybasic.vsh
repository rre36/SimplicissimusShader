#version 120
/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/math.glsl"

varying vec4 tint;

vec4 position;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void repackPos() {
    position = gl_ProjectionMatrix * (gbufferModelView * position);
}

void main() {
	position 	= (gl_ModelViewMatrix*gl_Vertex);
    position 	= gbufferModelViewInverse*position;
	repackPos();
	gl_Position = position;
	tint = gl_Color;
}