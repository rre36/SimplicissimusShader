varying float timeSunrise;
varying float timeNoon;
varying float timeSunset;
varying float timeNight;
varying float timeMoon;
varying float timeLightTransition;
varying float timeSun;

uniform float sunAngle;
//uniform int worldTime;

const float transitionExp = 2.0;
float timeVal = sunAngle;
//float timeVal   = fract((worldTime+250)/24000.0); //because sun angle won't update, for whatever reason

void daytime() {
    float tSunrise  = ((clamp(timeVal, 0.96, 1.00)-0.96) / 0.04 + 1-(clamp(timeVal, 0.02, 0.15)-0.02) / 0.13);
    float tNoon     = ((clamp(timeVal, 0.02, 0.15)-0.02) / 0.13   - (clamp(timeVal, 0.35, 0.48)-0.35) / 0.13);
    float tSunset   = ((clamp(timeVal, 0.35, 0.48)-0.35) / 0.13   - (clamp(timeVal, 0.50, 0.53)-0.50) / 0.03);
    float tNight    = ((clamp(timeVal, 0.50, 0.53)-0.50) / 0.03   - (clamp(timeVal, 0.96, 1.00)-0.96) / 0.04);
    float tMoon     = ((clamp(timeVal, 0.51, 0.54)-0.51) / 0.03   - (clamp(timeVal, 0.97, 0.99)-0.97) / 0.02);
    float tLightTransition1 = ((clamp(timeVal, 0.494, 0.499)-0.494) / 0.005  - (clamp(timeVal, 0.53, 0.56)-0.53) / 0.03);
    float tLightTransition2 = ((clamp(timeVal, 0.94, 0.97)-0.94) / 0.03  + 1-(clamp(timeVal, 0.004, 0.03)-0.004) / 0.026);
    float tLightTransition = tLightTransition1+tLightTransition2;

    timeSunrise = clamp(pow3(tSunrise), 0.0, 1.0);
    timeNoon    = clamp(1-pow3(1-tNoon), 0.0, 1.0);
    timeSunset  = clamp(pow3(tSunset), 0.0, 1.0);
    timeNight   = clamp(1-pow3(1-tNight), 0.0, 1.0);
    timeMoon    = clamp(pow2(tMoon), 0.0, 1.0);
    timeLightTransition = (clamp(tLightTransition1, 0.0, 1.0)+clamp(pow2(tLightTransition2), 0.0, 1.0));
    timeSun		= timeSunrise + timeNoon + timeSunset;
}
