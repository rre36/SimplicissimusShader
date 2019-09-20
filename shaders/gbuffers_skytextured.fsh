#version 120
#include "/lib/common.glsl"

uniform sampler2D texture;

varying vec4 color;
varying vec4 texcoord;

#include "/lib/fog.glsl"

void main() {
    vec4 scenecol       = texture2D(texture, texcoord.st) * color;
        scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));
        scenecol.rgb    = applyFog(scenecol.rgb)*3.0;

    scenecol.rgb 	= compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}