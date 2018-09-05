export Buffer

type Buffer
  name::GLuint
  length::GLint
  eltype::Type
  Buffer() = new(create(glCreateBuffers), 0, Void)
  Buffer(data::Vector) = data!(Buffer(), data)
end

name(b::Buffer) = b.name
length(b::Buffer) = b.length
eltype(b::Buffer) = b.eltype

function data!{T}(b::Buffer, data::Vector{T})
  b.eltype = T
  b.length = length(data)
  glNamedBufferStorage(b.name, sizeof(data), pointer(data), 0)
  b
end

gltype(b::Buffer) = gltype(b.eltype)
glsize(b::Buffer) = glsize(b.eltype)
glstride(b::Buffer) = glstride(b.eltype)
