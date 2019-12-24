#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"

#include "/settings.glsl"

//#define cloud_twolayer

varying vec4 tint;
varying vec2 coord;

varying vec3 vpos;
varying vec3 cpos;
varying vec3 normal;

varying vec3 svec;
varying vec3 mvec;
varying vec3 uvec;

varying vec3 skycol;
varying vec3 suncol;
varying vec3 fogcol;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec2 taaOffset;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;

uniform vec4 daytime;

uniform int instanceId;

#ifdef cloud_twolayer
const int countInstances = 2;
#endif

#include "lib/time.glsl"

void main() {
	vec4 position 	= gl_Vertex;
	
	if (instanceId > 0) position.y += 60.0 * instanceId;

		position 	= viewMAD(gl_ModelViewMatrix, position.xyz).xyzz;
    	vpos 		= position.xyz;
    	position.xyz = viewMAD(gbufferModelViewInverse, position.xyz);
		cpos 		= position.xyz;

		position.xyz = viewMAD(gbufferModelView, position.xyz);

		position     = position.xyzz * diag4(gl_ProjectionMatrix) + vec4(0.0, 0.0, gl_ProjectionMatrix[3].z, 0.0);

	#ifdef taa_enabled
		position.xy += taaOffset*position.w;
	#endif

	gl_Position = position;

	tint 	= gl_Color;
	if (instanceId > 0) tint.a *= 0.5 /float(instanceId);

	coord 	= (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	if (instanceId == 1) coord = coord.yx;
	if (instanceId == 2) coord = vec2(-coord.x, coord.y);

	normal 	= normalize(gl_NormalMatrix*gl_Normal);

	svec 		= normalize(sunPosition);
	mvec 		= normalize(moonPosition);
	uvec 		= normalize(upPosition);

	get_daytime();

	skycol 		= pow(skyColor, vec3(2.2));

	vec3 fsunrise 	= vec3(1.0, 0.6, 0.5)*2.0;
	vec3 fnoon 		= pow(fogColor, vec3(2.2))*2.5;
	vec3 fsunset 	= vec3(0.9, 0.6, 0.8);
	vec3 fnight 	= vec3(0.25, 0.3, 1.0)*0.1;

	fogcol 		= fsunrise*daytime.x + fnoon*daytime.y + fsunset*daytime.z + fnight*daytime.w;

	vec3 sunlightSunrise 	= vec3(1.0, 0.13, 0.03);
	vec3 sunlightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 sunlightSunset 	= vec3(1.0, 0.1, 0.02);
	vec3 sunlightNight 		= vec3(1.0, 0.05, 0.01)*0.2;

    suncol = daytime.x*sunlightSunrise + daytime.y*sunlightNoon + daytime.z*sunlightSunset + daytime.w*sunlightNight;
	suncol *= 1.5;
}