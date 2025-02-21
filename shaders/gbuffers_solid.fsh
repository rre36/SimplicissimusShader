/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"
#include "/lib/common.glsl"
#include "/settings.glsl"

//#define hq_shadows

#ifdef g_entities
uniform int entityId;
    //#define noEntityLab
#endif

const int shadowMapResolution   = 2560; 	//[512 1024 1536 2048 2560 3072 3584 4096 6144 8192]

uniform sampler2D tex;
uniform sampler2D lightmap;

varying float noDiffuse;

varying float timeLightTransition;

#ifdef translucency
varying float water;
#endif

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

varying vec4 tint;

uniform vec4 daytime;

uniform mat4 gbufferModelViewInverse;

#ifdef labpbr_enabled
	uniform sampler2D specular;
#endif

#if (defined labpbr_enabled || defined normalmap_enabled)
	uniform sampler2D normals;

	varying mat3x3 tbn;
#endif

const bool shadowHardwareFiltering = true;
uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform sampler2D shadowcolor0;

uniform float far, screenBrightness;

uniform vec3 lightvec;

#ifdef hq_shadows
	float ditherGradNoise(){
		return fract(52.9829189*fract(0.06711056*gl_FragCoord.x + 0.00583715*gl_FragCoord.y));
	}

	float shadowFilter(sampler2DShadow shadowtex, vec3 pos) {
		const float step = 1.0/shadowMapResolution;
		float noise     = ditherGradNoise()*pi;
		vec2 offset     = vec2(cos(noise), sin(noise))*step;
		float shade     = shadow2D(shadowtex, vec3(pos.xy+offset, pos.z)).x;
			shade      += shadow2D(shadowtex, vec3(pos.xy-offset, pos.z)).x;
			shade      += shadow2D(shadowtex, pos.xyz).x*0.5;
		return shade*0.4;
	}
#endif

float getShadow(sampler2DShadow shadowtex, in vec3 shadowpos) {
	#ifdef hq_shadows
		float shadow 	= shadowFilter(shadowtex, shadowpos);
	#else
		float shadow 	= shadow2D(shadowtex, shadowpos).x;
	#endif

	return shadow;
}

float getDiffuse(vec3 normal, vec3 lightvec) {
	float lambert 	= dot(normal, lightvec);
		lambert 	= max(lambert, max(noDiffuse, 0.0));
	return lambert;
}

//#define pixel_shadows
#define pixel_shadow_res 32 	//[8 16 32 64 128 256]

#ifdef pixel_shadows
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

uniform vec3 cameraPosition;

#include "/lib/shadowmap.glsl"

vec3 getShadowCoordinate() {
		float bias 	= 0.1;
	vec3 position 	= vpos;
		position 	= transMAD(gbufferModelViewInverse, position);
		position 	= floor((position + cameraPosition) * pixel_shadow_res) / pixel_shadow_res - cameraPosition;
		position   += vec3(bias)*lightvec;
		position 	= transMAD(shadowModelView, position);
		position 	= projMAD3(shadowProjection, position);
		position.z -= 0.05 * (1.0 / float(pixel_shadow_res));

		position.z *= 0.2;
		warpShadowmap(position.xy);

	return position*0.5+0.5;
}
#endif


/* ------ labPBR relevant stuff ------ */

#if (defined labpbr_enabled && !defined noEntityLab)
	vec3 decode_lab_nrm(vec3 ntex, inout float ao) {
        if (floor(ntex * 256.0) == vec3(0.0)) return normal;

        if(any(greaterThan(ntex, vec3(0.003)))) ao = sqrt(ntex.z);   //thanks for this fix in ymir niemand

		ntex.xy    = ntex.xy * 2.0 - (254.0 * rcp(255.0));

        ntex.z  = sqrt(saturate(1.0 - dot(ntex.xy, ntex.xy)));

		ntex    = normalize(ntex);

		return normalize(ntex * tbn);
	}
#else
	#ifdef normalmap_enabled
	vec3 decode_nrm(vec3 ntex) {
        if (floor(ntex * 256.0) == vec3(0.0)) return normal;
		ntex    = ntex * 2.0 - (254.0 * rcp(255.0));
        ntex.z  = sqrt(saturate(1.0 - dot(ntex.xy, ntex.xy)));

		ntex    = normalize(ntex);

		return normalize(ntex * tbn);
	}
	#endif
#endif

vec3 decode_lab(vec4 unpacked_tex, out bool is_metal) {
	vec3 mat_data = vec3(1.0, 0.0, 0.0);

    mat_data.x  = pow2(1.0 - unpacked_tex.x);   //roughness
    mat_data.y  = (unpacked_tex.y);         //f0

    unpacked_tex.w = unpacked_tex.w * 255.0;

    mat_data.z  = unpacked_tex.w < 254.5 ? linStep(unpacked_tex.w, 0.0, 254.0) : 0.0; //emission

    is_metal    = (unpacked_tex.y * 255.0) >= 230.0;

	return mat_data;
}

float get_specGGX(vec3 normal, vec3 svec, vec2 material) {
    float f0  = material.y;
    float roughness = pow2(material.x);

    vec3 h      = lightvec - svec;
    float hn    = inversesqrt(dot(h, h));
    float hDotL = saturate(dot(h, lightvec)*hn);
    float hDotN = saturate(dot(h, normal)*hn);
    float nDotL = saturate(dot(normal, lightvec));
    float denom = (hDotN * roughness - hDotN) * hDotN + 1.0;
    float D     = roughness / (pi * denom * denom);
    float F     = f0 + (1.0-f0) * exp2((-5.55473*hDotL-6.98316)*hDotL);
    float k2    = 0.25 * roughness;

    return nDotL * D * F / (hDotL * hDotL * (1.0-k2) + k2);
}

void main() {
	vec4 scenecol 	= texture2D(tex, coord);
	vec3 scenenormal = normal;

	#ifndef translucency
        #ifdef g_entities
        if (scenecol.a<0.1 && entityId != 1001) discard;
        #else
        if (scenecol.a<0.1) discard;
        #endif
	#endif

		scenecol.rgb = pow(scenecol.rgb, vec3(2.3)) * tint.rgb;


	#if (defined labpbr_enabled && !defined noEntityLab)
		//vec4 spectex    = texture(specular, coord);
		//vec2 return1_zw = vec2(encode2x8(spectex.xy), encode2x8(spectex.zw));

		vec3 albedo 	= scenecol.rgb;
		float t_ao 		= 1.0;

		vec4 ntex       = texture2D(normals, coord);

		scenenormal     = decode_lab_nrm(ntex.rgb, t_ao);
	#else
		#ifdef normalmap_enabled
			vec4 ntex       = texture2D(normals, coord);

			scenenormal     = decode_nrm(ntex.rgb);
		#endif

		//const vec2 return1_zw = vec2(1.0);
	#endif

    #ifdef isParticle
    float diffuse   = 1.0;
    #else
	float diffuse 	= getDiffuse(scenenormal, lightvec);
    #endif

	float shadow  	= 1.0;
    vec3 shadowcol  = vec3(1.0);

	#ifdef pixel_shadows
	vec3 spos 		= getShadowCoordinate();
	#endif

	if (diffuse>0.0) {
		shadow 	= getShadow(shadowtex1, spos);
        float s0 = getShadow(shadowtex0, spos);

        if (length(shadow-s0)>0.05) {
            vec4 s  = texture2D(shadowcolor0, spos.xy);
            shadowcol = mix(vec3(1.0), pow(s.rgb, vec3(2.2)), (s.a));
        }
	}

	shadow 		= min(shadow, diffuse);

	vec3 lmapcol 	= texture2D(lightmap, vec2(clamp(lmap.x, 0.5 / 16.0, 15.5 / 16.0), 0.5 / 16.0)).rgb;
		lmapcol 	= pow(lmapcol, vec3(2.2));
        //lmapcol     = saturate(normalize(lmapcol)) * pow5(lmap.x);

    vec3 sunlight   = sunlightColor*shadow*shadowcol*finv(timeLightTransition);

	vec3 lighting 	= max(skylightColor*pow5(lmap.y), vec3(0.5, 0.8, 1.0) * mix(0.003, 0.025, screenBrightness));
		lighting 	= max(lighting, lmapcol*torchlightColor);

	#if (defined labpbr_enabled && !defined noEntityLab)
        lighting *= saturate(t_ao * 0.8 + 0.2);
    #endif

	scenecol.rgb   *= lighting + sunlight;

    #ifndef translucency
    float ao        = pow2(tint.a);
    scenecol.rgb   *= ao;
    #endif

    #ifdef labpbr_enabled
    /* - */
    #endif

    #ifdef noEntityLab
    /* - */
    #endif

	#if (defined labpbr_enabled && !defined noEntityLab)
		vec4 spectex = texture2D(specular, coord);

		bool is_metal = false;

		vec3 mat_data = decode_lab(spectex, is_metal);

        vec3 viewVector = normalize(mat3(gbufferModelViewInverse) * vpos);

		float ggx 	= get_specGGX(scenenormal, viewVector, mat_data.xy);

		if (is_metal) {
			scenecol.rgb *= normalize(albedo * 0.5 + 0.5);
            scenecol.rgb *= mix(pow(saturate(dot(scenenormal, -viewVector)), mix(4.0, 1.0, mat_data.x)), 1.0, 0.12);
			scenecol.rgb += ggx * albedo * sunlight;
		} else {
			scenecol.rgb += ggx * sunlight;
		}
	#endif

	scenecol.rgb 	= compressHDR(scenecol.rgb);

	#ifdef isHand
		vec4 ret1 	= vec4(1.0, 0.0, 0.0, 1.0);
	#else
		vec4 ret1 	= vec4(0.3, 0.0, 0.0, 1.0);
	#endif

    #ifndef translucency
	/*DRAWBUFFERS:02*/
	gl_FragData[0] = scenecol;
	gl_FragData[1] = ret1;
    #else
   	/*DRAWBUFFERS:32*/
	gl_FragData[0] = scenecol;
	gl_FragData[1] = ret1 + vec4(0.0, water, 0.0, 0.0);
    #endif
}