#version 120

uniform sampler2D tex;

varying vec2 coord;

varying vec4 tint;

uniform int blockEntityId;

void main() {
    vec4 scenecol   = texture2D(tex, coord, -1)*vec4(tint.rgb, 1.0);

    if (blockEntityId == 138) discard;

    gl_FragData[0]  = scenecol;
}