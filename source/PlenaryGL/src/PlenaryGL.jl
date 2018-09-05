__precompile__()
module PlenaryGL
  using PlenaryMath
  import Base: length, eltype
  include("glcore.jl")
  include("glext.jl")
  include("utils.jl")
  # include("sync.jl")
  include("buffer.jl")
  # include("execution.jl")
  # include("query.jl")
  # include("sampler.jl")
  include("named_string.jl")
  include("shader.jl")
  include("program.jl")
  # include("program_pipeline.jl")
  include("texture.jl")
  include("renderbuffer.jl")
  include("framebuffer.jl")
  include("vertex_array.jl")
  include("state.jl")
  include("debugging.jl")
end
