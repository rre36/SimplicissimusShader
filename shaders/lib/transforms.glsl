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