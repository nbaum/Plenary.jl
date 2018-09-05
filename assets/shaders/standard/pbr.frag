#define PI 3.1415926535897932384626433832795

float rand(vec4 seed) {
  float dot_product = dot(seed, vec4(12.9898,78.233,45.164,94.673));
  return fract(sin(dot_product) * 43758.5453);
}

struct Light {
  vec3 position;
  mat4 transform;
  vec4 color;
};

struct Scene {
  float framenum;
  mat4 projection, view, model;
  Light lights[8];
};

uniform Scene scene;

// uniform sampler2D lightmaps[8];

vec3 model2world(vec3 v) { return mat3(scene.model) * v; }
vec3 world2model(vec3 v) { return inverse(mat3(scene.model)) * v; }

vec3 model2eye(vec3 v) { return mat3(scene.view) * mat3(scene.model) * v; }
vec3 world2eye(vec3 v) { return mat3(scene.model) * v; }

vec3 eye2model(vec3 v) { return inverse(mat3(scene.view) * mat3(scene.model)) * v; }
vec3 eye2world(vec3 v) { return inverse(mat3(scene.view)) * v; }

vec4 eye2world(vec4 v) { return inverse(scene.view) * v; }

vec4 proj (vec4 v) {
  return vec4(v.xyz / v.w, 1);
}

vec3 specular(in Light light, vec3 normal, vec3 position) {
  vec3 lightdir = normalize(light.position - position);
  if (dot(normal, lightdir) < 0.1)
    return vec3(0);
  vec3 refdir = reflect(-lightdir, normal);
  float x = pow(clamp(dot(refdir, eye2world(vec3(0, 0, 1))), 0.0, 1.0), 50);
  return vec3(0.25) * x;
}

vec3 diffuse(in Light light, vec3 normal, vec3 position) {
  vec3 lightdir = normalize(light.position - position);
  return vec3(clamp(dot(normal, lightdir), 0.0, 1.0));
}

float shadow(sampler2D lightmap, vec4 coord) {
  float scene_z = coord.z / coord.w;
  scene_z -= fwidth(scene_z);
  // ivec2 size = textureSize(lightmap, 0);
  float t = 0, c = 0;
  vec2 step = fwidth(coord.xy);
  int size = 2;
  for (int x = -size; x <= size; ++x)
    for (int y = -size; y <= size; ++y) {
      t += texture(lightmap, coord.xy + step.x * x + step.y * y).r > scene_z ? 1.0 : 0.0;
      c += 1.0;
    }
  return t / c;
}

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

in FragData frag;

out vec4 fragColor;

vec4 fragment(in FragData frag);

void main() {
  fragColor = fragment(frag);
}

// uniform sampler2D skybox;
// uniform sampler2D irradiance;

vec3 fresnel_factor (vec3 f, float p) {
  return mix(f, vec3(1), pow(1.01 - p, 5.0));
}

float GGX (float r, float NdH) {
  float m = r * r;
  float m2 = m * m;
  float d = (NdH * m2 - NdH) * NdH + 1.0;
  return m2 / (PI * d * d);
}

float schlick (float r, float NdV, float NdL) {
  float k = r * r * 0.5;
  float V = NdV * (1.0 - k) + k;
  float L = NdL * (1.0 - k) + k;
  return 0.25 / (V * L);
}

vec3 cooktorrance(vec3 s, float r, float NdH, float NdV, float NdL)
{
  float D = GGX(r, NdH);
  float G = schlick(r, NdV, NdL);
  float rim = mix(1.0 - r * 0.5 * 0.9, 1.0, NdV);
  return (1.0 / rim) * s * clamp(G, 0.0, 1.0) * D;
}

bool eq (vec3 a, vec3 b) {
  a += 0.1;
  return a.r > b.r && a.g > b.g && a.b > b.b;
}

// uniform sampler2D emission, ao, albedo, matprops;
uniform sampler2D albedo;

vec4 fragment (in FragData frag) {

  vec3 lightpos = scene.lights[0].position;
  vec3 viewpos = eye2world(vec4(0, 0, 0, 1)).xyz;

  float A = 1.0 / sqrt(length(lightpos - frag.worldpos.xzy));

  vec3 L = normalize(lightpos - frag.worldpos.xyz);
  vec3 V = normalize(viewpos - frag.worldpos.xyz);
  vec3 N = normalize(frag.worldnormal);
  vec3 H = normalize(L + V);

  float NdL = clamp(dot(N, L), 0.0, 1.0);
  float NdV = dot(N, V);
  float HdV = dot(H, V);
  float NdH = dot(N, H);

  vec3 base = texture(albedo, frag.uv0).rgb;
  //vec3 base = vec3(1, 1, 1);

  // vec3 emit = pow(texture(emission, frag.uv0).rgb, vec3(2, 2, 2)) * 30;
  vec3 emit = vec3(0, 0, 0);

  // vec2 prop = texture(matprops, frag.uv0).xy;
  vec2 prop = vec2(0.5, 0.5);

  return vec4(base, 1);

  float metallic = prop.x;
  float roughness = prop.y;

  vec3 specular = mix(vec3(0.04), base, metallic);
  vec3 specfresnel = fresnel_factor(specular, HdV);
  vec3 light = scene.lights[0].color.rgb * scene.lights[0].color.a;
  // light *= shadow(lightmaps[0], frag.lightpos0);
  // light *= pow(texture(ao, frag.uv0).rgb, vec3(1));

  vec3 reflected = cooktorrance(specfresnel, roughness, NdH, NdV, NdL) * NdL * light;
  vec3 diffuse = (vec3(1) - specfresnel) * NdL * light / PI;

  // reflected += texture360(skybox, normalize(reflect(-V, N))).rgb;
  // diffuse += texture360(irradiance, N).rgb / PI;
  vec3 result = diffuse * mix(base, vec3(0.0), metallic) + reflected * mix(0.0, 1.0, metallic);
  return vec4(result + emit, 1.0);

}
