#include "/common.glsl"

uniform sampler2D skybox;

vec4 fragment (in FragData frag) {
  return vec4(pow(texture360(skybox, normalize(proj(frag.worldpos).xyz)).rgb, vec3(5, 5, 5)) * 30, 1);
}
