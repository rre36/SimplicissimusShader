#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"

varying vec2 coord;

varying vec4 tint;

#include "/lib/shadowmap.glsl"

uniform vec3 cameraPosition;

uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

#define wind_effects

#ifdef wind_effects
	attribute vec4 mc_Entity;
	attribute vec4 mc_midTexCoord;
	uniform float frameTimeCounter;

	vec3 get_wind(vec3 pos) {
		vec3 w 	= pos*vec3(1.0, 0.3, 0.1);
		float tick = frameTimeCounter*pi;

		float m = sin(tick+(pos.x+pos.y+pos.z)*0.5)*0.4+0.6;

		float a 	= sin(tick*1.2+(w.x+w.y+w.z)*1.5)*0.4-0.35;
		float b 	= sin(tick*1.3+(w.x+w.y+w.z)*2.5)*0.2;
		float c 	= sin(tick*1.35+(w.x+w.y+w.z)*2.0)*0.1;

		vec3 w0 	= vec3(a, b, c)*m*0.2;

		float m1 	= sin(tick*1.3+(pos.x+pos.y+pos.z)*0.9)*0.3+0.7;

		float a1	= sin(tick*2.4+(w.x+w.y+w.z)*7.5)*0.4-0.3;
		float b1	= sin(tick*1.8+(w.x+w.y+w.z)*5.5)*0.2;
		float c1	= sin(tick*2.2+(w.x+w.y+w.z)*9.0)*0.1;

		vec3 w1 	= vec3(a1, b1, c1)*m1*0.1;
		return w0+w1;
	}
#endif

void main() {
    vec4 position   = gl_Vertex;
        position    = gl_ModelViewMatrix*position;

    #ifdef wind_effects
		position.xyz = viewMAD(shadowModelViewInverse, position.xyz);

		bool windLod    = length(position.xz) < 64.0;

		if (windLod) {
			position.xyz += cameraPosition.xyz;

			bool top_vertex 	= gl_MultiTexCoord0.t < mc_midTexCoord.t;
			if ((mc_Entity.x == 6.0 ||
			mc_Entity.x == 31.0 ||
			mc_Entity.x == 38.0 ||
			mc_Entity.x == 59.0 ||
			mc_Entity.x == 141.0 ||
			mc_Entity.x == 142.0 ||
			mc_Entity.x == 600.0 )
			&& top_vertex) position.xyz += get_wind(position.xyz);

			if (mc_Entity.x == 240.0 && top_vertex) position.xyz += get_wind(position.xyz)*0.5;
			if (mc_Entity.x == 241.0) position.xyz += get_wind(position.xyz)*(float(top_vertex)*0.5+0.5);

			if (mc_Entity.x == 18.0 ||
			mc_Entity.x == 161.0) position.xyz += get_wind(position.xyz)*0.2;
			
			position.xyz -= cameraPosition.xyz;
		}

		position.xyz = viewMAD(shadowModelView, position.xyz);
    #endif

	position = gl_ProjectionMatrix * position;

    //position        = gl_ProjectionMatrix*gl_ModelViewMatrix*position;

    warpShadowmap(position.xy);
    position.z     *= 0.2;

    gl_Position     = position;

    coord           = (gl_TextureMatrix[0]*gl_MultiTexCoord0).xy;
    tint           = gl_Color;
}