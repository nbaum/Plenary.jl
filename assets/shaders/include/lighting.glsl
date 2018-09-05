
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
