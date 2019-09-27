#version 120
#include "/lib/math.glsl"

varying vec4 tint;

vec4 position;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

void repackPos() {
    position = gl_ProjectionMatrix * (gbufferModelView * position);
}

void main() {
	position 	= (gl_ModelViewMatrix*gl_Vertex);
    position 	= gbufferModelViewInverse*position;
	repackPos();
	gl_Position = position;
	tint = gl_Color;
}