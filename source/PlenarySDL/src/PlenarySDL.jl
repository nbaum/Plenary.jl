__precompile__()
module PlenarySDL
  module SDL
    include("macros.jl")
    include("types.jl")
    include("sdl.jl")
    include("video.jl")
    include("opengl.jl")
    include("events.jl")
    include("image.jl")
  end
  export SDL
end
