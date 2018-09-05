
function inside{T <: SVector}(A::T, B::T, C::T, P::T)
  a = cross(A - B, A - C)
  b = cross(P - B, P - C)
  any((a .* b) .< 0) && return false
  c = cross(P - C, P - A)
  d = cross(P - A, P - B)
  any((a .* b) .< 0) && return false
  any((a .* c) .< 0) && return false
  any((a .* d) .< 0) && return false
  return true
end

function snip{N, T}(contour::Vector{SVector{N, T}}, u, v, w, n, V)
  A = contour[V[u]]
  B = contour[V[v]]
  C = contour[V[w]]
  # x = (((B[1] - A[1]) * (C[2] - A[2])) - ((B[2] - A[2]) * (C[1] - A[1])))
  # 0.0000000001f0 > x && return false
  for p = 1:n
    ((p == u) || (p == v) || (p == w)) && continue
    P = contour[V[p]]
    inside(A, B, C, P) && return false
  end
  true
end

function triangulate(contour::Vector{SVector{3, Float64}})
  result = Int32[]
  n = length(contour)
  # V = 0 < area(contour) ? Int[i for i = 1:n] : Int[i for i = n:-1:1]
  V = Int[i for i = 1:n]
  nv = n
  count = 2 * nv
  v = nv
  while nv > 2 && count > 0
    count -= 1
    u = v; (u > nv) && (u = 1)
    v = u + 1; (v > nv) && (v = 1)
    w = v + 1; (w > nv) && (w = 1)
    if snip(contour, u, v, w, nv, V)
      a = V[u]; b = V[v]; c = V[w];
      push!(result, a, b, c)
      s = v; t = v + 1
      while t <= nv
        V[s] = V[t]
        s += 1; t += 1
      end
      nv -= 1
      count = 2 * nv
    end
  end
  result
end
