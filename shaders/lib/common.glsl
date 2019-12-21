/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


vec3 compressHDR(vec3 color) {
    return color/8.0;
}

vec3 decompressHDR(inout vec3 color) {
    return color*8.0;
}

//#define s_secondCloudLayer