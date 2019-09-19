#include "/lib/math.glsl"

uniform sampler2D tex;
uniform sampler2D lightmap;

varying flat int noDiffuse;

varying vec2 coord;
varying vec2 lmap;

varying vec3 normal;
varying vec3 vpos;
varying vec3 wpos;
varying vec3 spos;
varying vec3 lvec;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;

varying vec4 tint;

const bool shadowHardwareFiltering = true;
uniform sampler2DShadow shadowtex1; 	//shadowdepth

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
		scenecol.rgb = pow(scenecol.rgb, vec3(2.2));

	float diffuse 	= getDiffuse(normal, lvec);
	float shadow  	= 1.0;

	if (diffuse>0.0) {
		shadow 	= getShadow(shadowtex1, spos);
	}

	shadow 		= min(shadow, diffuse);

	vec3 lmapcol 	= texture2D(lightmap, vec2(lmap.x, 0.0)).rgb;

	vec3 lighting 	= sunlightColor*shadow + skylightColor*lmap.y + lmapcol;

	scenecol.rgb   *= lighting;

    #ifndef translucency
    float ao        = pow2(tint.a);
    scenecol.rgb   *= ao;
    #endif

    scenecol.rgb    = applyFog(scenecol.rgb);


	/*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}