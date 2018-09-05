export label!, label, debug

function label!(object, label::String)
  glObjectLabel(labeltype(object), name(object), length(label), pointer(label))
  object
end

function label(object)
  len = GLsizei[0]
  glGetObjectLabel(labeltype(object), name(object), 8192, pointer(len), C_NULL)
  if len[] == 0
    "unlabeled object"
  else
    buffer = Array{UInt8}(len[] + 1)
    glGetObjectLabel(labeltype(object), name(object), len[] + 1, C_NULL, pointer(buffer))
    String(buffer)
  end
end

labeltype(::Buffer) = GL_BUFFER
labeltype(::Framebuffer) = GL_FRAMEBUFFER
labeltype(::Program) = GL_PROGRAM
# labeltype(::Query) = GL_QUERY
labeltype(::Renderbuffer) = GL_RENDERBUFFER
# labeltype(::Sampler) = GL_SAMPLER
labeltype(::Shader) = GL_SHADER
labeltype(::Texture) = GL_TEXTURE
labeltype(::VertexArray) = GL_VERTEX_ARRAY

type ContextLostError <: Exception end
type EnumError <: Exception end
type ValueError <: Exception end
type OperationError <: Exception end
type FramebufferError <: Exception end
type StackUnderflowError <: Exception end

gl_error_types = Dict(
  GL_CONTEXT_LOST => ContextLostError,
  GL_INVALID_ENUM => EnumError,
  GL_INVALID_VALUE => ValueError,
  GL_INVALID_OPERATION => OperationError,
  GL_INVALID_FRAMEBUFFER_OPERATION => FramebufferError,
  GL_OUT_OF_MEMORY => OutOfMemoryError,
  GL_STACK_OVERFLOW => StackOverflowError,
  GL_STACK_UNDERFLOW => StackUnderflowError,
)

function checkerror()
  code = glGetError()
  if code == GL_NO_ERROR
    return
  else
    throw(gl_error_types[code]())
  end
end

function debug(message::String;
               id::GLuint = GLuint(0),
               high::Bool = false,
               medium::Bool = false,
               low::Bool = true,
               perf::Bool = true,
               typ::GLenum = perf ? GL_DEBUG_TYPE_PERFORMANCE : GL_DEBUG_TYPE_OTHER,
               severity::GLenum = high ? GL_DEBUG_SEVERITY_HIGH : medium ? GL_DEBUG_SEVERITY_MEDIUM : low ? GL_DEBUG_SEVERITY_LOW : GL_DEBUG_SEVERITY_NOTIFICATION)
  glDebugMessageInsert(GL_DEBUG_SOURCE_APPLICATION, typ, id, severity, length(message), pointer(message))
end
