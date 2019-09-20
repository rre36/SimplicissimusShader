#version 120
#include "/lib/math.glsl"

varying vec4 tint;

varying vec3 vpos;

varying flat int star;

varying flat vec3 svec;
varying flat vec3 mvec;
varying flat vec3 uvec;

varying flat vec3 skycol;
varying flat vec3 suncol;
varying flat vec3 fogcol;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

#include "lib/time.glsl"

vec4 position;

void repackPos() {
    position = gl_ProjectionMatrix * (gbufferModelView * position);
}

void main() {
	position 	= (gl_ModelViewMatrix*gl_Vertex);
    vpos 		= position.xyz;
    position 	= gbufferModelViewInverse*position;
	repackPos();
	gl_Position = position;
	tint = gl_Color;

	svec 		= normalize(sunPosition);
	mvec 		= normalize(moonPosition);
	uvec 		= normalize(upPosition);

	daytime();

	skycol 		= pow(skyColor, vec3(2.2));

	vec3 fsunrise 	= vec3(1.0, 0.6, 0.5)*2.0;
	vec3 fnoon 		= pow(fogColor, vec3(2.2))*3.0;
	vec3 fsunset 	= vec3(0.9, 0.6, 0.8);
	vec3 fnight 	= vec3(0.25, 0.3, 1.0)*0.1;

	fogcol 		= fsunrise*timeSunrise + fnoon*timeNoon + fsunset*timeSunset + fnight*timeNight;

	vec3 sunlightSunrise 	= vec3(1.0, 0.13, 0.03);
	vec3 sunlightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 sunlightSunset 	= vec3(1.0, 0.1, 0.02);
	vec3 sunlightNight 		= vec3(1.0, 0.05, 0.01)*0.2;

    suncol = timeSunrise*sunlightSunrise + timeNoon*sunlightNoon + timeSunset*sunlightSunset + timeNight*sunlightNight;
	suncol *= 2.0;

	float isStar = float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0);

	star = int(isStar);
}