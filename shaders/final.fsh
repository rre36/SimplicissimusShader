#version 120

uniform sampler2D colortex0;

varying vec2 texcoord;

void main() {
	vec3 sceneColor 	= texture2D(colortex0, texcoord).rgb;
		sceneColor 		= pow(sceneColor, vec3(1.0/2.2));	//convert color back to display gamma

	gl_FragColor		= vec4(sceneColor, 1.0);
}