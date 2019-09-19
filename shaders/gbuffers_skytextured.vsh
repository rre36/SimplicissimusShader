#version 120

varying vec4 color;
varying vec4 texcoord;

void main() {
	gl_Position = ftransform();
	
	color = gl_Color;
	color.rgb 	= pow(color.rgb, vec3(2.2));
	
	texcoord = gl_TextureMatrix[0] * gl_MultiTexCoord0;

	gl_FogFragCoord = gl_Position.z;
}