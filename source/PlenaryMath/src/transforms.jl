
function ortho(size, aspect, near, far)
  m = Mat4f([aspect * 2 / size 0     0             0
         0     2 / size 0             0
         0     0     -2 / (far - near)  (- (far + near) / (far - near))
         0     0     0             1])
end

function perspective(fov, aspect, near, far)
  range = tan(fov / 2) * near
  sy = near / range
  sx = sy * aspect
  sz = -(far + near) / (far - near)
  pz = -(2 * far * near) / (far - near)
  Mat4f([sx  0   0   0
         0   sy  0   0
         0   0   sz  pz
         0   0   -1  0])
end

function scale(x, y = x, z = x)
  Mat4f([x 0 0 0
         0 y 0 0
         0 0 z 0
         0 0 0 1])
end

function translate(x, y = x, z = x)
  Mat4f([1 0 0 x
         0 1 0 y
         0 0 1 z
         0 0 0 1])
end

function rotate(angle, x, y, z)
  c = cos(angle)
  s = sin(angle)
  t = 1 - c
  tx = t * x
  ty = t * y
  tz = t * z
  txx = tx * x
  txy = tx * y
  txz = tx * z
  tyy = ty * y
  tyz = ty * z
  tzz = tz * z
  sx = s * x
  sy = s * y
  sz = s * z
  Mat4f([(txx + c)  (txy - sz) (txz + sy) 0
         (txy + sz) (tyy + c)  (tyz - sx) 0
         (txz - sy) (tyz + sx) (tzz + c)  0
         0          0          0          1])
end


rotate(x, y, z) = rotx(x) * roty(y) * rotz(z)

rotx(a) = rotate(a, 1, 0, 0)
roty(a) = rotate(a, 0, 1, 0)
rotz(a) = rotate(a, 0, 0, 1)

const identity = scale(1)
