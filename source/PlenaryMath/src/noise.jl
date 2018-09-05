export Noise, fbm

type Noise
  perms::Vector{Vector{UInt8}}
  lacunarity::Float64
  gain::Float64
end

Noise(rng::AbstractRNG, octaves::Int64, lacunarity::Float64, gain::Float64) = Noise([Simplex.Permutation(rand(rng, UInt32)) for i = 1:octaves], lacunarity, gain)
Noise(; octaves::Int64 = 1, lacunarity::Float64 = 2.0, gain::Float64 = 0.5, seed::Int64 = 0) = Noise(MersenneTwister(seed), octaves, lacunarity, gain)

fbm{T<:AbstractFloat}(n::Noise, x::T, y::T, z::T, w::T) = begin
  t, s, c = T(0), T(1), T(0)
  for perm in n.perms
    t += Simplex.noise(perm, x, y, z, w) * s
    c += s
    s *= n.gain
    x *= n.lacunarity
    y *= n.lacunarity
    z *= n.lacunarity
    w *= n.lacunarity
  end
  t / c
end

fbm{T<:AbstractFloat}(n::Noise, x::T, y::T, z::T) = begin
  t, s, c = T(0), T(1), T(0)
  for perm in n.perms
    t += Simplex.noise(perm, x, y, z) * s
    c += s
    s *= n.gain
    x *= n.lacunarity
    y *= n.lacunarity
    z *= n.lacunarity
  end
  t / c
end

fbm{T<:AbstractFloat}(n::Noise, x::T, y::T) = begin
  t, s, c = T(0), T(1), T(0)
  for perm in n.perms
    t += Simplex.noise(perm, x, y) * s
    c += s
    s *= n.gain
    x *= n.lacunarity
    y *= n.lacunarity
  end
  t / c
end

fbm{T<:AbstractFloat}(n::Noise, x::T) = begin
  t, s, c = T(0), T(1), T(0)
  for perm in n.perms
    t += Simplex.noise(perm, x) * s
    c += s
    s *= n.gain
    x *= n.lacunarity
  end
  t / c
end
