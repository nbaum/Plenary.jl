import ColorTypes, FixedPointNumbers

export gltype, glsize, glstride

function create(f::Function, args...)
  ids = GLuint[0]
  f(args..., 1, pointer(ids))
  ids[]
end

# deleter(obj) = (finalizer(obj, obj -> delete(obj)); obj)
# deleter(obj) = obj

enum(e::GLenum) = e

getone(T::Type, f::Function) = (v = zeros(T, 1); f(pointer(v)); v[])

glpixelformat{T<:Integer}(::Type{Vec{1, T}}) = GL_RED_INTEGER
glpixelformat{T<:Integer}(::Type{Vec{2, T}}) = GL_RG_INTEGER
glpixelformat{T<:Integer}(::Type{Vec{3, T}}) = GL_RGB_INTEGER
glpixelformat{T<:Integer}(::Type{Vec{4, T}}) = GL_RGBA_INTEGER
glpixelformat{T<:AbstractFloat}(::Type{Vec{1, T}}) = GL_RED
glpixelformat{T<:AbstractFloat}(::Type{Vec{2, T}}) = GL_RG
glpixelformat{T<:AbstractFloat}(::Type{Vec{3, T}}) = GL_RGB
glpixelformat{T<:AbstractFloat}(::Type{Vec{4, T}}) = GL_RGBA
glpixelformat{T<:Number}(::Type{T}) = GL_RED
glpixelformat{T}(::Type{ColorTypes.RGB{T}}) = GL_RGB
glpixelformat{T}(::Type{ColorTypes.RGBA{T}}) = GL_RGBA
glpixelformat{T}(::Type{ColorTypes.BGRA{T}}) = GL_BGRA

gltype(::Type{GLuchar}) = GL_UNSIGNED_BYTE
gltype(::Type{GLushort}) = GL_UNSIGNED_SHORT
gltype(::Type{GLuint}) = GL_UNSIGNED_INT
gltype(::Type{GLchar}) = GL_BYTE
gltype(::Type{GLshort}) = GL_SHORT
gltype(::Type{GLint}) = GL_INT
gltype(::Type{GLfloat}) = GL_FLOAT
gltype(::Type{GLhalf}) = GL_HALF_FLOAT
gltype(::Type{GLdouble}) = GL_DOUBLE
gltype{N,T}(::Type{Vec{N,T}}) = gltype(T)
gltype{T}(::Type{ColorTypes.RGB{T}}) = gltype(T)
gltype{T}(::Type{ColorTypes.RGBA{T}}) = gltype(T)
gltype{T}(::Type{ColorTypes.BGRA{T}}) = gltype(T)
gltype{T,N}(::Type{FixedPointNumbers.UFixed{T, N}}) = gltype(T)

glsize(::Type{GLuchar}) = GLint(1)
glsize(::Type{GLfloat}) = GLint(1)
glsize(::Type{GLdouble}) = GLint(1)
glsize{N,T}(::Type{Vec{N,T}}) = GLint(N)

glstride(t::Type) = GLint(sizeof(t))

getbool(pname::GLenum) = getone(GLbool, v -> glGetBooleanv(pname, v))
getint(pname::GLenum) = getone(GLint, v -> glGetIntegerv(pname, v))
getint64(pname::GLenum) = getone(GLint64, v -> glGetInteger64v(pname, v))
getfloat(pname::GLenum) = getone(GLfloat, v -> glGetFloatv(pname, v))
getdouble(pname::GLenum) = getone(GLdouble, v -> glGetDoublev(pname, v))

abstract RenderTarget

typealias Maybe{T} Union{Void, T}
