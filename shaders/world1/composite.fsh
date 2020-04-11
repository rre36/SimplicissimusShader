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

uniform sampler2D depthtex0;

uniform float far;

uniform vec2 taaOffset;

uniform vec3 fogColor;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

varying vec2 coord;

#include "/lib/transforms.glsl"

vec3 getFog(vec3 color, vec3 scenepos){
	float dist 	= length(scenepos)/far;
		dist 	= max((dist-fogStart)*1.25, 0.0);
	float alpha = 1.0-exp2(-dist);

	color 	= mix(color, pow(fogColor, vec3(2.3)), saturate(pow2(alpha))*fogIntensity);

	return color;
}

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);

    float scenedepth0   = texture2D(depthtex0, coord).x;

    if (scenedepth0 < 1.0) {
        vec3 viewpos0       = screenSpaceToViewSpace(vec3(coord, scenedepth0), gbufferProjectionInverse);
        vec3 scenepos0      = viewSpaceToSceneSpace(viewpos0, gbufferModelViewInverse);
        scenecol.rgb    = getFog(scenecol.rgb, scenepos0);
    }

        scenecol 	    = compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
    gl_FragData[0]  = vec4(scenecol, 1.0);
}