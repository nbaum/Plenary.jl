export Program, delete, attach!, detach!, detachall!, link!, use, valid, infolog, input, uniform, output, uniform!

immutable Program
  name::GLuint
  shaders::Set{Shader}
end

function Program(shaders::Shader...)
  program = deleter(Program(glCreateProgram(), Set{Shader}()))
  if !isempty(shaders)
    for shader in shaders
      attach!(program, shader)
    end
    link!(program)
  end
  program
end

function Base.show(io::IO, p::Program)
  print(io, "Program (")
  join(io, p.shaders, ", ")
  print(io, ")")
end

GLuint(program::Program) = program.name

delete(program::Program) = glDeleteProgram(program)

function attach!(program::Program, shader::Shader)
  glAttachShader(program, name(shader))
  union!(program.shaders, [shader])
end

function detachall!(program::Program)
  for shader in program.shaders
    detach!(program, shader)
  end
end

function detach!(program::Program, shader::Shader)
  glDetachShader(program, name(shader))
  setdiff!(program.shaders, [shader])
end

function link!(program::Program)
  glLinkProgram(program)
  valid(program) || print_with_color(:red, infolog(program))
end

use(program::Program) = glUseProgram(program)

get(program::Program, pname::GLenum) = getone(GLuint, v -> glGetProgramiv(program, pname, v))

valid(program::Program) = get(program, GL_VALIDATE_STATUS) == 1
loglength(program::Program) = get(program, GL_INFO_LOG_LENGTH)

function infolog(program::Program)
  buff = Array{UInt8}(loglength(program))
  glGetProgramInfoLog(program, length(buff), C_NULL, pointer(buff))
  String(buff)
end

function location(program::Program, programInterface::GLenum, name::String, kind::String = "resource")
  loc = glGetProgramResourceLocation(program, programInterface, pointer(name))
  if loc == -1
    # debug("shader $kind `$name' not found")
    nothing
  else
    loc
  end
end

input(program::Program, name::String) = location(program, GL_PROGRAM_INPUT, name, "input")
uniform(program::Program, name::String) = location(program, GL_UNIFORM, name, "uniform")
output(program::Program, name::String) = location(program, GL_PROGRAM_OUTPUT, name, "output")

subroutine(program::Program, shadertype::GLenum, name::String) = glGetSubroutineIndex(program, shadertype, name)
subroutine_uniform(program::Program, shadertype::GLenum, name::String) = glGetSubroutineUniformLocation(program, shadertype, name)

uniform!(program::Program, location::GLint, value::GLint64) = glProgramUniform1i(program, location, value)
uniform!(program::Program, location::GLint, value::GLuint64) = glProgramUniform1u(program, location, value)
uniform!(program::Program, location::GLint, value::GLint) = glProgramUniform1i(program, location, value)
uniform!(program::Program, location::GLint, value::GLuint) = glProgramUniform1ui(program, location, value)
uniform!(program::Program, location::GLint, value::GLfloat) = glProgramUniform1f(program, location, value)
uniform!(program::Program, location::GLint, value::GLdouble) = glProgramUniform1d(program, location, value)

uniform!(program::Program, location::GLint, value::Vec{2, GLint}) = glProgramUniform2iv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{2, GLuint}) = glProgramUniform2uiv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{2, GLfloat}) = glProgramUniform2fv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{2, GLdouble}) = glProgramUniform2dv(program, location, 1, pointer(value))

uniform!(program::Program, location::GLint, value::Vec{3, GLint}) = glProgramUniform3iv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{3, GLuint}) = glProgramUniform23iv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{3, GLfloat}) = glProgramUniform3fv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{3, GLdouble}) = glProgramUniform3dv(program, location, 1, pointer(value))

uniform!(program::Program, location::GLint, value::Vec{4, GLint}) = glProgramUniform4iv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{4, GLuint}) = glProgramUniform4uiv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{4, GLfloat}) = glProgramUniform4fv(program, location, 1, pointer(value))
uniform!(program::Program, location::GLint, value::Vec{4, GLdouble}) = glProgramUniform4dv(program, location, 1, pointer(value))

uniform!(program::Program, location::GLint, value::Mat{4, 4, GLfloat}, transpose::GLboolean = GL_FALSE) = glProgramUniformMatrix4fv(program, location, 1, transpose, pointer(value))
uniform!(program::Program, location::GLint, value::Mat{4, 4, GLdouble}, transpose::GLboolean = GL_FALSE) = glProgramUniformMatrix4dv(program, location, 1, transpose, pointer(value))

uniform!(program::Program, location::GLint, value::Function) = uniform!(program, location, value())

uniform!(program::Program, name::String, value) = uniform!(program, uniform(program, name), value)

uniform!(program::Program, ::Void, value) = nothing
uniform!(::Void, name, value) = nothing

uniform!(id::Union{GLint, String}, value) = uniform!(Program(getint(GL_CURRENT_PROGRAM)), id, value)
