#version 120

uniform sampler2D texture;

varying vec4 color;
varying vec4 texcoord;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

uniform int fogMode;

void main() {

	gl_FragData[0] = texture2D(texture, texcoord.st) * color;
}