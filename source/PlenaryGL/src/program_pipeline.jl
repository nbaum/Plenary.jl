export ProgramPipeline, delete, attach!

immutable ProgramPipeline
  name::GLuint
  programs::Vector{Program}
end

function ProgramPipeline(; vertex::Program = nothing, fragment::Program = nothing)
  p = deleter(ProgramPipeline(glCreateProgramPipeline()))
  vertex != nothing && attach!(p, GL_VERTEX_SHADER_BIT, vertex)
  fragment != nothing && attach!(p, GL_FRAGMENT_SHADER_BIT, fragment)
  p
end

delete(pp::ProgramPipeline) = glDeleteProgramPipeline(pp)

function attach!(pp::ProgramPipeline, stages::GLbitfield, p::Program)
  glUseProgramStages(pp.name, stages, p.name)
end

bind!(pp::ProgramPipeline) = glBindProgramPipeline(pp)
