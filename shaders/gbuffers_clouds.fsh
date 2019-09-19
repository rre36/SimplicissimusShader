#version 120

uniform sampler2D tex;

varying vec4 tint;
varying vec2 coord;

#include "/lib/fog.glsl"

void main() {
	vec4 scenecol 	= texture2D(tex, coord)*tint;
    scenecol.rgb = pow(scenecol.rgb, vec3(2.2));
		scenecol.rgb = applyFog(scenecol.rgb);

	/*DRAWBUFFERS:0*/
	gl_FragData[0] 	= scenecol;
}