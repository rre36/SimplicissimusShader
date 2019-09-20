#version 120
#include "/lib/common.glsl"

uniform sampler2D texture;
uniform sampler2D lightmap;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;

void main() {
	vec4 scenecol 	= texture2D(texture, texcoord.st) * texture2D(lightmap, lmcoord.st) * color;
	scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));
	scenecol.rgb 	= compressHDR(scenecol.rgb);

	/*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}