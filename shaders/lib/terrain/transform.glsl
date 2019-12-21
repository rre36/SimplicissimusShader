/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/


uniform vec3 cameraPosition;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

void unpackPos() {
    position = gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex);
    position.xyz += cameraPosition.xyz;
}

void repackPos() {
    position.xyz -= cameraPosition.xyz;
    position = gl_ProjectionMatrix * (gbufferModelView * position);
}

void unpackShadow() {
    position = shadowProjectionInverse * position;
    position = shadowModelViewInverse * position;
    position.xyz += cameraPosition.xyz;
}

void repackShadow() {
    position.xyz -= cameraPosition.xyz;
    position = shadowModelView * position;
    position = shadowProjection * position;
}