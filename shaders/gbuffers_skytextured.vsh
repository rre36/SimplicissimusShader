#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



varying vec4 color;
varying vec4 texcoord;

uniform vec4 daytime;

void main() {
	gl_Position = ftransform();
	
	color = gl_Color;
	color.rgb 	= pow(color.rgb, vec3(2.2));
	color.rgb *= 1.0 + daytime.y * 2.5;
	
	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	gl_FogFragCoord = gl_Position.z;
}