#version 120
//can be anything up to 450, 120 is still common due to compatibility reasons, but i suggest something from 130 upwards so you can use the new "varying" syntax, i myself usually use "400 compatibility"

//set the main framebuffer attachment to use RGB16 as the format to give us higher color precision, for hdr you would want to use RGB16F instead
const int RGB16 = 0;
const int RGBA16 = 0;
const int colortex0Format   = RGB16;
const int colortex2Format 	= RGBA16;

//include math functions from file
#include "/lib/math.glsl"

//uniforms for scene texture binding
uniform sampler2D colortex0; 	//scene color
uniform sampler2D colortex1;	//scene normals
uniform sampler2D colortex2;	//scene lightmap
uniform sampler2D depthtex0;	//scene depth

//enable shadow2D shadows and bind shadowtex buffer
const bool shadowHardwareFiltering = true;
uniform sampler2DShadow shadowtex1; 	//shadowdepth

//shadowmap resolution
const int shadowMapResolution   = 4096;

//shadowdistance
const float shadowDistance      = 128.0;

//input from vertex
varying vec2 texcoord; 	//scene texture coordinates
varying vec3 lightVec;

varying vec3 sunlightColor;
varying vec3 skylightColor;
varying vec3 torchlightColor;

uniform vec3 cameraPosition;

//uniforms (projection matrices)
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;

//include position transform files
#include "/lib/transforms.glsl"
#include "/lib/shadowmap.glsl"

/* 	
	functions to be called in main and global variables go here
	however keep the amount of global variables rather low since the number of temp registers is limited,
	so large amounts of constantly changed global variables can cause performance bottlenecks
	also having non-constant global variables is considered bad practice by some and will cause issues
	if you sample a texture outside of void main() or a function
*/

vec3 sceneColor 	= vec3(0.0);
float sceneDepth	= 0.0;

//function to calculate position in shadowspace
vec3 getShadowCoordinate(in vec3 screenpos, in float bias) {
	vec3 position 	= screenpos;
		position   += vec3(bias)*lightVec;		//apply shadow bias to prevent shadow acne
		position 	= viewMAD(gbufferModelViewInverse, position); 	//do shadow position tranforms
		position 	= viewMAD(shadowModelView, position);
		position 	= projMAD(shadowProjection, position);

	//apply far plane fix and shadowmap distortion
		position.z *= 0.2;
		warpShadowmap(position.xy);

	return position*0.5+0.5;
}

//calculate shadow, using shadow2D shadows because they are a lot easier to setup here
float getShadow(sampler2DShadow shadowtex, in vec3 shadowpos) {
	float shadow 	= shadow2D(shadowtex, shadowpos).x;

	return shadow;
}

//simple lambertian diffuse shading, google "diffuse shading" for a better explaination than i could give right now
float getDiffuse(vec3 normal, vec3 lightvec) {
	float lambert 	= dot(normal, lightvec);
		lambert 	= max(lambert, 0.0);
	return lambert;
}

//void main is basically the main part where stuff get's done and function get called
void main() {
	//setup some variables for structure
	vec3 sceneNormal;
	vec2 sceneLightmap;

	//sample necessary scene textures
	sceneColor 	= texture2D(colortex0, texcoord).rgb;
	sceneColor 	= pow(sceneColor, vec3(2.2)); 	//linearize scene color
	sceneDepth 	= texture2D(depthtex0, texcoord).x;
	sceneNormal	= normalize(texture2D(colortex1, texcoord).xyz*2.0-1.0);
	sceneLightmap = texture2D(colortex2, texcoord).xy;
	sceneLightmap.x = pow2(sceneLightmap.x); 	//this improves the torchlight falloff a bit

	//calculate necessary positions
	vec3 screenpos 	= getScreenpos(sceneDepth, texcoord);

	//make terrain mask
	bool isTerrain 	= sceneDepth < 1.0;

	//variables for shadow calculation
	float shadow 		= 1.0;
	float comparedepth 	= 0.0;

	//check if it is even terrain and then do shading
	if (isTerrain) {
		float diffuse 		= getDiffuse(sceneNormal, lightVec); 	//get diffuse shading

		if (diffuse>0.0) {
			vec3 shadowcoord 	= getShadowCoordinate(screenpos, 0.06); 	//get shadow coordinate
				shadow 			= getShadow(shadowtex1, shadowcoord); 		//get shadows
		}
		shadow 	= min(diffuse, shadow); 		//blend shadows and diffuse shading, this was is good since it helps to hide some of the shadow acne

		vec3 lightcolor 	= sunlightColor*shadow + skylightColor*sceneLightmap.y;	//apply sunlight and skylight color based on lighting
			lightcolor 	    = max(lightcolor, torchlightColor*sceneLightmap.x);

		sceneColor 		   *= lightcolor; 		//apply lighting to diffuse
	}


	//write to framebuffer attachment
	/*DRAWBUFFERS:0*/
	gl_FragData[0] = vec4(sceneColor, 1.0);
}
