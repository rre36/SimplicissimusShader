//constants
const float pi = 3.14159265358979323846;

//macros, the first ones are optimized matrix operations
#define diag3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diag3(m) * (v) + (m)[3].xyz)
#define viewMAD(m, v) (mat3(m) * (v) + (m)[3].xyz)

#define sstep(x, low, high) smoothstep(low, high, x)
#define saturate(x) clamp(x, 0.0, 1.0)

#define pow2(x) (x*x)