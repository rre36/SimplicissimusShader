/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/math.glsl"

#include "/settings.glsl"

varying vec2 coord;
varying vec2 lmap;

varying vec3 normal;

varying vec3 vpos;
varying vec3 wpos;
varying vec3 cpos;

varying vec3 torchlightColor;

varying vec4 tint;

attribute vec4 mc_Entity;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

uniform vec2 taaOffset;

uniform vec3 shadowLightPosition;
uniform vec3 fogColor;
uniform vec3 sunPosition;

vec4 position;

#include "/lib/terrain/transform.glsl"

void main() {
	//essential vertex setup
	tint 	= gl_Color;
	coord 	= (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;	
	lmap 	= (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	position 	= (gl_ModelViewMatrix*gl_Vertex);
    vpos 		= position.xyz;

    position 	= gbufferModelViewInverse*position;
	cpos 		= position.xyz;
    position.xyz += cameraPosition.xyz;
	wpos = position.xyz;

	repackPos();

	#ifdef taa_enabled
		position.xy += taaOffset*position.w;
	#endif

	gl_Position = position;

	normal 	= normalize(gl_NormalMatrix*gl_Normal);

	torchlightColor = vec3(1.0, 0.9, 0.8);
}