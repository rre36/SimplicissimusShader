//the functions in this file are "bending" the shadowmap so that it conatins higher detail close to the camera
//it also allows for infinite shadowdistances
//method based on code from robobo1221

#define shadowmapBias 0.85

float getWarpFactor(in vec2 x) {
    return length(x * 1.169) * shadowmapBias + (1.0 - shadowmapBias);
}
void warpShadowmap(inout vec2 coord, out float distortion) {
    distortion = getWarpFactor(coord);
    coord /= distortion;
}
void warpShadowmap(inout vec2 coord) {
    float distortion = getWarpFactor(coord);
    coord /= distortion;
}