export VertexArray, elements!, format!, attach!, bind!, draw

type VertexArray
  name::GLuint
  length::Int32
  eltype::GLenum
end

VertexArray() = deleter(VertexArray(getone(GLuint, v -> glCreateVertexArrays(1, v)), 0, GL_NONE))

@inline name(vertexarray::VertexArray) = vertexarray.name
delete(vertexarray::VertexArray) = glDeleteFramebuffers(1, name(vertexarray))
delete(vertexarrays::Vector{VertexArray}) = glDeleteTextures(length(vertexarrays), name.(vertexarrays))
valid(vertexarray::VertexArray) = glIsVertexArray(name(vertexarray))

function elements!(vertexarray::VertexArray, buffer::Buffer)
  glVertexArrayElementBuffer(name(vertexarray), name(buffer))
  vertexarray.eltype = gltype(buffer)
  vertexarray.length = length(buffer)
end

format!(vertexarray::VertexArray, attribindex::Integer, size::Integer, typ::GLenum, normalized::GLboolean, relativeoffset::Integer) =  glVertexArrayAttribFormat(name(vertexarray), attribindex, size, typ, normalized, relativeoffset)
format!(vertexarray::VertexArray, attribindex::Integer, size::Integer, typ::GLenum, relativeoffset::Integer) = format!(vertexarray, attribindex, size, typ, GL_FALSE, relativeoffset)
format!(vertexarray::VertexArray, attribindex::Integer, size::Integer, typ::GLenum, normalized::GLboolean) = format!(vertexarray, attribindex, size, typ, normalized, 0)
format!(vertexarray::VertexArray, attribindex::Integer, size::Integer, typ::GLenum) = format!(vertexarray, attribindex, size, typ, GL_FALSE, 0)

divisor!(vertexarray::VertexArray, bindingindex::Integer, divisor::Integer) = glVertexArrayBindingDivisor(name(vertexarray), bindingindex, divisor)

function attach!(vertexarray::VertexArray, bindingindex::Integer, buffer::Buffer, stride::Integer, offset::Integer = 0)
  if vertexarray.eltype == GL_NONE
    vertexarray.length = max(vertexarray.length, length(buffer))
  end
  glVertexArrayVertexBuffer(name(vertexarray), bindingindex, name(buffer), offset, stride)
end

function bind!(vertexarray::VertexArray, bindingindex::Integer, attribindex::Integer)
  glVertexArrayAttribBinding(name(vertexarray), attribindex, bindingindex)
end

function bind!(vertexarray::VertexArray, bindingindex::Integer, attribindex::Integer, buffer::Buffer, size::Integer, typ::Integer, stride::Integer, offset::Integer = 0)
  format!(vertexarray, attribindex, size, typ)
  attach!(vertexarray, bindingindex, buffer, stride, offset)
  bind!(vertexarray, bindingindex, attribindex)
  glEnableVertexArrayAttrib(name(vertexarray), attribindex)
end

function draw(va::VertexArray; instances = 1)
  if va.eltype == GL_NONE
    drawarrays(va, GL_TRIANGLES, 0, va.length, instances)
  else
    drawelements(va, GL_TRIANGLES, 0, va.length, va.eltype, instances)
  end
end

function drawarrays(vertexarray::VertexArray, mode::GLenum, first::Integer, count::Integer, instancecount::Integer = 1, baseinstance::Integer = 0)
  use(vertexarray)
  glDrawArraysInstancedBaseInstance(mode, first, count, instancecount, baseinstance)
end

function drawelements(vertexarray::VertexArray, mode::GLenum, first::Integer, count::Integer, eltype::GLenum, instancecount::Integer = 1, baseinstance::Integer = 0, basevertex::Integer = 0)
  use(vertexarray)
  glDrawElementsInstancedBaseVertexBaseInstance(mode, count, eltype, first, instancecount, basevertex, baseinstance)
end
