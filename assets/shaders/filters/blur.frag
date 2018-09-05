
uniform vec2 blurdir;
uniform sampler2D colormap;
uniform sampler2D depthmap;
in vec2 uv0;

out vec4 blurred;

#define blursize 32

void main () {
  blurred = texture(colormap, uv0);
  float w = 0.01, s = 1.0;
  float d = texture(depthmap, uv0).r;
  for (int i = 0; i < blursize; ++i) {
    vec2 bscale = blurdir * i * fwidth(uv0) * 3;
    vec4 x = texture(colormap, uv0 + bscale) + texture(colormap, uv0 - bscale);
    if (length(x) > 2.0) {
      w *= 0.9;
      s += w * 2;
      blurred += w * x;
    }
  }
  blurred /= s;
}
