#include "/common.glsl"

vec4 fragment (in FragData frag) {
  float depth = (gl_FragCoord.z / gl_FragCoord.w);
  float m1 = depth, m2 = depth * depth + (pow(dFdx(depth), 2) + pow(dFdy(depth), 2)) / 4;
  float dd = exp(ESM_EXPONENTIAL * gl_FragCoord.z);
  return vec4(m1, m2, dd, 1);
}
