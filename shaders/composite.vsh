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

varying vec2 coord;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;
varying vec3 fogcol;

uniform vec3 fogColor;

uniform vec4 daytime;

#include "/lib/time.glsl"

void main() {
    gl_Position     = ftransform();
    coord           = gl_MultiTexCoord0.xy;

   	get_daytime();

	//colors
	vec3 sunlightSunrise 	= vec3(1.0, 0.33, 0.03);
	vec3 sunlightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 sunlightSunset 	= vec3(1.0, 0.3, 0.02);
	vec3 sunlightNight 		= vec3(0.3, 0.4, 1.0)*0.15;

    sunlightColor = daytime.x*sunlightSunrise + daytime.y*sunlightNoon + daytime.z*sunlightSunset + daytime.w*sunlightNight;
	sunlightColor *= 1.5 * sunlight_luma;

	vec3 skylightSunrise 	= vec3(0.5, 0.75, 1.0)*0.6;
	vec3 skylightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 skylightSunset 	= vec3(0.5, 0.75, 1.0)*0.6;
	vec3 skylightNight 		= vec3(0.25, 0.3, 1.0)*0.2;

    skylightColor = daytime.x*skylightSunrise + daytime.y*skylightNoon + daytime.z*skylightSunset + daytime.w*skylightNight;
	skylightColor *= 0.15 * skylight_luma;

	vec3 fsunrise 	= vec3(1.0, 0.6, 0.5) * 2.0;
	vec3 fnoon 		= pow(fogColor, vec3(2.2)) * 2.0;
	vec3 fsunset 	= vec3(0.9, 0.6, 0.8) * 1.3;
	vec3 fnight 	= vec3(0.25, 0.3, 1.0)*0.1;

	fogcol 		= fsunrise*daytime.x + fnoon*daytime.y + fsunset*daytime.z + fnight*daytime.w;

	torchlightColor = vec3(1.0, 0.9, 0.8);
}