#version 120

uniform sampler2D texture;

varying vec4 color;
varying vec4 texcoord;
varying vec3 normal;

void main() {
	/*DRAWBUFFERS:01*/
	gl_FragData[0] = texture2D(texture, texcoord.st) * color;
	gl_FragData[1] = vec4(normal*0.5+0.5, 1.0);
}