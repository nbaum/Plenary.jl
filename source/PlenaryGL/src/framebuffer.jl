export Framebuffer

immutable Framebuffer
  name::GLuint
  samples::Int
end

Framebuffer(n) = Framebuffer(n, 1)

DEFAULT_FRAMEBUFFER = Framebuffer(0)

function Framebuffer(; color::Maybe{RenderTarget} = nothing,
                       colors::Maybe{Vector{RenderTarget}} = nothing,
                       depth::Maybe{RenderTarget} = nothing,
                       stencil::Maybe{RenderTarget} = nothing,
                       depthstencil::Maybe{RenderTarget} = nothing,
                       samples::Integer = 1)
  fb = deleter(Framebuffer(getone(GLuint, v -> glCreateFramebuffers(1, v)), samples))
  if colors != nothing
    for i in 1:length(colors)
      attach!(fb, colors[i], GL_COLOR_ATTACHMENT0 + i)
    end
  end
  color != nothing && attach!(fb, color, GL_COLOR_ATTACHMENT0)
  depth != nothing && attach!(fb, depth, GL_DEPTH_ATTACHMENT)
  stencil != nothing && attach!(fb, stencil, GL_STENCIL_ATTACHMENT)
  depthstencil != nothing && attach!(fb, depthstencil, GL_DEPTH_STENCIL_ATTACHMENT)
  fb
end

name(framebuffer::Framebuffer) = framebuffer.name
delete(framebuffer::Framebuffer) = glDeleteFramebuffers(1, name(framebuffer))
delete(framebuffers::Vector{Framebuffer}) = glDeleteTextures(length(framebuffers), name.(framebuffers))
valid(framebuffer::Framebuffer) = glIsFramebuffer(name(framebuffer))

set!(framebuffer::Framebuffer, pname::GLenum, param::Integer) = glNamedFramebufferParameteri(name(framebuffer), pname, param)

get(framebuffer::Framebuffer, pname::GLenum) = getone(GLint, v -> glGetNamedFramebufferParameteriv(name(framebuffer), pname, v))

attach!(framebuffer::Framebuffer, renderbuffer::Renderbuffer, attachment::GLenum) = glNamedFramebufferRenderbuffer(name(framebuffer), attachment, GL_RENDERBUFFER, name(renderbuffer))

attach!(renderbuffer::Renderbuffer, framebuffer::Framebuffer, attachment::GLenum) = attach(framebuffer, renderbuffer, attachment)

attach!{TextureTarget}(framebuffer::Framebuffer, texture::Texture{TextureTarget}, attachment::GLenum, level::Integer = 0) =
    if framebuffer.samples > 1
      glNamedFramebufferTexture2DMultisampleEXT(name(framebuffer), attachment, TextureTarget, name(texture), level, framebuffer.samples)
    else
      glNamedFramebufferTexture(name(framebuffer), attachment, name(texture), level)
    end

attach!(texture::Texture, framebuffer::Framebuffer, attachment::GLenum, level::Integer = 0) =
    attach(framebuffer, texture, attachment, level)

bind!(framebuffer::Framebuffer, target::GLenum = GL_FRAMEBUFFER) = glBindFramebuffer(target, name(framebuffer))
