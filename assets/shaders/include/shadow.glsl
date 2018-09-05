#define SHADOW pcm

float randompoisson(sampler2D lightmap, vec4 coord) {
  const vec2 poissonDisk[4] = vec2[](
    vec2( -0.94201624, -0.39906216 ),
    vec2( 0.94558609, -0.76890725 ),
    vec2( -0.094184101, -0.92938870 ),
    vec2( 0.34495938, 0.29387760 )
  );
  float visibility = 1.0;
  for (int i = 0; i < 4; i++) {
    int index = int(4 * rand(vec4(gl_FragCoord.xy, i, scene.framenum)));
    if (texture(lightmap, coord.xy + poissonDisk[index] / 1000.0).x < coord.z)
      visibility -= 0.2;
  }
  return clamp(visibility, 0.0, 1.0);
}

float poisson(sampler2D lightmap, vec4 coord) {
  const vec2 poissonDisk[4] = vec2[](
    vec2( -0.94201624, -0.39906216 ),
    vec2( 0.94558609, -0.76890725 ),
    vec2( -0.094184101, -0.92938870 ),
    vec2( 0.34495938, 0.29387760 )
  );
  float visibility = 1.0;
  for (int i = 0; i < 4; i++) {
    if (texture(lightmap, coord.xy + poissonDisk[i] / 1000.0).x < coord.z)
      visibility -= 0.2;
  }
  return clamp(visibility, 0.0, 1.0);
}

float pcm(sampler2D lightmap, vec4 coord) {
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

float straightup(sampler2D lightmap, vec4 coord) {
  float light_z = texture(lightmap, coord.xy).r;
  float scene_z = coord.z / coord.w;
  return light_z > scene_z - fwidth(scene_z) ? 1 : 0;
}

float vsm (sampler2D lightmap, vec4 coord) {
  coord = proj(coord);
	vec2 moments = texture(lightmap, coord.xy, 0).rg;
	if (coord.z <= moments.x) return 1.0 ;
  float var = max(moments.y - (moments.x * moments.x), 0.000001);
  float p = coord.z - moments.x;
  return var / (var + p * p);
}

#define ESM_EXPONENTIAL 10

float esm (sampler2D lightmap, vec4 coord) {
  coord = proj(coord);
	float occ = texture(lightmap, coord.xy, 0).b;
  return occ * exp(-ESM_EXPONENTIAL * coord.z);
}
