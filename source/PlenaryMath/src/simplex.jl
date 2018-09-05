module Simplex

Permutation(seed) = (a = shuffle(MersenneTwister(seed), collect(0:255)); UInt8[a; a])

function grad(h, x)
  h &= 15
  g = 1 + (h & 7)
  g = h & 8 == 8 ? -g : g
  g * x
end

function grad(h, x, y)
  h &= 7
  u = h < 4 ? x : y
  v = h < 4 ? y : x
  (h & 1 == 1 ? -u : u) + (h & 2 == 2 ? -2v : 2v)
end

function grad(h, x, y, z)
  h &= 15
  u = h < 8 ? x : y
  v = h < 4 ? y : (h == 12 || h == 14) ? x : z
  (h & 1 == 1 ? -u : u) + (h & 2 == 2 ? -v : v)
end

function grad(h, x, y, z, w)
  h &= 31
  u = h < 24 ? x : y
  v = h < 16 ? y : z
  s = h < 8 ? z : w
  (h & 1 == 1 ? -u : u) + (h & 2 == 2 ? -v : v) + (h & 4 == 4 ? -v : v)
end

const simplex = [
  [0, 1, 2, 3],  [0, 1, 3, 2],  [0, 0, 0, 0],  [0, 2, 3, 1],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],
  [1, 2, 3, 0],  [0, 2, 1, 3],  [0, 0, 0, 0],  [0, 3, 1, 2],  [0, 3, 2, 1],  [0, 0, 0, 0],  [0, 0, 0, 0],
  [0, 0, 0, 0],  [1, 3, 2, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],
  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [1, 2, 0, 3],  [0, 0, 0, 0],  [1, 3, 0, 2],  [0, 0, 0, 0],
  [0, 0, 0, 0],  [0, 0, 0, 0],  [2, 3, 0, 1],  [2, 3, 1, 0],  [1, 0, 2, 3],  [1, 0, 3, 2],  [0, 0, 0, 0],
  [0, 0, 0, 0],  [0, 0, 0, 0],  [2, 0, 3, 1],  [0, 0, 0, 0],  [2, 1, 3, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],
  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [2, 0, 1, 3],
  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [3, 0, 1, 2],  [3, 0, 2, 1],  [0, 0, 0, 0],  [3, 1, 2, 0],
  [2, 1, 0, 3],  [0, 0, 0, 0],  [0, 0, 0, 0],  [0, 0, 0, 0],  [3, 1, 0, 2],  [0, 0, 0, 0],  [3, 2, 0, 1],
  [3, 2, 1, 0]
]

function noise(perm, x)
  i0 = floor(Int, x)
  i1 = i0 + 1
  x0 = x - i0
  x1 = x0 - 1
  t0 = (1 - x0 ^ 2) ^ 4
  @inbounds n0 = t0 * grad(perm[i0 & 0xff + 1], x0)
  t1 = (1 - x1 ^ 2) ^ 4
  @inbounds n1 = t1 * grad(perm[i1 & 0xff + 1], x1)
  0.395 * (n0 + n1)
end

const F2 = 0.5 * (sqrt(3.0) - 1.0)
const G2 = (3.0 - sqrt(3.0)) / 6.0

function noise(perm, x, y)
  s = (x + y) * F2
  xs = x + s
  ys = y + s
  i = floor(Int, xs)
  j = floor(Int, ys)
  t = (i + j) * G2
  X0 = i - t
  Y0 = j - t
  x0 = x - X0
  y0 = y - Y0
  if x0 > y0
    i1, j1 = 1, 0
  else
    i1, j1 = 0, 1
  end
  x1 = x0 - i1 + G2
  y1 = y0 - j1 + G2
  x2 = x0 - 1 + 2 * G2
  y2 = y0 - 1 + 2 * G2
  ii = i & 0xff
  jj = j & 0xff
  t0 = 0.5 - x0 * x0 - y0 * y0
  if t0 < 0.0
    n0 = 0.0
  else
    @inbounds n0 = t0 ^ 4 * grad(perm[ii + perm[jj + 1] + 1], x0, y0)
  end
  t1 = 0.5 - x1 * x1 - y1 * y1
  if t1 < 0.0
    n1 = 0.0
  else
    @inbounds n1 = t1 ^ 4 * grad(perm[ii + i1 + perm[jj + j1 + 1] + 1], x1, y1)
  end
  t2 = 0.5 - x2 * x2 - y2 * y2
  if t2 < 0.0
    n2 = 0.0
  else
    @inbounds n2 = t2 ^ 4 * grad(perm[ii + perm[jj + 2] + 2], x2, y2);
  end
  45.0 * (n0 + n1 + n2);
end

const F3 = 0.333333333
const G3 = 0.166666667

function noise(perm, x, y, z)
  s = (x + y +  z) * F3
  xs = x + s
  ys = y + s
  zs = z + s
  i = floor(Int, xs)
  j = floor(Int, ys)
  k = floor(Int, zs)
  t = (i + j + k) * G3
  X0 = i - t
  Y0 = j - t
  Z0 = k - t
  x0 = x - X0
  y0 = y - Y0
  z0 = z - Z0
  if x0 >= y0
    if y0 >= z0
      i1, j1, k1, i2, j2, k2 = 1, 0, 0, 1, 1, 0
    elseif x0 >= z0
      i1, j1, k1, i2, j2, k2 = 1, 0, 0, 1, 0, 1
    else
      i1, j1, k1, i2, j2, k2 = 0, 0, 1, 1, 0, 1
    end
  else
    if y0 < z0
      i1, j1, k1, i2, j2, k2 = 0, 0, 1, 0, 1, 1
    elseif x0 < z0
      i1, j1, k1, i2, j2, k2 = 0, 1, 0, 0, 1, 1
    else
      i1, j1, k1, i2, j2, k2 = 0, 1, 0, 1, 1, 0
    end
  end
  x1 = x0 - i1 + G3
  y1 = y0 - j1 + G3
  z1 = z0 - k1 + G3
  x2 = x0 - i2 + 2G3
  y2 = y0 - j2 + 2G3
  z2 = z0 - k2 + 2G3
  x3 = x0 - 1.0 + 3G3
  y3 = y0 - 1.0 + 3G3
  z3 = z0 - 1.0 + 3G3
  ii = i & 0xff
  jj = j & 0xff
  kk = k & 0xff
  t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0
  if t0 < 0.0
    n0 = 0.0
  else
    t0 *= t0
    @inbounds n0 = t0 * t0 * grad(perm[ii + 1 + perm[jj + 1 + perm[kk + 1]]], x0, y0, z0)
  end
  t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1
  if t1 < 0.0
    n1 = 0.0
  else
    t1 *= t1
    @inbounds n1 = t1 * t1 * grad(perm[ii + i1 + 1 + perm[jj + j1 + 1 + perm[kk + k1 + 1]]], x1, y1, z1)
  end
  t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2
  if t2 < 0.0
    n2 = 0.0
  else
    t2 *= t2
    @inbounds n2 = t2 * t2 * grad(perm[ii + i2 + 1 + perm[jj + j2 + 1 + perm[kk + k2 + 1]]], x2, y2, z2)
  end
  t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3
  if t3 < 0.0
    n3 = 0.0
  else
    t3 *= t3
    @inbounds n3 = t3 * t3 * grad(perm[ii + 2 + perm[jj + 2 + perm[kk + 2]]], x3, y3, z3)
  end
  return 32.0 * (n0 + n1 + n2 + n3)
end

const F4 = (sqrt(5.0) - 1.0) / 4.0
const G4 = (5.0 - sqrt(5.0)) / 20.0

function noise(perm, x, y, z, w)
  s = (x + y + z + w) * F4
  xs = x + s
  ys = y + s
  zs = z + s
  ws = w + s
  i = floor(Int, xs)
  j = floor(Int, ys)
  k = floor(Int, zs)
  l = floor(Int, ws)
  t = (i + j + k + l) * G4
  X0 = i - t
  Y0 = j - t
  Z0 = k - t
  W0 = l - t
  x0 = x - X0
  y0 = y - Y0
  z0 = z - Z0
  w0 = w - W0
  c1 = (x0 > y0) ? 32 : 0
  c2 = (x0 > z0) ? 16 : 0
  c3 = (y0 > z0) ? 8 : 0
  c4 = (x0 > w0) ? 4 : 0
  c5 = (y0 > w0) ? 2 : 0
  c6 = (z0 > w0) ? 1 : 0
  c = c1 + c2 + c3 + c4 + c5 + c6 + 1
  i1 = simplex[c][1] >= 3 ? 1 : 0
  j1 = simplex[c][2] >= 3 ? 1 : 0
  k1 = simplex[c][3] >= 3 ? 1 : 0
  l1 = simplex[c][4] >= 3 ? 1 : 0
  i2 = simplex[c][1] >= 2 ? 1 : 0
  j2 = simplex[c][2] >= 2 ? 1 : 0
  k2 = simplex[c][3] >= 2 ? 1 : 0
  l2 = simplex[c][4] >= 2 ? 1 : 0
  i3 = simplex[c][1] >= 1 ? 1 : 0
  j3 = simplex[c][2] >= 1 ? 1 : 0
  k3 = simplex[c][3] >= 1 ? 1 : 0
  l3 = simplex[c][4] >= 1 ? 1 : 0
  x1 = x0 - i1 + G4
  y1 = y0 - j1 + G4
  z1 = z0 - k1 + G4
  w1 = w0 - l1 + G4
  x2 = x0 - i2 + 2G4
  y2 = y0 - j2 + 2G4
  z2 = z0 - k2 + 2G4
  w2 = w0 - l2 + 2G4
  x3 = x0 - i3 + 3G4
  y3 = y0 - j3 + 3G4
  z3 = z0 - k3 + 3G4
  w3 = w0 - l3 + 3G4
  x4 = x0 - 1.0 + 4G4
  y4 = y0 - 1.0 + 4G4
  z4 = z0 - 1.0 + 4G4
  w4 = w0 - 1.0 + 4G4
  ii = i & 0xff
  jj = j & 0xff
  kk = k & 0xff
  ll = l & 0xff
  t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0 - w0 * w0
  if t0 < 0.0
    n0 = 0.0
  else
    t0 *= t0
    n0 = t0 * t0 * grad(perm[ii + 1 + perm[jj + 1 + perm[kk + 1 + perm[ll + 1]]]], x0, y0, z0, w0)
  end
  t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1 - w1 * w1
  if t1 < 0.0
    n1 = 0.0
  else
    t1 *= t1
    n1 = t1 * t1 * grad(perm[ii + i1 + 1 + perm[jj + j1 + 1 + perm[kk + k1 + 1 + perm[ll + l1 + 1]]]], x1, y1, z1, w1)
  end
  t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2 - w2 * w2
  if t2 < 0.0
    n2 = 0.0
  else
    t2 *= t2
    n2 = t2 * t2 * grad(perm[ii + i2 + 1 + perm[jj + j2 + 1 + perm[kk + k2 + 1 + perm[ll + l2 + 1]]]], x2, y2, z2, w2)
  end
  t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3 - w3 * w3
  if t3 < 0.0
    n3 = 0.0
  else
    t3 *= t3
    n3 = t3 * t3 * grad(perm[ii + i3 + 1 + perm[jj + j3 + 1 + perm[kk + k3 + 1 + perm[ll + l3 + 1]]]], x3, y3, z3, w3)
  end
  t4 = 0.6 - x4 * x4 - y4 * y4 - z4 * z4 - w4 * w4
  if t4 < 0.0
    n4 = 0.0
  else
    t4 *= t4
    n4 = t4 * t4 * grad(perm[ii + 2 + perm[jj + 2 + perm[kk + 2 + perm[ll + 2]]]], x4, y4, z4, w4)
  end
  return 20.0 * (n0 + n1 + n2 + n3 + n4)
end

end
