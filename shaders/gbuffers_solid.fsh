#include "/lib/math.glsl"
#include "/lib/common.glsl"

uniform sampler2D tex;
uniform sampler2D lightmap;

varying flat int noDiffuse;

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

float getShadow(sampler2DShadow shadowtex, in vec3 shadowpos) {
	float shadow 	= shadow2D(shadowtex, shadowpos).x;

	return shadow;
}

float getDiffuse(vec3 normal, vec3 lightvec) {
	float lambert 	= dot(normal, lightvec);
		lambert 	= max(lambert, float(noDiffuse));
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
		dist 	= max((dist-0.2)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist);

	color 	= mix(color, fogcol*finv(sglow)+sunlightColor*sglow*5.0, saturate(pow2(alpha)));

	return color;
}

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

    scenecol.rgb    = getFog(scenecol.rgb);

	scenecol.rgb 	= compressHDR(scenecol.rgb);

	/*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}