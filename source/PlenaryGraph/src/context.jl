export Context
export doframe
export render

type Context{T}
  window::GLFW.Window
  width::Integer
  height::Integer
  uniforms::T
  program::Maybe{Program}
  framenum::Int
  timedelta::Float64
  renderpass::String
end

const GLFW_AUTO_ICONIFY = 0x00020006

function Context(; title = "OpenGL Example", fullscreen = true, width = nothing, height = nothing)
  GLFW.Init()
  monitor = GLFW.GetPrimaryMonitor()
  mode = GLFW.GetVideoMode(monitor)
  width = @coalesce(width, mode.width)
  height = @coalesce(height, mode.height)
  GLFW.WindowHint(GLFW.SAMPLES, 16)
  GLFW.WindowHint(GLFW.CLIENT_API, GLFW.OPENGL_API)
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 4)
  GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 5)
  GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, true)
  GLFW.WindowHint(GLFW.STENCIL_BITS, 32)
  GLFW.WindowHint(GLFW_AUTO_ICONIFY, false);
  GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
  window = GLFW.CreateWindow(width, height, title, (fullscreen ? [monitor] : [])...)
  GLFW.MakeContextCurrent(window)
  GLFW.ShowWindow(window)
  GLFW.SwapInterval(1)
  installdebugcallback()
  glEnable(GL_DEBUG_OUTPUT)
  glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0x00000000, C_NULL, 0x01)
  glViewport(0, 0, width, height)
  Finalizer.wrap(Context(window, width, height, DefaultUniforms(), nothing, 0, 0.0, ""))
end

function installdebugcallback()
  glDebugMessageCallback(cfunction(debugcallback, Void, (GLenum, GLenum, GLint, GLenum, GLsizei, Ptr{UInt8}, Ptr{Void})), C_NULL)
end

TYPES = Dict(
  GL_DEBUG_TYPE_ERROR               => "E",
  GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR => "D",
  GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR  => "U",
  GL_DEBUG_TYPE_PERFORMANCE         => "P",
  GL_DEBUG_TYPE_PORTABILITY         => "p",
  GL_DEBUG_TYPE_MARKER              => "M",
  GL_DEBUG_TYPE_PUSH_GROUP          => "G",
  GL_DEBUG_TYPE_POP_GROUP           => "g",
  GL_DEBUG_TYPE_OTHER               => "O",
)

SEVERITIES = Dict(
  GL_DEBUG_SEVERITY_HIGH         => ("H", :red),
  GL_DEBUG_SEVERITY_MEDIUM       => ("M", :yellow),
  GL_DEBUG_SEVERITY_LOW          => ("L", :normal),
  GL_DEBUG_SEVERITY_NOTIFICATION => ("N", :black),
)

function debugcallback(source::GLenum, typ::GLenum, id::GLint, severity::GLenum, length::GLsizei, msgptr::Ptr{UInt8}, userParam::Ptr{Void})
  message = Array{UInt8}(length)
  unsafe_copy!(pointer(message), msgptr, length)
  message = @sprintf("%s %s %6i %s\n", SEVERITIES[severity][1], TYPES[typ], id, String(message))
  # print_with_color(SEVERITIES[severity][2], message)
  nothing::Void
end

function doframe(f, ctx::Context)
  ctx.framenum += 1
  f()
 	GLFW.PollEvents()
  GLFW.SwapBuffers(ctx.window)
  if GLFW.GetKey(ctx.window, GLFW.KEY_ESCAPE) == GLFW.PRESS
    GLFW.SetWindowShouldClose(ctx.window, true)
  end
  return !GLFW.WindowShouldClose(ctx.window)
end

function render(ctx::Context, vec::Vector; kwargs...)
  for elem in vec
    render(ctx, elem; kwargs...)
  end
end

@generated function render(ctx::Context, f::Function)
  if !isdefined(f, :instance)
    quote
      if method_exists(f, (Context, ))
        f(ctx)
      elseif method_exists(f, ())
        f()
      else
        throw(MethodError)
      end
    end
  elseif method_exists(f.instance, (Context, ))
    :(f(ctx))
  elseif method_exists(f.instance, ())
    :(f())
  else
    throw(MethodError)
  end
end

function render(ctx::Context, program::Program)
  if ctx.program != program
    use(program)
    dirty!(ctx.uniforms)
    ctx.program = program
  end
end

function render(ctx::Context, fb::Framebuffer)
  ctx["buffer"] = fb.name
  bind!(fb)
end

Base.getindex(ctx::Context, name::String) = ctx.uniforms[name]

Base.setindex!(ctx::Context, value, name::String) = ctx.uniforms[name] = value
