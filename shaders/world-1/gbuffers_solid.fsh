#include "/lib/math.glsl"
#include "/lib/common.glsl"

#define fogStart 0.2 	//[0.0 0.2 0.4 0.6 0.8]
#define fogIntensity 1.0 //[0 0.2 0.4 0.6 0.8 1.0]

uniform sampler2D tex;
uniform sampler2D lightmap;

varying vec2 coord;
varying vec2 lmap;

varying vec3 normal;
varying vec3 vpos;
varying vec3 wpos;
varying vec3 cpos;

varying vec3 torchlightColor;

varying vec4 tint;

uniform float far;

vec3 getFog(vec3 color){
	float dist 	= length(cpos)/far;
		dist 	= max((dist-fogStart)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist);

	color 	= mix(color, vec3(1.0, 0.14, 0.06)*0.3, saturate(pow2(alpha))*fogIntensity);

	return color;
}

void main() {
	vec4 scenecol 	= texture2D(tex, coord)*vec4(tint.rgb, 1.0);

	#ifndef translucency
		if(scenecol.a < 0.1) discard;
	#endif

		scenecol.rgb = pow(scenecol.rgb, vec3(2.2));

	vec3 lmapcol 	= texture2D(lightmap, vec2(lmap.x, 0.0)).rgb;
		lmapcol 	= pow(lmapcol, vec3(2.2));
	vec3 lmaps 		= texture2D(lightmap, vec2(0.0, lmap.x)).rgb;
		lmaps 		= pow(lmapcol, vec3(2.2));

	vec3 lighting 	= lmaps;
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