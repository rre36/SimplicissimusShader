#include "/lib/math.glsl"
#include "/lib/common.glsl"

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
varying vec3 lvec;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;
varying vec3 fogcol;

varying vec4 tint;

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
	float sglow = linStep(sgrad, 0.1, 0.99);
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
uniform mat4 gbufferModelViewInverse;
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

void main() {
	vec4 scenecol 	= texture2D(tex, coord)*vec4(tint.rgb, 1.0);

	#ifndef translucency
		if(scenecol.a < 0.1) discard;
	#endif

		scenecol.rgb = pow(scenecol.rgb, vec3(2.2));

    #ifdef isParticle
    float diffuse   = 1.0;
    #else
	float diffuse 	= getDiffuse(normal, lvec);
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

    vec3 sunlight   = sunlightColor*shadow*shadowcol;

	vec3 lighting 	= sunlight*finv(timeLightTransition) + skylightColor*pow5(lmap.y);
		lighting 	= max(lighting, lmapcol*torchlightColor);

	scenecol.rgb   *= lighting;

    #ifndef translucency
    float ao        = pow2(tint.a);
    scenecol.rgb   *= ao;
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