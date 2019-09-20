#include "/lib/math.glsl"
#include "/lib/common.glsl"

uniform sampler2D tex;
uniform sampler2D lightmap;

varying flat int noDiffuse;

varying flat float timeLightTransition;

varying vec2 coord;
varying vec2 lmap;

varying flat vec3 normal;
varying vec3 vpos;
varying vec3 wpos;
varying vec3 spos;
varying flat vec3 lvec;

varying flat vec3 sunlightColor;
varying flat vec3 skylightColor;
varying flat vec3 torchlightColor;

varying vec4 tint;

const bool shadowHardwareFiltering = true;
uniform sampler2DShadow shadowtex0;
uniform sampler2DShadow shadowtex1;
uniform sampler2DShadow shadowcolor0;

float getShadow(sampler2DShadow shadowtex, in vec3 shadowpos) {
	float shadow 	= shadow2D(shadowtex, shadowpos).x;

	return shadow;
}

float getDiffuse(vec3 normal, vec3 lightvec) {
	float lambert 	= dot(normal, lightvec);
		lambert 	= max(lambert, float(noDiffuse));
	return lambert;
}

#include "/lib/fog.glsl"

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

	vec3 lighting 	= sunlight*finv(timeLightTransition) + skylightColor*lmap.y;
		lighting 	= max(lighting, lmapcol)*torchlightColor;

	scenecol.rgb   *= lighting;

    #ifndef translucency
    float ao        = pow2(tint.a);
    scenecol.rgb   *= ao;
    #endif

    scenecol.rgb    = applyFog(scenecol.rgb);

	scenecol.rgb 	= compressHDR(scenecol.rgb);

	/*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}