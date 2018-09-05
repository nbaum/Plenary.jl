in vec3 position;
out vec2 uv0;

void main() {
  gl_Position = vec4(2 * position.xy - 1, 0, 1);
  uv0 = position.xy;
}
