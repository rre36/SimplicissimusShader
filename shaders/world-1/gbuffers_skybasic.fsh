#version 120
#include "/lib/math.glsl"
#include "/lib/common.glsl"

varying vec4 tint;

void main() {
    vec4 scenecol       = vec4(1.0, 0.2, 0.1, 1.0);

	scenecol.rgb 	= compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}