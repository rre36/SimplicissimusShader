#version 120

varying vec3 lightVec;

varying vec2 texcoord;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;

uniform vec3 shadowLightPosition;

void main() {
	gl_Position = ftransform();

	sunlightColor = vec3(1.0, 1.0, 1.0);
	skylightColor = vec3(0.1, 0.1, 0.1);
	torchlightColor = vec3(1.0, 0.3, 0.0);
	
	texcoord 	= gl_MultiTexCoord0.xy;
	lightVec	= normalize(shadowLightPosition);
}
