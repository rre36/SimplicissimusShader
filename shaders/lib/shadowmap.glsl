/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


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