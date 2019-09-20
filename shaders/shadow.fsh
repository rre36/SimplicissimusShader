#version 120

uniform sampler2D tex;

varying vec2 coord;

varying vec4 tint;

void main() {
    vec4 scenecol   = texture2D(tex, coord)*vec4(tint.rgb, 1.0);

    gl_FragData[0]  = scenecol;
}