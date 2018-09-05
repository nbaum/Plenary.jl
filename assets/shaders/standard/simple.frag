#include "/common.glsl"

vec4 fragment (in FragData frag) {
  float atten = SHADOW(lightmaps[0], frag.lightpos0);
  vec3 color = vec3(1.0 / 8.0);
  color += diffuse(scene.lights[0], frag.worldnormal, frag.worldpos.xyz) * atten;
  color += specular(scene.lights[0], frag.worldnormal, frag.worldpos.xyz) * atten;
  return vec4(color, 1);
}
