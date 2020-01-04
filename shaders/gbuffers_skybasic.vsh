#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"

varying vec4 tint;

varying vec3 vpos;
varying vec3 wpos;

varying float star;

varying vec3 svec;
varying vec3 mvec;
varying vec3 uvec;

varying vec3 skycol;
varying vec3 suncol;
varying vec3 fogcol;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;

uniform vec4 daytime;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

#include "lib/time.glsl"

void main() {
	vec4 position 	= gl_Vertex;
		position 	= viewMAD(gl_ModelViewMatrix, position.xyz).xyzz;
    	vpos 		= position.xyz;

    	position.xyz = viewMAD(gbufferModelViewInverse, position.xyz);
		wpos 		= position.xyz;

		position.xyz = viewMAD(gbufferModelView, position.xyz);

		position     = position.xyzz * diag4(gl_ProjectionMatrix) + vec4(0.0, 0.0, gl_ProjectionMatrix[3].z, 0.0);

	gl_Position = position;
	tint = gl_Color;

	svec 		= normalize(sunPosition);
	mvec 		= normalize(moonPosition);
	uvec 		= normalize(upPosition);

	get_daytime();

	skycol 		= pow(skyColor, vec3(2.2));
	skycol 	   *= vec3(0.9, 0.85, 1.0);

	vec3 fsunrise 	= vec3(1.0, 0.6, 0.5) * 2.0;
	vec3 fnoon 		= pow(fogColor, vec3(2.2)) * 2.0;
	vec3 fsunset 	= vec3(0.9, 0.6, 0.8) * 1.3;
	vec3 fnight 	= vec3(0.25, 0.3, 1.0)*0.1;

	fogcol 		= fsunrise*daytime.x + fnoon*daytime.y + fsunset*daytime.z + fnight*daytime.w;

	vec3 sunlightSunrise 	= vec3(1.0, 0.13, 0.03);
	vec3 sunlightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 sunlightSunset 	= vec3(1.0, 0.1, 0.02);
	vec3 sunlightNight 		= vec3(1.0, 0.05, 0.01)*0.2;

    suncol = daytime.x*sunlightSunrise + daytime.y*sunlightNoon + daytime.z*sunlightSunset + daytime.w*sunlightNight;
	suncol *= 1.5;

	float isStar = float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0);

	star = isStar;
}