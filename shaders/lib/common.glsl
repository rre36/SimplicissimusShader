vec3 compressHDR(vec3 color) {
    return color/8.0;
}

vec3 decompressHDR(inout vec3 color) {
    return color*8.0;
}

//#define s_secondCloudLayer