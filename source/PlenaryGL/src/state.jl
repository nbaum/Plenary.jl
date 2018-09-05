
use(framebuffer::Framebuffer) = glBindFramebuffer(GL_FRAMEBUFFER, name(framebuffer))
use(texture::Texture, unit::GLuint) = glBindTextureUnit(unit, name(texture))
use(vertexarray::VertexArray) = glBindVertexArray(name(vertexarray))
