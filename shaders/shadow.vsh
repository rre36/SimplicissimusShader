#version 120

varying vec2 coord;

varying vec4 tint;

#include "/lib/shadowmap.glsl"

void main() {
    vec4 position   = gl_ProjectionMatrix*gl_ModelViewMatrix*gl_Vertex;

    warpShadowmap(position.xy);
    position.z     *= 0.2;

    gl_Position     = position;

    coord           = (gl_TextureMatrix[0]*gl_MultiTexCoord0).xy;
    tint           = gl_Color;
}