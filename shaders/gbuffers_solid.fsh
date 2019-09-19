uniform sampler2D tex;
uniform sampler2D lightmap;

varying vec4 color;
varying vec4 texcoord;
varying vec4 lmcoord;
varying vec3 normal;

void main() {
	/*DRAWBUFFERS:012*/
	gl_FragData[0] = texture2D(tex, texcoord.st) * color;
	gl_FragData[1] = vec4(normal*0.5+0.5, 1.0); 	//write normals to a buffer to be reused later
	gl_FragData[2] = vec4(lmcoord.xy, 0.0, 1.0); 	//write lightmaps to a buffer
}