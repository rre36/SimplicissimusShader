const int gLinear = 9729;
const int gExp = 2048;

uniform int fogMode;

vec3 applyFog(vec3 color) {
    vec3 fogcolor = pow(gl_Fog.color.rgb, vec3(2.2));
    
    if (fogMode == gExp) {
		color = mix(color, (fogcolor.rgb), 1.0 - clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0));
	} else if (fogMode == gLinear) {
		color = mix(color, (fogcolor.rgb), clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale, 0.0, 1.0));
	}
    return color;
}