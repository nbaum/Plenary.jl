#include "/common.glsl"

uniform sampler2D colormap;
uniform sampler2D depthmap;

in vec2 uv0;

out vec4 fragColour;

float ssao(sampler2D map, vec2 uv) {
  float n = 0, t = 0;
  float d = texture(map, uv).r;
  float dp = fwidth(d);
  d -= dp;
  float q = 0.001;
  for (int x = -samples; x <= samples; ++x) {
    for (int y = -samples; y <= samples; ++y) {
      if (x != 0 && y != 0) {
        float l = length(vec2(x, y));
        float e = texture(map, uv + vec2(x, y) / size, lod).r;
        float f = abs(d - e);
        if (f <= q) {
          if (d > e) t += (1.0 / l) * smoothstep(q, 0.0, f);
        }
        n += 1.0 / l;
      }
    }
  }
  d = 1 - (t / n);
  return d;
}

void main() {
  float ao = ssao(depthmap, uv0);
  fragColour = vec4(texture(colormap, uv0).rgb, 1) * ao;
}
