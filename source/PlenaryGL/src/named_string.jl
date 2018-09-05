export addincludes!, addinclude!, updateincludes!

@gl_const GL_SHADER_INCLUDE_ARB      0x8DAE GLenum
@gl_const GL_NAMED_STRING_LENGTH_ARB 0x8DE9 GLenum
@gl_const GL_NAMED_STRING_TYPE_ARB   0x8DEA GLenum

@gl_function glNamedStringARB(typ::GLenum, namelen::GLint, name::Ptr{GLchar}, stringlen::GLint, string::Ptr{GLchar})::Void
@gl_function glCompileShaderIncludeARB(shader::GLuint, count::GLsizei, paths::Ptr{Ptr{GLchar}}, lengths::Ptr{GLint})::Void

type Include
  name::String
  path::String
end

includes = Set{Include}()

addincludes!(root) = begin
  for (dir, _, files) in walkdir(root, follow_symlinks=true)
    for file in files
      path = joinpath(dir, file)
      addinclude!(path[1 + length(root):end], read(path))
      union!(includes, [Include(path[1 + length(root):end], path)])
    end
  end
end

addinclude!(name, string) = begin
  glNamedStringARB(GL_SHADER_INCLUDE_ARB, length(name), pointer(name), length(string), pointer(string))
end

updateincludes!() = begin
  for include in includes
    addinclude!(include.name, read(include.path))
  end
end
