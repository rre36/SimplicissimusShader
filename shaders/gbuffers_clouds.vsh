#version 120

varying vec4 tint;
varying vec2 coord;

void main() {
	tint 	= gl_Color;
	coord 	= (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;	
	
	vec4 position = gl_Vertex;

	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
	gl_FogFragCoord = gl_Position.z;
}