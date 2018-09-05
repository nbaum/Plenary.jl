
immutable Sampler
  name::GLuint
end

Sampler() = finalizer(Sampler(getone(GLuint, v -> glCreateSamplers(1, v))))

name(sampler::Sampler) = sampler.name
delete(sampler::Sampler) = glDeleteSamplers(1, name(sampler))
delete(samplers::Vector{Sampler}) = glDeleteSamplers(length(samplers), name.(samplers))
valid(sampler::Sampler) = glIsSampler(name(sampler))

bind(unit::GLuint, sampler::Sampler) = glBindSampler(unit, name(sampler))
bind(unit::GLuint, samplers::Vector{Sampler}) = glBindSamplers(unit, length(samplers), name.(samplers))

set(sampler::Sampler, pname::GLenum, param::GLint) = glSamplerParameteri(name(sampler), pname, param)
set(sampler::Sampler, pname::GLenum, param::GLfloat) = glSamplerParameterf(name(sampler), pname, param)

filters(sampler::Sampler, min::GLenum, mag::GLenum) = set(sampler, GL_MIN_FILTER, min), set(sampler, GL_MAG_FILTER, mag)
wrap(sampler::Sampler, s::GLenum, t::GLenum, r::GLenum) = set(sampler, GL_WRAP_S, s), set(sampler, GL_WRAP_T, t), set(sampler, GL_WRAP_R, r)
