/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


const float pi = 3.14159265358979323846;

/* ------ matrix macros ------ */
    #define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
    #define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
    #define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

    #define transMAD(mat, v) (mat3x3(mat) * (v) + (mat)[3].xyz)
    #define projMAD3(mat, v) (diagonal3(mat) * (v) + (mat)[3].xyz)

#define sstep(x, low, high) smoothstep(low, high, x)
#define saturate(x) clamp(x, 0.0, 1.0)
#define finv(x) (1.0-x)
#define ircp(x) (1.0 / x)

float rcp(float x) {
    return ircp(x);
}
vec2 rcp(vec2 x) {
    return ircp(x);
}
vec3 rcp(vec3 x) {
    return ircp(x);
}

float pow2(float x) {
    return x*x;
}
float pow3(float x) {
    return pow2(x)*x;
}
float pow4(float x) {
    return pow2(pow2(x));
}
float pow5(float x) {
    return pow4(x)*x;
}
float pow6(float x) {
    return pow2(pow3(x));
}
float pow8(float x) {
    return pow2(pow4(x));
}
float pow10(float x) {
    return pow5(x)*pow5(x);
}

float vec3avg(vec3 x) {
    return (x.r+x.g+x.b)/3.0;
}

float linStep(float x, float low, float high) {
    float t = saturate((x-low)/(high-low));
    return t;
}

vec3 linStep(vec3 x, float low, float high) {
    vec3 t = saturate((x-low)/(high-low));
    return t;
}