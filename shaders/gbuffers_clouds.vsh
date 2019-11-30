#version 120
#include "/lib/math.glsl"

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

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform vec3 skyColor;
uniform vec3 fogColor;

uniform int instanceId;

#ifdef cloud_twolayer
const int countInstances = 2;
#endif

#include "lib/time.glsl"

vec4 position;

void repackPos() {
    position = gl_ProjectionMatrix * (gbufferModelView * position);
}

#include "/lib/taaJitter.glsl"

void main() {
	position 	= gl_Vertex;
	
	if (instanceId > 0) position.y += 60.0 * instanceId;

	position 	= (gl_ModelViewMatrix*position);
    vpos 		= position.xyz;
    position 	= gbufferModelViewInverse*position;

	cpos 		= position.xyz;
	repackPos();
	position.xy = taaJitter(position.xy, position.w);
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
}