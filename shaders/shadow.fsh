#version 120
/*
Copyright (C) 2019 RRe36

All Rights Reserved unless otherwise explicitly stated.


By downloading this you have agreed to the license and terms of use.
These can be found inside the included license-file or here: https://rre36.github.io/license/

Violating these terms may be penalized with actions according to the Digital Millennium Copyright Act (DMCA), the Information Society Directive and/or similar laws depending on your country.
*/



uniform sampler2D tex;

varying vec2 coord;

varying vec4 tint;

uniform int blockEntityId;

void main() {
    vec4 scenecol   = texture2D(tex, coord, -1)*vec4(tint.rgb, 1.0);

    if (blockEntityId == 138) discard;

    gl_FragData[0]  = scenecol;
}