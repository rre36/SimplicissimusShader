#version 120

#include "/lib/math.glsl"
#include "/lib/common.glsl"

varying vec2 coord;
varying vec2 lmap;

varying vec4 tint;

uniform sampler2D tex;
uniform sampler2D lightmap;

void main() {
    vec4 scenecol 	= texture2D(tex, coord)*tint;

    scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));

    scenecol.rgb   *= 3.0;

    scenecol.rgb 	= compressHDR(scenecol.rgb);

    vec4 ret1 	= vec4(0.0, 0.0, 0.0, 1.0);

	/*DRAWBUFFERS:02*/
	gl_FragData[0] = scenecol;
	gl_FragData[1] = ret1;
}