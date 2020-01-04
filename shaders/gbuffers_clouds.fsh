#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#include "/lib/math.glsl"
#include "/lib/common.glsl"

varying float timeMoon;

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

uniform vec4 daytime;

uniform float far;
uniform sampler2D tex;

vec3 getSky() {
    vec3 nfrag  = -normalize(vpos);
    vec3 hvec0  = normalize(-uvec+nfrag);
    vec3 hvec1  = normalize(uvec+nfrag);
    vec3 sgvec  = normalize(svec+nfrag);
    vec3 mgvec  = normalize(mvec+nfrag);

    float htop  = dot(hvec0, nfrag);
    float hbot  = dot(hvec1, nfrag);

    float hfade = lin_step(hbot, 0.3, 0.8);
        hfade   = pow6(hfade);

    float hgrad = 1.0-max(hbot, htop);

    float horizon = lin_step(hgrad, 0.12, 0.30);
        horizon = pow6(horizon);

    float sgrad = 1.0-dot(sgvec, nfrag);
    float mgrad = 1.0-dot(mgvec, nfrag);

    float sglow = lin_step(sgrad, 0.5, 0.99);
        sglow   = pow6(sglow)*0.5;

    float shglow = lin_step(sgrad, 0.0, 0.99);
        shglow  = pow3(shglow)*(hfade+horizon)*finv(timeMoon)*finv(daytime.y*0.8);

    vec3 sky    = skycol * 0.8;
        sky     = mix(sky, fogcol, hfade*0.75);
        sky     = mix(sky, fogcol, horizon*0.8);
        sky    *= pow3(1.0-saturate(shglow));
        sky    += suncol*shglow*6.0;
        sky    += suncol*sglow;

    return sky;
}

vec3 getFog(vec3 color){
	float dist 	= length(cpos)/far;
		dist 	= max((dist-0.5)*2.0, 0.0);
	float alpha = 1.0-exp2(-dist*2.0);

	color 	= mix(color, getSky(), saturate(pow2(alpha)));

	return color;
}

vec3 cloudShading(vec3 color) {
	if (daytime.w<1.0) {
		float lambert 	= dot(normal, svec);
		float vdotl 	= dot(normalize(vpos), svec)*0.5+0.5;
		float phase1 	= pow6(saturate(vdotl))*1.2;
		float phase2 	= pow3(saturate(-vdotl));
		float phase 	= mix(phase1, phase2, 0.4)+0.5;

		vec3 color0 	= saturate(lambert*0.75+0.25)*suncol*0.5*phase;
		color0  += suncol*(phase1*0.2+0.02);

		float lambertu 	= dot(normal, uvec);

		color0  += (skycol+fogcol*0.6)*(sqrt(saturate(lambertu))*0.85+0.15);

		return mix(color0, color, daytime.w);
	} else {
		return color;
	}
}

void main() {
	vec4 scenecol 	= texture2D(tex, coord)*tint;

    if (scenecol.a < 0.01) discard;

    scenecol.rgb = pow(scenecol.rgb, vec3(2.2))*2.0;
	scenecol.rgb = cloudShading(scenecol.rgb);
	scenecol.rgb = getFog(scenecol.rgb);

	scenecol.rgb 	= compressHDR(scenecol.rgb);

	/*DRAWBUFFERS:0*/
	gl_FragData[0] 	= scenecol;
}