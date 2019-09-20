const float pi = 3.14159265358979323846;

#define diag3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diag3(m) * (v) + (m)[3].xyz)
#define viewMAD(m, v) (mat3(m) * (v) + (m)[3].xyz)

#define sstep(x, low, high) smoothstep(low, high, x)
#define saturate(x) clamp(x, 0.0, 1.0)
#define finv(x) (1.0-x)

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