export Shader

immutable Shader{T}
  name::GLuint
  file::String
  Shader(source::String, file::String = "(string input)", line::Integer = 1) = begin
    s = deleter(new(glCreateShader(T), file))
    source!(s, "#version 450\n#extension GL_ARB_shading_language_include : require\n$(preamble(s))\n#line $line $(repr(file))\n", source)
    compile!(s)
    s
  end
end

name(shader::Shader) = shader.name
delete(shader::Shader) = glDeleteShader(shader)

source!(shader::Shader, sources::String...) = glShaderSource(name(shader), length(sources), pointer([pointer(source) for source in sources]), C_NULL)
compile!(shader::Shader) = glCompileShader(name(shader))
binary!(ss::Vector{Shader}, bs::Vector{UInt8}, format::GLenum) = glShaderBinary(length(ss), ss, format, bs, length(bs))

get(shader::Shader, pname::GLenum) = getone(GLuint, v -> glGetShaderiv(name(shader), pname, v))

Base.show(io::IO, s::Shader{GL_FRAGMENT_SHADER}) = print(io, "Fragment $(repr(s.file))")
Base.show(io::IO, s::Shader{GL_VERTEX_SHADER}) = print(io, "Vertex $(repr(s.file))")
Base.show(io::IO, s::Shader{GL_GEOMETRY_SHADER}) = print(io, "Geometry $(repr(s.file))")

preamble(s::Shader{GL_FRAGMENT_SHADER}) = "#define FRAGMENT_SHADER 1"
preamble(s::Shader{GL_VERTEX_SHADER})   = "#define VERTEX_SHADER   1"
preamble(s::Shader{GL_GEOMETRY_SHADER}) = "#define GEOMETRY_SHADER 1"
