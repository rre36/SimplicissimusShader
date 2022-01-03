/*
Copyright (C) 2022 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


vec3 screenSpaceToViewSpace(vec3 screenPosition, mat4 projectionInverse, const bool taaAware) {
	screenPosition = screenPosition * 2.0 - 1.0;

    #ifdef taa_enabled
        if (taaAware) screenPosition.xy -= taaOffset;
    #endif

	vec3 viewPosition  = vec3(vec2(projectionInverse[0].x, projectionInverse[1].y) * screenPosition.xy + projectionInverse[3].xy, projectionInverse[3].z);
	     viewPosition /= projectionInverse[2].w * screenPosition.z + projectionInverse[3].w;

	return viewPosition;
}
vec3 screenSpaceToViewSpace(vec3 screenPosition, mat4 projectionInverse) {
    return screenSpaceToViewSpace(screenPosition, projectionInverse, true);
}
vec3 viewSpaceToSceneSpace(in vec3 viewPosition, in mat4 modelViewInverse) {
    return mat3(modelViewInverse) * viewPosition + modelViewInverse[3].xyz;
}