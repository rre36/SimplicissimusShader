#version 120

varying vec2 coord;
varying vec2 lmap;

varying vec4 tint;

vec4 position;

uniform int frameCounter;

uniform float viewWidth;
uniform float viewHeight;

#include "/lib/taaJitter.glsl"

void main() {
	tint 	= gl_Color;
	coord 	= (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;	
	lmap 	= (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    position 	= gl_ProjectionMatrix*(gl_ModelViewMatrix*gl_Vertex);

	position.xy = taaJitter(position.xy, position.w);

	gl_Position = position;
}