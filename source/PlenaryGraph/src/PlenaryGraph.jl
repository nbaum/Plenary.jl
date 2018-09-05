__precompile__()
module PlenaryGraph
  typealias Maybe{T} Union{Void, T}
  using PlenaryGL
  using PlenaryMath
  import GLFW
  include("macros.jl")
  include("context.jl")
  include("clear.jl")
  include("uniforms.jl")
  include("mesh.jl")
  include("primitives.jl")
  include("transform.jl")
  include("material.jl")
  include("renderpass.jl")
  include("precompile.jl")
end
