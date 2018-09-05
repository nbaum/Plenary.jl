
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

uniform sampler2D lightmaps[8];
