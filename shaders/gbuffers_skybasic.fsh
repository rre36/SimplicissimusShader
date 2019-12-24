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

varying float star;

varying float timeMoon;

varying vec4 tint;

varying vec3 vpos;
varying vec3 wpos;

varying vec3 svec;
varying vec3 mvec;
varying vec3 uvec;

varying vec3 skycol;
varying vec3 suncol;
varying vec3 fogcol;

uniform vec4 daytime;

uniform sampler2D gaux1;

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

    vec3 sky    = skycol * 0.75;
        sky     = mix(sky, fogcol, hfade*0.75);
        sky     = mix(sky, fogcol, horizon*0.8);
        sky    *= pow3(1.0-saturate(shglow));
        sky    += suncol*shglow*6.0;
        sky    += suncol*sglow;
        sky    += float(star)*daytime.w*pow4(finv(max(hfade, horizon)));

    return sky;
}

#ifdef s_secondCloudLayer
uniform float frameTimeCounter;
uniform float eyeAltitude;

uniform vec3 cameraPosition;

#define cloudAlt 400.0

float getCloud(vec3 pos) {
    const float size    = 0.00008;
    vec2 coord  = -pos.xz*size;
    vec2 anim   = vec2(-frameTimeCounter*size*2.0, 0.0);

    float shape = texture2D(gaux1, coord+anim).a;

    return shape;
}

vec3 clouds(vec3 scenecol) {
    vec3 wvec   = normalize(wpos);

    float cloud = 0.0;

    bool visible = wvec.y>0.0 && eyeAltitude<cloudAlt;

    if (visible) {
        vec3 plane  = wvec*((cloudAlt-eyeAltitude)/wvec.y);
        vec3 coord  = plane+cameraPosition*0.75;
        float fade  = 1.0-lin_step(length(plane.xz), 500.0, 2500.0);
        if (fade>0.0) cloud = getCloud(coord)*fade;

		float vdotl 	= dot(normalize(vpos), svec)*0.5+0.5;
		float phase1 	= pow6(saturate(vdotl))*1.2;
		//float phase2 	= pow3(saturate(-vdotl));
		//float phase 	= mix(phase1, phase2, 0.4)+0.5;

        vec3 color      = suncol*(phase1*0.5+0.25);
            color      += (skycol+fogcol*0.6)*0.15;
            color       = mix(color, vec3(0.45, 0.4, 1.0)*0.02, daytime.w);

        scenecol       *= 1.0-cloud*0.2;
        scenecol       += color*cloud*0.3;
    }

    return scenecol;
}
#endif

void main() {
    vec4 scenecol       = tint;
        scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));
        scenecol.rgb    = getSky();

    #ifdef s_secondCloudLayer
        scenecol.rgb    = clouds(scenecol.rgb);
    #endif

	scenecol.rgb 	= compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}