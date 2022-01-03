
/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/math.glsl"

#include "/settings.glsl"

const int shadowMapResolution   = 2560; 	//[512 1024 1536 2048 2560 3072 3584 4096 6144 8192]

#ifdef translucency
varying float water;
#endif

varying float noDiffuse;

varying vec2 coord;
varying vec2 lmap;

varying vec3 normal;

varying vec3 vpos;
varying vec3 wpos;
varying vec3 spos;
varying vec3 cpos;
varying vec3 svec;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;
varying vec3 fogcol;

#if (defined labpbr_enabled || defined normalmap_enabled)
    varying mat3x3 tbn;

    attribute vec4 at_tangent;
#endif

varying vec4 tint;

uniform int frameCounter;

uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;

uniform vec2 taaOffset;

uniform vec3 shadowLightPosition;
uniform vec3 fogColor;
uniform vec3 sunPosition;
uniform vec3 lightvec;

uniform vec3 cameraPosition;

uniform vec4 daytime;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

#include "/lib/shadowmap.glsl"

#define wind_effects

#ifdef terrain
attribute vec4 mc_Entity;
#ifdef wind_effects
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
#endif

vec3 getShadowCoordinate(vec3 vpos, float bias) {
	vec3 position 	= vpos;
		position 	= transMAD(gbufferModelViewInverse, position);
		position   += vec3(bias)*lightvec;
		position 	= transMAD(shadowModelView, position);
		position 	= projMAD3(shadowProjection, position);
		position.z -= 0.0007;

		position.z *= 0.2;
		warpShadowmap(position.xy);

	return position*0.5+0.5;
}

#include "/lib/time.glsl"

void main() {
	//essential vertex setup
	tint 	= gl_Color;
	tint.rgb = pow(tint.rgb, vec3(2.2));
	coord 	= (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;	
	lmap 	= (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	
	vec4 position 	= gl_Vertex;
		position 	= transMAD(gl_ModelViewMatrix, position.xyz).xyzz;
    	vpos 		= position.xyz;

    	position.xyz = transMAD(gbufferModelViewInverse, position.xyz);
		cpos 		= position.xyz;
		wpos = position.xyz + cameraPosition;

	#ifdef terrain
		#ifdef wind_effects
			bool top_vertex 	= gl_MultiTexCoord0.t < mc_midTexCoord.t;
			if ((mc_Entity.x == 6.0 ||
			mc_Entity.x == 31.0 ||
			mc_Entity.x == 38.0 ||
			mc_Entity.x == 59.0 ||
			mc_Entity.x == 141.0 ||
			mc_Entity.x == 142.0 ||
			mc_Entity.x == 600.0 )
			&& top_vertex) position.xyz += get_wind(wpos);

			if (mc_Entity.x == 240.0 && top_vertex) position.xyz += get_wind(wpos)*0.5;
			if (mc_Entity.x == 241.0) position.xyz += get_wind(wpos)*(float(top_vertex)*0.5+0.5);

			if (mc_Entity.x == 18.0 ||
			mc_Entity.x == 161.0) position.xyz += get_wind(wpos)*0.2;
		#endif

        #ifdef translucency
            water   = float(mc_Entity.x == 8 || mc_Entity.x == 9);
        #endif
	#endif

		position.xyz = transMAD(gbufferModelView, position.xyz);

		position     = position.xyzz * diagonal4(gl_ProjectionMatrix) + vec4(0.0, 0.0, gl_ProjectionMatrix[3].z, 0.0);

	#ifdef taa_enabled
		position.xy += taaOffset*position.w;
	#endif

	gl_Position = position;

	normal 	= mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix*gl_Normal);

    #if (defined labpbr_enabled || defined normalmap_enabled)
        vec3 tangent = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix*at_tangent.xyz);
        vec3 binormal = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix*cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);

        tbn     = mat3(tangent.x, binormal.x, normal.x,
                    tangent.y, binormal.y, normal.y,
                    tangent.z, binormal.z, normal.z);
    #endif

	svec 	= normalize(sunPosition);

	spos 	= getShadowCoordinate(vpos, 0.08 * (2048.0 / shadowMapResolution));

	get_daytime();

	//colors
	vec3 sunlightSunrise 	= vec3(1.0, 0.33, 0.03);
	vec3 sunlightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 sunlightSunset 	= vec3(1.0, 0.3, 0.02);
	vec3 sunlightNight 		= vec3(0.3, 0.4, 1.0)*0.15;

    sunlightColor = daytime.x*sunlightSunrise + daytime.y*sunlightNoon + daytime.z*sunlightSunset + daytime.w*sunlightNight;
    sunlightColor = colorSaturation(sunlightColor * (1.0 - rainStrength * 0.9), 1.0 - rainStrength * 0.9);
	sunlightColor *= 1.5 * sunlight_luma;

	vec3 skylightSunrise 	= vec3(0.5, 0.75, 1.0)*0.6;
	vec3 skylightNoon 		= vec3(1.0, 1.0, 1.0);
	vec3 skylightSunset 	= vec3(0.5, 0.75, 1.0)*0.6;
	vec3 skylightNight 		= vec3(0.25, 0.3, 1.0)*0.2;

    skylightColor = daytime.x*skylightSunrise + daytime.y*skylightNoon + daytime.z*skylightSunset + daytime.w*skylightNight;
    skylightColor = colorSaturation(skylightColor, 1.0 - rainStrength * 0.9);
	skylightColor *= 0.15 * skylight_luma;

	vec3 fsunrise 	= vec3(1.0, 0.6, 0.5) * (2.0 - rainStrength);
	vec3 fnoon 		= pow(fogColor, vec3(2.2)) * 2.0;
	vec3 fsunset 	= vec3(0.9, 0.6, 0.8) * 1.3;
	vec3 fnight 	= vec3(0.25, 0.3, 1.0)*0.1;

	fogcol 		= fsunrise*daytime.x + fnoon*daytime.y + fsunset*daytime.z + fnight*daytime.w;
    fogcol      = colorSaturation(fogcol, 1.0 - rainStrength * 0.9);

	torchlightColor = vec3(1.0, 0.9, 0.8);

    #ifdef terrain
	if (mc_Entity.x == 6.0 ||
		mc_Entity.x == 31.0 ||
		mc_Entity.x == 38.0 ||
		mc_Entity.x == 59.0 ||
		mc_Entity.x == 83.0 ||
		mc_Entity.x == 141.0 ||
		mc_Entity.x == 142.0 ||
		mc_Entity.x == 175.0 ||
		mc_Entity.x == 207.0 ||
		mc_Entity.x == 240.0 ||
		mc_Entity.x == 241.0 ||
		mc_Entity.x == 600.0 ||
		mc_Entity.x == 601.0) {
			noDiffuse = 0.8;
		} else {
        	noDiffuse = 0.0;
        }
    #else
        noDiffuse = 0.0;
    #endif
}