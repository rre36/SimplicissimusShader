/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


const int gLinear = 9729;
const int gExp = 2048;

uniform int fogMode;

vec3 applyFog(vec3 color) {
    vec3 fogcolor = pow(gl_Fog.color.rgb, vec3(2.2));
    
    if (fogMode == gExp) {
		color = mix(color, (fogcolor.rgb), 1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0));
	} else if (fogMode == gLinear) {
		color = mix(color, (fogcolor.rgb), clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0));
	}
    return color;
}