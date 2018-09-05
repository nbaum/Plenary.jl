
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
