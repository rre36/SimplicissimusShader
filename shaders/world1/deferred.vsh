#version 120
/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



varying vec3 lightVec;

varying vec2 coord;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;

uniform vec3 shadowLightPosition;

void main() {
	gl_Position = ftransform();

	sunlightColor = vec3(1.0, 1.0, 1.0);
	skylightColor = vec3(0.1, 0.1, 0.1);
	torchlightColor = vec3(1.0, 0.3, 0.0);
	
	coord 		= gl_MultiTexCoord0.xy;
	lightVec	= normalize(shadowLightPosition);
}
