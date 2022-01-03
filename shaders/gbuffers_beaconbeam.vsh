#version 120
/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/settings.glsl"

varying vec2 coord;
varying vec2 lmap;

varying vec4 tint;

vec4 position;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

uniform vec2 taaOffset;

void main() {
	tint 	= gl_Color;
	coord 	= (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;	
	lmap 	= (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    position 	= gl_ProjectionMatrix*(gl_ModelViewMatrix*gl_Vertex);

	#ifdef taa_enabled
		position.xy += taaOffset*position.w;
	#endif

	gl_Position = position;
}