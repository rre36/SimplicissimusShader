#version 120

varying vec2 texcoord;

varying vec4 color;

#include "/lib/shadowmap.glsl"

void main() {
    vec4 position   = gl_ProjectionMatrix*gl_ModelViewMatrix*gl_Vertex;

    warpShadowmap(position.xy);
    position.z     *= 0.2;

    gl_Position     = position;

    texcoord        = (gl_TextureMatrix[0]*gl_MultiTexCoord0).xy;
    color           = gl_Color;
}