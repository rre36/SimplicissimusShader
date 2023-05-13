#version 120
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

#define fogStart 0.2 	//[0.0 0.2 0.4 0.6 0.8]
#define fogIntensity 1.0 //[0 0.2 0.4 0.6 0.8 1.0]

uniform sampler2D colortex0;    //scene color
uniform sampler2D colortex2;
uniform sampler2D colortex3;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform int isEyeInWater;

uniform ivec2 eyeBrightnessSmooth;

uniform float far;

uniform vec2 taaOffset;

uniform vec3 fogColor;
uniform vec3 sunvecView;

uniform vec4 daytime;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

varying float timeMoon;

varying vec2 coord;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;
varying vec3 fogcol;
varying vec3 skycol;

#include "/lib/transforms.glsl"

vec3 getFog(vec3 color, vec3 scenepos, vec3 viewpos, float cave){
	vec3 nfrag  = -normalize(viewpos);
	vec3 sgvec  = normalize(sunvecView+nfrag);

    float UpDot = normalize(scenepos).y;

    float upAlpha = mix(exp(-UpDot * 2.71), 1.0 - sstep(UpDot, 0.0, 0.16), 0.71);

	float sgrad = 1.0-dot(sgvec, nfrag);
	float sglow = linStep(sgrad, 0.1, 0.99);
        sglow   = pow6(sglow);
		sglow  *= daytime.x+daytime.z;

    float hgrad = exp(-abs(UpDot) * 0.6);

    float shglow = linStep(sgrad, 0.0, 0.99);
        shglow  = pow3(shglow)*(hgrad)*finv(daytime.y*0.8) * finv(timeMoon);

	float dist 	= length(scenepos)/far;
		dist 	= max((dist-fogStart)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist);
        alpha = mix(alpha, 1.0, pow3(linStep(dist, 0.25, 1.0)));

	color 	= mix(color, mix(skycol * 0.8, fogcol, hgrad * 0.8)*pow3(finv(shglow)) + sunlightColor*sglow + sunlightColor * shglow * 6.0, saturate(pow2(alpha))*fogIntensity * upAlpha);

	return color;
}

vec3 getWaterFog(vec3 color, vec3 scenepos, float cave){
	float dist 	= length(scenepos)/far;
		dist 	= max((dist)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist * pi * 10.0);

    float skylightLum = mix(0.01, vec3avg(skylightColor), cave);

    vec3 fogcol = isEyeInWater == 1 ? normalize(pow(fogColor, vec3(2.0)) + 1e-8) * skylightLum : skylightColor * vec3(0.05, 0.1, 0.9) * 0.35 * cave;


	color 	= mix(color, fogcol, saturate((alpha)));

	return color;
}

vec3 getLavaFog(vec3 color, vec3 scenepos){
	float dist 	= length(scenepos);
	float alpha = 1.0-exp(-dist);

	color 	= mix(color, vec3(1.0, 0.15, 0.01), saturate((alpha)));

	return color;
}

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);

    vec4 tex2           = texture2D(colortex2, coord);

    float matID         = tex2.x;

    float scenedepth0   = texture2D(depthtex0, coord).x;
    float scenedepth1   = texture2D(depthtex1, coord).x;

    float caveMult  = linStep(eyeBrightnessSmooth.y/240.0, 0.1, 0.9);

    vec3 viewpos0       = screenSpaceToViewSpace(vec3(coord, scenedepth0), gbufferProjectionInverse);
    vec3 scenepos0      = viewSpaceToSceneSpace(viewpos0, gbufferModelViewInverse);

    if (scenedepth0 != 1.0 && matID > 0.01) {

        vec3 viewpos1       = screenSpaceToViewSpace(vec3(coord, scenedepth1), gbufferProjectionInverse);
        vec3 scenepos1      = viewSpaceToSceneSpace(viewpos1, gbufferModelViewInverse);

        bool translucent  = scenedepth0 < scenedepth1;

        if (translucent) {
            vec4 translucents   = texture2D(colortex3, coord);
                translucents.rgb = decompressHDR(translucents.rgb);

                if (tex2.g > 0.5 && isEyeInWater == 0) scenecol.rgb = getWaterFog(scenecol.rgb, (scenepos1 - scenepos0), caveMult);
                else if (scenedepth1 != 1.0) scenecol.rgb    = getFog(scenecol.rgb, (scenepos1 - scenepos0), viewpos1, caveMult);

                scenecol.rgb    = scenecol.rgb * (1.0 - translucents.a) + translucents.rgb;

                scenecol.rgb    = getFog(scenecol.rgb, scenepos0, viewpos0, caveMult);
        } else {
            scenecol.rgb    = getFog(scenecol.rgb, scenepos0, viewpos0, caveMult);
        }
    }

    if (isEyeInWater == 1) scenecol.rgb = getWaterFog(scenecol.rgb, scenepos0, caveMult);
    if (isEyeInWater == 2) scenecol.rgb = getLavaFog(scenecol.rgb, scenepos0);

        scenecol 	    = compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
    gl_FragData[0]  = vec4(scenecol, 1.0);
}