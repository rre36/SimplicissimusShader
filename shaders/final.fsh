#version 120

#define info 0 		//[0]

#define setBitdepth 8       //[6 8 10 12]

#include "/lib/common.glsl"

uniform sampler2D colortex0;

varying vec2 coord;

float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}
#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))

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
		scenecol 		= reinhardTonemap(scenecol);
		scenecol 		= pow(scenecol, vec3(1.0/2.2));	//convert color back to display gamma
		scenecol 		= imageDither(scenecol);

	gl_FragColor		= vec4(scenecol, 1.0);
}