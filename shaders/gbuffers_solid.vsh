varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec3 normal;

attribute vec4 mc_Entity;

uniform int worldTime;

void main() {

	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;
	
	vec4 position = gl_Vertex;

	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
	
	color = gl_Color;
	
	lmcoord = gl_TextureMatrix[1] * gl_MultiTexCoord1;
	
	gl_FogFragCoord = gl_Position.z;

	normal 	= normalize(gl_NormalMatrix*gl_Normal);
}