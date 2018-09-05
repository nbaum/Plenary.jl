#define PI 3.1415926535897932384626433832795

float rand(vec4 seed) {
  float dot_product = dot(seed, vec4(12.9898,78.233,45.164,94.673));
  return fract(sin(dot_product) * 43758.5453);
}

#include "/uniforms.glsl"
#include "/transform.glsl"
#include "/lighting.glsl"
#include "/shadow.glsl"

struct FragData {
  vec4 localpos;
  vec4 worldpos;
  vec4 eyepos;
  vec3 localnormal;
  vec3 worldnormal;
  vec2 uv0;
  vec3 tangent0;
  vec3 binormal0;
  vec4 color0;
  vec4 lightpos0;
};

vec4 texture360(sampler2D tex, vec3 dir) {
  vec2 uv;
  uv.x = -atan(dir.x, dir.z) / PI * 0.5;
  uv.y = -acos(dir.y / length(dir)) / PI;
  return texture(tex, uv);
}

#ifdef VERTEX_SHADER
in vec3 position;
in vec3 normal;
in vec2 uv0;
in vec3 tangent0;
in vec3 binormal0;
in vec4 color0;
in vec4 alpha0;

out FragData frag;

void vertex(inout FragData frag);

bool shouldDiscard;

void main() {
  shouldDiscard = false;
  frag.localpos = vec4(position, 1);
  frag.localnormal = normal;
  frag.uv0 = uv0;
  frag.tangent0 = tangent0;
  frag.binormal0 = binormal0;
  frag.color0 = color0;
  vertex(frag);
  frag.worldnormal = normalize(mat3(scene.model) * frag.localnormal);
  frag.worldpos = scene.model * frag.localpos;
  frag.eyepos = scene.view * frag.worldpos;
  frag.lightpos0 = scene.lights[0].transform * frag.worldpos;
  frag.lightpos0.xyz = frag.lightpos0.xyz / 2 + 0.5;
  if (shouldDiscard) {
    gl_Position = vec4(-1000, -1000, -1, 1);
  } else {
    gl_Position = scene.projection * frag.eyepos;
  }
}
#endif

#ifdef FRAGMENT_SHADER
in FragData frag;

out vec4 fragColor;

vec4 fragment(in FragData frag);

void main() {
  fragColor = fragment(frag);
}
#endif
