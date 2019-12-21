/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


//screen-/viewspace position
vec3 getScreenpos(float depth, vec2 coord) {
    vec4 posNDC     = vec4(coord.x*2.0-1.0, coord.y*2.0-1.0, 2.0*depth-1.0, 1.0);
        posNDC      = gbufferProjectionInverse*posNDC;
    return posNDC.xyz/posNDC.w;
}

//worldspace position
vec3 getWorldpos(float depth, vec2 coord) {
    vec3 posCamSpace    = getScreenpos(depth, coord).xyz;
    vec3 posWorldSpace  = viewMAD(gbufferModelViewInverse, posCamSpace);
    posWorldSpace.xyz  += cameraPosition.xyz;
    return posWorldSpace;
}

//convert screenspace to worldspace
vec3 toWorldpos(vec3 screenPos) {
    vec3 posCamSpace    = screenPos;
    vec3 posWorldSpace  = viewMAD(gbufferModelViewInverse, posCamSpace);
    posWorldSpace.xyz  += cameraPosition.xyz;
    return posWorldSpace;
}

//convert worldspace to screenspace
vec3 toScreenpos(vec3 worldpos) {
    vec3 posWorldSpace  = worldpos;
    posWorldSpace.xyz  -= cameraPosition.xyz;
    vec3 posCamSpace    = viewMAD(gbufferModelView, posWorldSpace);
    return posCamSpace;
}