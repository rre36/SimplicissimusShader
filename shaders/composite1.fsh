#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


#include "/lib/common.glsl"

#extension GL_ARB_shader_texture_lod : enable

//#define bloom

//#define useMotionblur

#ifdef bloom
const bool colortex0MipmapEnabled = true;
#endif

uniform sampler2D colortex0;    //scene color
uniform sampler2D colortex2;    //scene material masks
uniform sampler2D depthtex1;

uniform int frameCounter;

uniform float viewHeight;
uniform float viewWidth;
uniform float aspectRatio;
uniform float frameTime;

varying vec2 coord;

float pxWidth       = 1.0/viewWidth;

vec3 bloomBuffers(float mip, vec2 offset){
	vec3 bufferTex 	= vec3(0.0);
	vec3 temp 		= vec3(0.0);
	float scale 	= pow(2.0, mip);
	vec2 bCoord 	= (coord-offset)*scale;
	float padding 	= 0.005*scale;

	if (bCoord.x>-padding && bCoord.y>-padding && bCoord.x<1.0+padding && bCoord.y<1.0+padding) {
		for (int i=0;  i<7; i++) {
			for (int j=0; j<7; j++) {
				float wg 	= clamp(1.0-length(vec2(i-3,j-3))*0.28, 0.0, 1.0);
					wg 		= pow(wg, 2.0)*20;
				vec2 tCoord = (coord-offset+vec2(i-3, j-3)*pxWidth*vec2(1.0, aspectRatio))*scale;
				if (wg>0) {
					temp 			= (texture2D(colortex0, tCoord).rgb)*wg;
						bufferTex  += max(temp, 0.0);
				}
			}
		}
	bufferTex /=49;
	}
return pow(bufferTex/16.0, vec3(0.2));
}

vec3 makeBloomBuffer() {
    vec3 blur = vec3(0.0);
	blur += bloomBuffers(2,vec2(0,0));
	blur += bloomBuffers(3,vec2(0.3,0));
	blur += bloomBuffers(4,vec2(0,0.3));
	blur += bloomBuffers(5,vec2(0.1,0.3));
	blur += bloomBuffers(6,vec2(0.2,0.3));
	blur += bloomBuffers(7,vec2(0.3,0.3));
	blur += bloomBuffers(8,vec2(0.4,0.3));
	blur += bloomBuffers(9,vec2(0.5,0.3));
    return blur;
}

float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
}
#define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
#define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
#define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))

#define mBlurSamples 7
#define mBlurInt 1.0

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferModelViewInverse;

#ifdef useMotionblur
vec3 motionblur() {
    const int samples = mBlurSamples;
    const float blurStrength = 0.018*mBlurInt;

    float handmask = texture2D(colortex2, coord).r;

    float d     = texture2D(depthtex1, coord).r;
        d       = mix(d, pow(d, 0.01), handmask);

    float dither = bayer16(gl_FragCoord.xy);
    vec2 viewport = 2.0/vec2(viewWidth, viewHeight);

    vec4 currPos = vec4(coord.x*2.0-1.0, coord.y*2.0-1.0, 2.0*d-1.0, 1.0);

    vec4 frag   = gbufferProjectionInverse*currPos;
        frag    = gbufferModelViewInverse*frag;
        frag   /= frag.w;
        frag.xyz += cameraPosition;

    vec4 prevPos = frag;
        prevPos.xyz -= previousCameraPosition;
        prevPos = gbufferPreviousModelView*prevPos;
        prevPos = gbufferPreviousProjection*prevPos;
        prevPos /= prevPos.w;

    float blurSize = blurStrength;
        blurSize /= frameTime*30;
        blurSize  = min(blurSize, 0.033);

    vec2 vel    = (currPos-prevPos).xy;
        vel    *= blurSize;
    const float maxVel = 0.046;
        vel     = clamp(vel, -maxVel, maxVel);
        vel     = vel - (vel/2.0);

    vec2 mCoord  = coord;
    vec3 colBlur = vec3(0.0);
    mCoord += vel*dither;

    int fix = 0;

    for (int i = 0; i<samples; i++, mCoord +=vel) {
        if (mCoord.x>=1.0 || mCoord.y>=1.0 || mCoord.x<=0.0 || mCoord.y<=0.0) {
            colBlur += texture2DLod(colortex0, coord, 0).rgb;
            fix += 1;
            break;
        } else {
            vec2 coordB = clamp(mCoord, viewport, 1.0-viewport);
            colBlur += texture2DLod(colortex0, coordB, 0).rgb;
            ++fix;
        }
    }
    colBlur /= fix;

    return colBlur;
}
#endif

void main() {
	vec3 scenecol 		= texture2D(colortex0, coord).rgb;

    #ifdef useMotionblur
	    scenecol        = motionblur();
    #endif

    #ifdef bloom
    vec3 blur = makeBloomBuffer();
        //blur  = compressHDR(blur);
    #else
    const vec3 blur = vec3(0.0);
    #endif

    /*DRAWBUFFERS:02*/
    gl_FragData[0]  = vec4(scenecol, 1.0);
    gl_FragData[1]  = vec4(blur, 1.0);
}