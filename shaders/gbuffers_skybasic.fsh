#version 120
#include "/lib/math.glsl"
#include "/lib/common.glsl"

varying flat float timeNoon;
varying flat float timeMoon;

varying vec4 tint;

varying vec3 vpos;

varying vec3 svec;
varying vec3 mvec;
varying vec3 uvec;

varying vec3 skycol;
varying vec3 suncol;
varying vec3 fogcol;

vec3 getSky() {
    vec3 nfrag  = -normalize(vpos);
    vec3 hvec0  = normalize(-uvec+nfrag);
    vec3 hvec1  = normalize(uvec+nfrag);
    vec3 sgvec  = normalize(svec+nfrag);
    vec3 mgvec  = normalize(mvec+nfrag);

    float htop  = dot(hvec0, nfrag);
    float hbot  = dot(hvec1, nfrag);

    float hfade = linStep(hbot, 0.3, 0.8);
        hfade   = pow6(hfade);

    float hgrad = 1.0-max(hbot, htop);

    float horizon = linStep(hgrad, 0.12, 0.31);
        horizon = pow6(horizon);

    float sgrad = 1.0-dot(sgvec, nfrag);
    float mgrad = 1.0-dot(mgvec, nfrag);

    float sglow = linStep(sgrad, 0.5, 0.99);
        sglow   = pow6(sglow)*0.5;

    float shglow = linStep(sgrad, 0.0, 0.99);
        shglow  = pow3(shglow)*(hfade+horizon)*finv(timeMoon)*finv(timeNoon*0.8);

    vec3 sky    = skycol;
        sky     = mix(sky, fogcol, hfade*0.75);
        sky     = mix(sky, fogcol, horizon*0.8);
        sky    *= pow3(1.0-saturate(shglow));
        sky    += suncol*shglow*6.0;
        sky    += suncol*sglow;

    return sky;
}

void main() {
    vec4 scenecol       = tint;
        scenecol.rgb    = pow(scenecol.rgb, vec3(2.2));
        scenecol.rgb    = getSky();

	scenecol.rgb 	= compressHDR(scenecol.rgb);

    /*DRAWBUFFERS:0*/
	gl_FragData[0] = scenecol;
}