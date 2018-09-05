export Texture, Texture1D, Texture2D, Texture3D, wrap!, storage!, image!, TextureCube

import Images
import Base.size

immutable Texture{Target} <: RenderTarget
  name::GLuint
  function Texture(; size = nothing, data = nothing, iformat = GL_RGBA8, samples = 1, levels = samples, label = nothing)
    t = deleter(new(getone(GLuint, v -> glCreateTextures(Target, 1, v))))
    if size != nothing
      storage!(t, levels, iformat, size...)
    elseif data != nothing
      storage!(t, levels, iformat, data)
    end
    if label != nothing
      label!(t, label)
    end
    t
  end
end

typealias Texture1D Texture{GL_TEXTURE_1D}
typealias Texture2D Texture{GL_TEXTURE_2D}
typealias Texture3D Texture{GL_TEXTURE_3D}
typealias TextureCube Texture{GL_TEXTURE_CUBE_MAP}

name(texture::Texture) = texture.name
delete(texture::Texture) = glDeleteTextures(1, name(texture))
delete(textures::Vector{Texture}) = glDeleteTextures(length(textures), name.(textures))
valid(texture::Texture) = glIsTexture(name(texture))

size(texture::Texture1D) = (width(texture), )
size(texture::Texture2D) = (width(texture), height(texture))
size(texture::Texture3D) = (width(texture), height(texture), depth(texture))

set!(texture::Texture, pname::GLenum, param::Integer) = glTextureParameteri(name(texture), pname, param)
set!(texture::Texture, pname::GLenum, param::AbstractFloat) = glTextureParameterf(name(texture), pname, param)

filters!(texture::Texture, min::GLenum, mag::GLenum) = set!(texture, GL_MIN_FILTER, min), set!(texture, GL_MAG_FILTER, mag)

wrap!(texture::Texture1D, s::GLenum) = set!(texture, GL_TEXTURE_WRAP_S, s)
wrap!(texture::Texture2D, s::GLenum, t::GLenum = s) = set!(texture, GL_TEXTURE_WRAP_S, s), set!(texture, GL_TEXTURE_WRAP_T, t)
wrap!(texture::Texture3D, s::GLenum, t::GLenum = s, r::GLenum = t) = set!(texture, GL_TEXTURE_WRAP_S, s), set!(texture, GL_TEXTURE_WRAP_T, t), set1(texture, GL_TEXTURE_WRAP_R, r)

storage!(texture::TextureCube, levels::Integer, internalformat::GLenum, width::Integer, height::Integer = width, depth::Integer = height) = glTextureStorage2D(name(texture), levels, internalformat, width, height)
storage!(texture::Texture3D, levels::Integer, internalformat::GLenum, width::Integer, height::Integer = width, depth::Integer = height) = glTextureStorage3D(name(texture), levels, internalformat, width, height, depth)
storage!(texture::Texture2D, levels::Integer, internalformat::GLenum, width::Integer, height::Integer = width) = glTextureStorage2D(name(texture), levels, internalformat, width, height)
storage!(texture::Texture1D, levels::Integer, internalformat::GLenum, width::Integer) = glTextureStorage1D(name(texture), levels, internalformat, width)

storage!{T}(texture::TextureCube, levels::Integer, internalformat::GLenum, data::Array{T, 3}; format = glpixelformat(T), typ = gltype(T)) = begin
  storage!(texture, levels, internalformat, size(data)...)
  image!(texture, 0, 0, 0, 0, size(data)..., format, typ, data)
end

storage!{T}(texture::Texture3D, levels::Integer, internalformat::GLenum, data::Array{T, 3}; format = glpixelformat(T), typ = gltype(T)) = begin
  storage!(texture, levels, internalformat, size(data)...)
  image!(texture, 0, 0, 0, 0, size(data)..., format, typ, data)
end

storage!{T}(texture::Texture2D, levels::Integer, internalformat::GLenum, data::Array{T, 2}; format = glpixelformat(T), typ = gltype(T)) = begin
  storage!(texture, levels, internalformat, size(data)...)
  image!(texture, 0, 0, 0, 0, size(data)..., 0, format, typ, data)
end

storage!{T}(texture::Texture1D, levels::Integer, internalformat::GLenum, data::Array{T, 1}; format = glpixelformat(T), typ = gltype(T)) = begin
  storage!(texture, levels, internalformat, size(data)...)
  image!(texture, 0, 0, 0, 0, size(data)..., 0, 0, format, typ, data)
end

storage!{T}(texture::TextureCube, levels::Integer, internalformat::GLenum, data::Vector{Array{T, 1}}; format = glpixelformat(T), typ = gltype(T)) = begin
  storage!(texture, levels, internalformat, size(data[1])...)
  image!(texture, 0, 0, 0, 0, size(data)..., 0, 0, format, typ, data)
end

storage!(texture::Texture2D, levels::Integer, internalformat::GLenum, image::Images.Image) = storage!(texture, levels, internalformat, permutedims(Array(image), [2, 1])[1:end, end:-1:1])

function storage!(texture::TextureCube, levels::Integer, internalformat::GLenum, image::Images.Image)
  data = permutedims(Array(image), [2, 1])
  len = size(data, 1) >> 2
  face(x, y) = data[(x - 1) * len + 1 : x * len, (y - 1) * len + 1 : y * len]
  data = cat(3, face(3, 2)[end:-1:1, :], face(1, 2)[end:-1:1, :],
                face(2, 1)[:, end:-1:1], face(2, 3)[:, end:-1:1],
                face(4, 2)[end:-1:1, :], face(2, 2)[end:-1:1, :])
  storage!(texture, levels, internalformat, data)
end

image!{T}(texture::TextureCube, data::Array{T, 3}; format = glpixelformat(T), typ = gltype(T)) = image!(texture, 0, 0, 0, 0, size(data)..., format, typ, data)
image!{T}(texture::Texture3D, data::Array{T, 3}; format = glpixelformat(T), typ = gltype(T)) = image!(texture, 0, 0, 0, 0, size(data)..., format, typ, data)
image!{T}(texture::Texture2D, data::Array{T, 2}; format = glpixelformat(T), typ = gltype(T)) = image!(texture, 0, 0, 0, 0, size(data)..., 0, format, typ, data)
image!{T}(texture::Texture1D, data::Array{T, 1}; format = glpixelformat(T), typ = gltype(T)) = image!(texture, 0, 0, 0, 0, size(data)..., 0, 0, format, typ, data)

image!(texture::TextureCube, level::Integer, xoffset::Integer, yoffset::Integer, zoffset::Integer, width::Integer, height::Integer, depth::Integer, format::GLenum, typ::GLenum, pixels::Array) =
    glTextureSubImage3D(name(texture), level, xoffset, yoffset, zoffset, width, height, depth, format, typ, pointer(pixels))

image!(texture::Texture3D, level::Integer, xoffset::Integer, yoffset::Integer, zoffset::Integer, width::Integer, height::Integer, depth::Integer, format::GLenum, typ::GLenum, pixels::Array) =
    glTextureSubImage3D(name(texture), level, xoffset, yoffset, zoffset, width, height, depth, format, typ, pointer(pixels))

image!(texture::Texture2D, level::Integer, xoffset::Integer, yoffset::Integer, zoffset::Integer, width::Integer, height::Integer, depth::Integer, format::GLenum, typ::GLenum, pixels::Array) =
    glTextureSubImage2D(name(texture), level, xoffset, yoffset, width, height, format, typ, pointer(pixels))

image!(texture::Texture1D, level::Integer, xoffset::Integer, yoffset::Integer, zoffset::Integer, width::Integer, height::Integer, depth::Integer, format::GLenum, typ::GLenum, pixels::Array) =
    glTextureSubImage1D(name(texture), level, xoffset, width, format, typ, pointer(pixels))

get(::Type{GLint}, texture::Texture, pname::GLenum) = getone(GLint, v -> glGetTextureParameteriv(name(texture), pname, v))
get(::Type{GLfloat}, texture::Texture, pname::GLenum) = getone(GLfloat, v -> glGetTextureParameterfv(name(texture), pname, v))

get(::Type{GLint}, texture::Texture, level::Integer, pname::GLenum) = getone(GLint, v -> glGetTextureLevelParameteriv(name(texture), level, pname, v))
get(::Type{GLfloat}, texture::Texture, level::Integer, pname::GLenum) = getone(GLfloat, v -> glGetTextureLevelParameterfv(name(texture), level, pname, v))

width(texture::Texture, level::Integer = 0) = get(GLint, texture, level, GL_TEXTURE_WIDTH)
height(texture::Texture, level::Integer = 0) = get(GLint, texture, level, GL_TEXTURE_HEIGHT)
depth(texture::Texture, level::Integer = 0) = get(GLint, texture, level, GL_TEXTURE_DEPTH)

# image(texture::Texture, level::GLint, format::GLenum, typ::GLenum, pixels::Array) = glGetTextureImage(name(texture), level, format, typ, sizeof(pixels), pixels)
# image(texture::Texture, level::GLint, xoffset::GLint, yoffset::GLint, zoffset::GLint, width::GLsizei, height::GLsizei, depth::GLsizei, format::GLenum, typ::GLenum, pixels::Array) = glGetTextureSubImage(name(texture), level, xoffset, yoffset, zoffset, width, height, depth, format, typ, sizeof(pixels), pixels)
# image(texture::Texture, level::GLint, xoffset::GLint, yoffset::GLint, width::GLsizei, height::GLsizei, format::GLenum, typ::GLenum, pixels::Array) = image(name(texture), level, xoffset, yoffset, 0, width, height, 1, format, typ, pixels)
# image(texture::Texture, level::GLint, xoffset::GLint, width::GLsizei, format::GLenum, typ::GLenum, pixels::Array) = image(name(texture), level, xoffset, 0, 0, width, 1, 1, format, typ, pixels)

Base.show(io::IO, t::Texture1D) = print(io, "Texture1D($(t.name), `$(label(t))`)")
Base.show(io::IO, t::Texture2D) = print(io, "Texture2D($(t.name), `$(label(t))`)")
Base.show(io::IO, t::Texture3D) = print(io, "Texture3D($(t.name), `$(label(t))`)")
