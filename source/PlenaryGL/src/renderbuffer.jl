export Renderbuffer

immutable Renderbuffer <: RenderTarget
  name::GLuint
end

Renderbuffer() = deleter(Renderbuffer(getone(GLuint, v -> glCreateRenderbuffers(1, v))))

Renderbuffer(width, height, iformat) = begin
  r = Renderbuffer()
  storage!(r, iformat, width, height)
  r
end

Renderbuffer(width, height, samples, iformat) = begin
  r = Renderbuffer()
  storage!(r, samples, iformat, width, height)
  r
end

name(renderbuffer::Renderbuffer) = renderbuffer.name
delete(renderbuffer::Renderbuffer) = glDeleteRenderbuffers(1, name(renderbuffer))
delete(renderbuffers::Vector{Renderbuffer}) = glDeleteRenderbuffers(length(renderbuffers), name.(renderbuffers))
valid(renderbuffer::Renderbuffer) = glIsRenderbuffer(name(renderbuffer))

storage!(renderbuffer::Renderbuffer, samples::Integer, internalformat::GLenum, width::Integer, height::Integer) = glNamedRenderbufferStorageMultisample(name(renderbuffer), samples, internalformat, width, height)
storage!(renderbuffer::Renderbuffer, internalformat::GLenum, width::Integer, height::Integer) = glNamedRenderbufferStorage(name(renderbuffer), internalformat, width, height)

set!(renderbuffer::Renderbuffer, pname::GLenum, param::GLint) = glNamedRenderbufferParameteri(name(renderbuffer), pname, param)

get(renderbuffer::Renderbuffer, pname::GLenum) = getone(GLint, v -> glGetNamedRenderbufferParameteriv(name(renderbuffer), pname, v))

width(renderbuffer::Renderbuffer) = get(renderbuffer, GL_RENDERBUFFER_WIDTH)
height(renderbuffer::Renderbuffer) = get(renderbuffer, GL_RENDERBUFFER_HEIGHT)
internalformat(renderbuffer::Renderbuffer) = get(renderbuffer, GL_RENDERBUFFER_INTERNALFORMAT)
samples(renderbuffer::Renderbuffer) = get(renderbuffer, GL_RENDERBUFFER_SAMPLES)
