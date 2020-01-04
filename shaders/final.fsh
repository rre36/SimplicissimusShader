#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#define info 0 		//[0]

#define setBitdepth 8       //[6 8 10 12]

#include "/lib/common.glsl"

//#define bloom

uniform sampler2D colortex0;

varying vec2 coord;

#ifdef bloom
const float bloomIntensity  = 0.0025;

uniform sampler2D colortex2;

uniform float viewHeight;
uniform float viewWidth;

float vec3avg(vec3 x) {
    return (x.x+x.y+x.z)/3.0;
}

vec3 bloomExpand(vec3 x) {
    return x * x * x * x * 16.0;
}

vec3 get_bloom() {
    vec3 blur1 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,2.0) + vec2(0.0,0.0)).rgb);
    vec3 blur2 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,3.0) + vec2(0.3,0.0)).rgb)*0.95;
    vec3 blur3 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,4.0) + vec2(0.0,0.3)).rgb)*0.9;
    vec3 blur4 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,5.0) + vec2(0.1,0.3)).rgb)*0.85;
    vec3 blur5 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,6.0) + vec2(0.2,0.3)).rgb)*0.8;
    vec3 blur6 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,7.0) + vec2(0.3,0.3)).rgb)*0.75;
    vec3 blur7 = bloomExpand(texture2D(colortex2,coord.xy/pow(2.0,8.0) + vec2(0.4,0.3)).rgb)*0.7;
	
    vec3 blur = (blur1 + blur2 + blur3 + blur4 + blur5 + blur6 + blur7);
    float blurLuma = vec3avg(blur);
    blur *= blurLuma*blurLuma;

    return blur/7.0;
}

#endif

float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}
#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))

vec3 reinhardTonemap(vec3 hdr){     //based off jodie's approach
    vec3 sdr   	= hdr * 0.7;
    float luma  = dot(sdr, vec3(0.2126, 0.7152, 0.0722));

	float coeff = 0.4;

	//sdr 		= pow(sdr, vec3(0.98));
    vec3 color  = sdr/(sdr + coeff);

    	sdr   	= mix(sdr/(luma + coeff), color, color);

	return sdr;
}

int getColorBit() {
	if (setBitdepth==1) {
		return 1;
	} else if (setBitdepth==2) {
		return 4;
	} else if (setBitdepth==4) {
		return 16;
	} else if (setBitdepth==6) {
		return 64;
	} else if(setBitdepth==8){
		return 255;
	} else if (setBitdepth==10) {
		return 1023;
	} else {
		return 255;
	}
}

vec3 imageDither(vec3 color) {
    int bits = getColorBit();
    vec3 colDither = color;
        colDither *= bits;
        colDither += bayer16(gl_FragCoord.xy)-0.5;

        float colR = (colDither.r);
        float colG = (colDither.g);
        float colB = (colDither.b);

    return vec3(colR, colG, colB)/bits;
}

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);

	#ifdef bloom
		scenecol 	   += get_bloom()*bloomIntensity;
	#endif

		//if (scenecol.r > 2.0) scenecol.rgb = vec3(0.0, 40.0, 0.0);
		//else if (scenecol.r < 1.0) scenecol.rgb = vec3(40.0, 0.0, 0.0);
		scenecol 		= reinhardTonemap(scenecol);
		//if (scenecol.r > 0.9) scenecol.rgb = vec3(1.0, 0.0, 0.0);
		scenecol 		= pow(scenecol, vec3(1.0/2.2));	//convert color back to display gamma
		scenecol 		= imageDither(scenecol);

	gl_FragColor		= vec4(scenecol, 1.0);
}