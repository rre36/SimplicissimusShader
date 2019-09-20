#version 120

#include "/lib/common.glsl"

uniform sampler2D colortex0;

varying vec2 texcoord;

vec3 reinhardTonemap(vec3 hdr){     //based off jodie's approach
    vec3 sdr   	= hdr*0.13;
    float luma  = dot(sdr, vec3(0.2126, 0.7152, 0.0722));

	const float lumCoeff = 0.1;
	const float lumCoeff2 = 0.13;

	//sdr 		= pow(sdr, vec3(0.98));
    vec3 color  = sdr/(sdr + lumCoeff);

    	sdr   	= mix(sdr/(luma + lumCoeff2), color, color);

	return sdr*1.0;
}

void main() {
	vec3 scenecol 		= texture2D(colortex0, texcoord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);
		scenecol 		= reinhardTonemap(scenecol);
		scenecol 		= pow(scenecol, vec3(1.0/2.2));	//convert color back to display gamma

	gl_FragColor		= vec4(scenecol, 1.0);
}