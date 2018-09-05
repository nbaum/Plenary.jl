#include "/common.glsl"

uniform sampler3D voxelmap;
uniform int chunksize;

void vertex (inout FragData frag) {
  int x = gl_InstanceID % chunksize;
  int y = (gl_InstanceID / chunksize) % chunksize;
  int z = (gl_InstanceID / (chunksize * chunksize)) % chunksize;
  frag.localpos.xyz += vec3(x, y, -z) - vec3(chunksize / 2, chunksize / 2, -chunksize / 2);
  vec3 chunkpos = vec3(x, y, z) / chunksize;
  frag.color0 = vec4(texture(voxelmap, vec3(x, y, z) / float(chunksize)));
  // if (frag.color0.r > chunkpos.z) shouldDiscard = true;
  if (frag.color0.r >= pow(chunkpos.z, 2)) shouldDiscard = true;
}
