const float jitterSize = 0.6;

const vec2 jitter[8] = vec2[8](
    vec2( 0.125, -0.375),
    vec2(-0.125,  0.375),
    vec2( 0.625,  0.125),
    vec2( 0.375, -0.625),
    vec2(-0.625,  0.625),
    vec2(-0.875, -0.125),
    vec2( 0.375, -0.875),
    vec2( 0.875,  0.875)
);

vec2 taaJitter(vec2 coord, float w) {
    return jitter[int(mod(frameCounter, 8))]*(w/vec2(viewWidth, viewHeight))*jitterSize + coord;
}