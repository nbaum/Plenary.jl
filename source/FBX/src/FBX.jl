__precompile__()
module FBX
  using StaticArrays
  using Zlib
  import Base: show, read, write
  include("nodes.jl")
  include("read.jl")
  include("translate.jl")
  include("triangulate.jl")
  include("show.jl")
end
