/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



#define info 0 		//[0]

#define setBitdepth 8       //[6 8 10 12]

/* ------ color grading related settings ------ */
//#define do_colorgrading

#define vibrance_int 1.00       //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define saturation_int 1.00     //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define gamma_curve 1.00        //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define brightness_int 0.00     //[-0.50 -0.45 -0.40 -0.35 -0.30 -0.25 -0.20 -0.15 -0.10 -0.05 0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.5]
#define constrast_int 1.00      //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

#define colorlum_r 1.00         //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define colorlum_g 1.00         //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define colorlum_b 1.00         //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

//#define vignette_enabled
#define vignette_start 0.15     //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define vignette_end 0.85       //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define vignette_intensity 0.75 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define vignette_exponent 1.50  //[0.50 0.75 1.0 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00]


#include "/lib/math.glsl"
#include "/lib/common.glsl"

//#define bloom
#define bloomIntensity 1.0  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

uniform sampler2D colortex0;

varying vec2 coord;

#ifdef bloom
    uniform sampler2D colortex2;

    uniform float viewHeight;
    uniform float viewWidth;

    vec3 bloomExpand(vec3 x) {
        return x * x * x * x * 16.0;
    }

    vec3 getBloom() {
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

vec3 rgb_luma(vec3 x) {
    return x * vec3(colorlum_r, colorlum_g, colorlum_b);
}

vec3 gammacurve(vec3 x) {
    return pow(x, vec3(gamma_curve));
}

vec3 vibrance_saturation(vec3 color) {
    float lum  = dot(color, vec3(0.2125, 0.7154, 0.0721));
    float mn   = min(min(color.r, color.g), color.b);
    float mx   = max(max(color.r, color.g), color.b);
    float sat  = (1.0 - saturate(mx-mn)) * saturate(1.0-mx) * lum * 5.0;
    vec3 light = vec3((mn + mx) / 2.0);

    color      = mix(color, mix(light, color, vibrance_int), sat);
    color      = mix(color, light, (1.0-light) * (1.0-vibrance_int) / 2.0 * abs(vibrance_int));
    color      = mix(vec3(lum), color, saturation_int);

    return color;
}

vec3 brightness_contrast(vec3 color) {
    return (color - 0.5) * constrast_int + 0.5 + brightness_int;
}

vec3 vignette(vec3 color) {
    float fade      = length(coord*2.0-1.0);
        fade        = linStep(abs(fade) * 0.5, vignette_start, vignette_end);
        fade        = 1.0 - pow(fade, vignette_exponent) * vignette_intensity;

    return color * fade;
}

const mat3 XYZ_sRGB = mat3(
	 3.2409699419, -1.5373831776, -0.4986107603,
	-0.9692436363,  1.8759675015,  0.0415550574,
	 0.0556300797, -0.2039769589,  1.0569715142
);
const mat3 sRGB_XYZ = mat3(
	0.4124564, 0.3575761, 0.1804375,
	0.2126729, 0.7151522, 0.0721750,
	0.0193339, 0.1191920, 0.9503041
);

const mat3 XYZ_P3D65 = mat3(
    2.4933963, -0.9313459, -0.4026945,
    -0.8294868,  1.7626597,  0.0236246,
    0.0358507, -0.0761827,  0.9570140
);
const mat3 XYZ_REC2020 = mat3(
	 1.7166511880, -0.3556707838, -0.2533662814,
	-0.6666843518,  1.6164812366,  0.0157685458,
	 0.0176398574, -0.0427706133,  0.9421031212
);
// https://en.wikipedia.org/wiki/Adobe_RGB_color_space
const mat3 XYZ_AdobeRGB = mat3(
      2.04158790381075,  -0.56500697427886,  -0.34473135077833,
     -0.96924363628088,   1.87596750150772, 0.0415550574071756,
    0.0134442806320311, -0.118362392231018,   1.01517499439121
);

// Bradford chromatic adaptation from standard D65 to DCI Cinema White
const mat3 D65_DCI = mat3(
    1.02449672775258,     0.0151635410224164, 0.0196885223342068,
    0.0256121933371582,   0.972586305624413,  0.00471635229242733,
    0.00638423065008769, -0.0122680827367302, 1.14794244517368
);

const mat3 sRGB_to_P3DCI = ((sRGB_XYZ) * XYZ_P3D65) * D65_DCI;
const mat3 sRGB_to_P3D65 = sRGB_XYZ * XYZ_P3D65;
const mat3 sRGB_to_REC2020 = sRGB_XYZ * XYZ_REC2020;
const mat3 sRGB_to_AdobeRGB = sRGB_XYZ * XYZ_AdobeRGB;

#if (defined COLOR_SPACE_SRGB || defined COLOR_SPACE_DCI_P3 || defined COLOR_SPACE_DISPLAY_P3 || defined COLOR_SPACE_REC2020 || defined COLOR_SPACE_ADOBE_RGB)

uniform int currentColorSpace;

// https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics
vec3 EOTF_Curve(vec3 LinearCV, const float LinearFactor, const float Exponent, const float Alpha, const float Beta) {
    return mix(LinearCV * LinearFactor, clamp(Alpha * pow(LinearCV, vec3(Exponent)) - (Alpha - 1.0), 0.0, 1.0), step(Beta, LinearCV));
}

// https://en.wikipedia.org/wiki/SRGB#Transfer_function_(%22gamma%22)
vec3 EOTF_IEC61966(vec3 LinearCV) {
    return EOTF_Curve(LinearCV, 12.92, 1.0 / 2.4, 1.055, 0.0031308);;
    //return mix(LinearCV * 12.92, clamp(pow(LinearCV, vec3(1.0/2.4)) * 1.055 - 0.055, 0.0, 1.0), step(0.0031308, LinearCV));
}
// https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics
vec3 EOTF_BT709(vec3 LinearCV) {
    return EOTF_Curve(LinearCV, 4.5, 0.45, 1.099, 0.018);
    //return mix(LinearCV * 4.5, clamp(pow(LinearCV, vec3(0.45)) * 1.099 - 0.099, 0.0, 1.0), step(0.018, LinearCV));
}
// https://en.wikipedia.org/wiki/DCI-P3
vec3 EOTF_P3DCI(vec3 LinearCV) {
    return pow(LinearCV, vec3(1.0 / 2.6));
}
// https://en.wikipedia.org/wiki/Adobe_RGB_color_space
vec3 EOTF_Adobe(vec3 LinearCV) {
    return pow(LinearCV, vec3(1.0 / 2.2));
}

vec3 OutputGamutTransform(vec3 LinearCV) {
    switch(currentColorSpace) {
        case COLOR_SPACE_SRGB:
            return EOTF_IEC61966(LinearCV);

        case COLOR_SPACE_DCI_P3:
            LinearCV = LinearCV * sRGB_to_P3DCI;
            return EOTF_P3DCI(LinearCV);

        case COLOR_SPACE_DISPLAY_P3:
            LinearCV = LinearCV * sRGB_to_P3D65;
            return EOTF_IEC61966(LinearCV);

        case COLOR_SPACE_REC2020:
            LinearCV = LinearCV * sRGB_to_REC2020;
            return EOTF_BT709(LinearCV);

        case COLOR_SPACE_ADOBE_RGB:
            LinearCV = LinearCV * sRGB_to_AdobeRGB;
            return EOTF_Adobe(LinearCV);
    }
    // Fall back to sRGB if unknown
    return EOTF_IEC61966(LinearCV);
}

#else

#define clamp16F(x) clamp(x, 0.0, 65535.0)

vec3 LinearToSRGB(vec3 x){
    return mix(x * 12.92, clamp16F(pow(x, vec3(1./2.4)) * 1.055 - 0.055), step(0.0031308, x));
}

#define VIEWPORT_GAMUT 0    //[0 1 2] 0: sRGB, 1: P3D65, 2: Display P3

vec3 OutputGamutTransform(vec3 Linear) {
#if VIEWPORT_GAMUT == 1
    vec3 P3 = Linear * sRGB_to_P3D65;
    //return LinearToSRGB(P3);
    return pow(P3, vec3(1.0 / 2.6));
#elif VIEWPORT_GAMUT == 2
    vec3 P3 = Linear * sRGB_to_P3D65;
    return LinearToSRGB(P3);
    //return pow(P3, vec3(1.0 / 2.2));
#else
    return LinearToSRGB(Linear);
#endif
}

#endif

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;
		scenecol 		= decompressHDR(scenecol.rgb);

	#ifdef bloom
        #ifdef dim
            scenecol 	   += getBloom() * 0.5 * bloomIntensity;
        #else
		    scenecol 	   += getBloom() * 0.023 * bloomIntensity;
        #endif
	#endif

    #ifdef do_colorgrading
        scenecol        = vibrance_saturation(scenecol);
        scenecol        = rgb_luma(scenecol);
    #endif

    #ifdef vignette_enabled
        scenecol        = vignette(scenecol);
    #endif

		scenecol 		= reinhardTonemap(scenecol);
		scenecol 		= OutputGamutTransform(scenecol);

    #ifdef do_colorgrading
        scenecol        = brightness_contrast(scenecol);
        scenecol        = gammacurve(scenecol);
    #endif

		scenecol 		= imageDither(scenecol);

	gl_FragColor		= vec4(scenecol, 1.0);
}