/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"
#include "/lib/common.glsl"
#include "/settings.glsl"

//#define hq_shadows

const int shadowMapResolution   = 2560; 	//[512 1024 1536 2048 2560 3072 3584 4096 6144 8192]

#define fogStart 0.2 	//[0.0 0.2 0.4 0.6 0.8]
#define fogIntensity 1.0 //[0 0.2 0.4 0.6 0.8 1.0]

uniform sampler2D tex;
uniform sampler2D lightmap;

varying float noDiffuse;

varying float timeSunrise;
varying float timeSunset;
varying float timeLightTransition;

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
uniform sampler2DShadow shadowcolor0;

uniform float far;

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

vec3 getFog(vec3 color){
	vec3 nfrag  = -normalize(vpos);
	vec3 sgvec  = normalize(svec+nfrag);

	float sgrad = 1.0-dot(sgvec, nfrag);
	float sglow = lin_step(sgrad, 0.1, 0.99);
        sglow   = pow4(sglow);
		sglow  *= timeSunrise+timeSunset;

	float dist 	= length(cpos)/far;
		dist 	= max((dist-fogStart)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist);

	color 	= mix(color, fogcol*finv(sglow)+sunlightColor*sglow*5.0, saturate(pow2(alpha))*fogIntensity);

	return color;
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
		position 	= viewMAD(gbufferModelViewInverse, position);
		position 	= floor((position + cameraPosition) * pixel_shadow_res) / pixel_shadow_res - cameraPosition;
		position   += vec3(bias)*lightvec;
		position 	= viewMAD(shadowModelView, position);
		position 	= projMAD(shadowProjection, position);
		position.z -= 0.0007;

		position.z *= 0.2;
		warpShadowmap(position.xy);

	return position*0.5+0.5;
}
#endif


/* ------ labPBR relevant stuff ------ */

#ifdef labpbr_enabled
	vec3 decode_lab_nrm(vec3 ntex, inout float ao) {
		ntex    = ntex * 2.0 - (254.0 * rcp(255.0));

		ao     *= pow2(length(ntex));

		ntex    = normalize(ntex);

		return normalize(ntex * tbn);
	}
#else
	#ifdef normalmap_enabled
	vec3 decode_nrm(vec3 ntex) {
		ntex    = ntex * 2.0 - (254.0 * rcp(255.0));

		ntex    = normalize(ntex);

		return normalize(ntex * tbn);
	}
	#endif
#endif

vec3 decode_lab(vec4 unpacked_tex, out bool is_metal) {
	vec3 mat_data = vec3(1.0, 0.0, 0.0);

    mat_data.x  = pow2(1.0 - unpacked_tex.x);   //roughness
    mat_data.y  = pow2(unpacked_tex.y);         //f0

    unpacked_tex.w = unpacked_tex.w * 255.0;

    mat_data.z  = unpacked_tex.w < 254.5 ? lin_step(unpacked_tex.w, 0.0, 254.0) : 0.0; //emission

    is_metal    = (unpacked_tex.y * 255.0) > 229.5;

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
	vec4 scenecol 	= texture2D(tex, coord)*vec4(tint.rgb, 1.0);
	vec3 scenenormal = normal;

	#ifndef translucency
		if(scenecol.a < 0.1) discard;
	#endif

		scenecol.rgb = pow(scenecol.rgb, vec3(2.2));


	#ifdef labpbr_enabled
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
            vec4 s  = shadow2D(shadowcolor0, spos);
            shadowcol = mix(vec3(1.0), pow(s.rgb, vec3(2.2)), s.a);
        }
	}

	shadow 		= min(shadow, diffuse);

	vec3 lmapcol 	= texture2D(lightmap, vec2(lmap.x, 0.0)).rgb;
		lmapcol 	= pow(lmapcol, vec3(2.2));

    vec3 sunlight   = sunlightColor*shadow*shadowcol*finv(timeLightTransition);

	vec3 lighting 	= sunlight + skylightColor*pow5(lmap.y);
		lighting 	= max(lighting, lmapcol*torchlightColor);

	scenecol.rgb   *= lighting;

    #ifndef translucency
    float ao        = pow2(tint.a);
    scenecol.rgb   *= ao;
    #endif

	#ifdef labpbr_enabled
		vec4 spectex = texture2D(specular, coord);

		bool is_metal = false;

		vec3 mat_data = decode_lab(spectex, is_metal);

		float ggx 	= get_specGGX(scenenormal, normalize(mat3(gbufferModelViewInverse) * vpos), mat_data.xy);

		scenecol.rgb *= t_ao;

		if (is_metal) {
			scenecol.rgb *= albedo * 0.5 + 0.5;
			scenecol.rgb += ggx * albedo * sunlight;
		} else {
			scenecol.rgb += ggx * sunlight;
		}
	#endif

    scenecol.rgb    = getFog(scenecol.rgb);

	scenecol.rgb 	= compressHDR(scenecol.rgb);

	#ifdef isHand
		vec4 ret1 	= vec4(1.0, 0.0, 0.0, 1.0);
	#else
		vec4 ret1 	= vec4(0.0, 0.0, 0.0, 1.0);
	#endif

	/*DRAWBUFFERS:02*/
	gl_FragData[0] = scenecol;
	gl_FragData[1] = ret1;
}