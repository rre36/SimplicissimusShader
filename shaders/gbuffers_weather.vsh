#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



varying vec4 color;
varying vec2 texcoord;
varying vec2 lmcoord;

void main() {
	gl_Position = ftransform();
	
	color = gl_Color;
	
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}