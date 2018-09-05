export Window

type Window
  window::Ptr{SDL.Window}
  context::Ptr{SDL.GLContext}
  width::Cint
  height::Cint
  function Window(title, width = 1000, height = 1000)
    SDL.Init(SDL.INIT_EVERYTHING)
    w = SDL.CreateWindow(title, 1920, 0, width, height, SDL.WINDOW_OPENGL | SDL.WINDOW_SHOWN)
    SDL.GL_SetAttribute(SDL.GL_MULTISAMPLESAMPLES, 4)
    SDL.GL_SetAttribute(SDL.GL_CONTEXT_MAJOR_VERSION, 4)
    SDL.GL_SetAttribute(SDL.GL_CONTEXT_MINOR_VERSION, 5)
    SDL.GL_SetAttribute(SDL.GL_CONTEXT_PROFILE_MASK, SDL.GL_CONTEXT_PROFILE_CORE)
    SDL.GL_SetAttribute(SDL.GL_DOUBLEBUFFER, 1)
    SDL.GL_SetAttribute(SDL.GL_CONTEXT_FLAGS, SDL.GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)
    c = SDL.GL_CreateContext(w)
    SDL.GL_SetSwapInterval(1)
    width, height = Ref{Cint}(0), Ref{Cint}(0)
    SDL.GL_GetDrawableSize(w, width, height)
    new(w, c, width[], height[])
  end
end

swap(w::Window) = SDL.GL_SwapWindow(w.window)
