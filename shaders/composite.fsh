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
#include "/settings.glsl"

#define fogStart 0.2 	//[0.0 0.2 0.4 0.6 0.8]
#define fogIntensity 1.0 //[0 0.2 0.4 0.6 0.8 1.0]

uniform sampler2D colortex0;    //scene color
uniform sampler2D colortex3;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform float far;

uniform vec2 taaOffset;

uniform vec3 sunvecView;

uniform vec4 daytime;

varying vec2 coord;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;
varying vec3 fogcol;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

#include "/lib/transforms.glsl"

vec3 getFog(vec3 color, vec3 scenepos, vec3 viewpos){
	vec3 nfrag  = -normalize(viewpos);
	vec3 sgvec  = normalize(sunvecView+nfrag);

	float sgrad = 1.0-dot(sgvec, nfrag);
	float sglow = lin_step(sgrad, 0.1, 0.99);
        sglow   = pow4(sglow);
		sglow  *= daytime.x+daytime.z;

	float dist 	= length(scenepos)/far;
		dist 	= max((dist-fogStart)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist);

	color 	= mix(color, fogcol*finv(sglow)+sunlightColor*sglow*5.0, saturate(pow2(alpha))*fogIntensity);

	return color;
}

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);

    float scenedepth0   = texture2D(depthtex0, coord).x;
    float scenedepth1   = texture2D(depthtex1, coord).x;

    if (scenedepth0 != 1.0) {
        vec3 viewpos0       = screenSpaceToViewSpace(vec3(coord, scenedepth0), gbufferProjectionInverse);
        vec3 scenepos0      = viewSpaceToSceneSpace(viewpos0, gbufferModelViewInverse);

        vec3 viewpos1       = screenSpaceToViewSpace(vec3(coord, scenedepth1), gbufferProjectionInverse);
        vec3 scenepos1      = viewSpaceToSceneSpace(viewpos1, gbufferModelViewInverse);

        bool translucent  = scenedepth0 < scenedepth1;

        if (translucent) {
            vec4 translucents   = texture2D(colortex3, coord);
                translucents.rgb = decompressHDR(translucents.rgb);

                scenecol.rgb    = scenecol.rgb * (1.0 - translucents.a) + translucents.rgb;

                scenecol.rgb    = getFog(scenecol.rgb, scenepos0, viewpos0);
        } else {
            scenecol.rgb    = getFog(scenecol.rgb, scenepos0, viewpos0);
        }
    }

        scenecol 	    = compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
    gl_FragData[0]  = vec4(scenecol, 1.0);
}