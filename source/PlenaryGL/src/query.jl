
immutable Query
  typ::GLenum
  name::GLuint
end

Query(typ::GLenum) = finalizer(Query(typ, create(glCreateQueries, typ)))

name(query::Query) = query.name
delete(query::Query) = glDeleteQueries(1, [name(query)])
start(query::Query, i = 0) = glBeginQueryIndexed(target(query), i, name(query))
stop(query::Query, i = 0) = glEndQueryIndexed(target(query), i)
valid(query::Query) = glIsQuery(name(query))

function get{T}(::Type{T}, f::Function, query::Query, pname::GLenum)
  r = T[zero(T)]
  f(name(query), pname, r)
  r[]
end

get(t::Type{Int32}, query::Query, pname::GLenum) = get(t, glGetQueryObjectiv, query, pname)
get(t::Type{Int64}, query::Query, pname::GLenum) = get(t, glGetQueryObjecti64v, query, pname)
get(t::Type{UInt32}, query::Query, pname::GLenum) = get(t, glGetQueryObjectuiv, query, pname)
get(t::Type{UInt64}, query::Query, pname::GLenum) = get(t, glGetQueryObjectui64v, query, pname)

resultavailable(query::Query) = get(Int32, query, GL_QUERY_RESULT_AVAILABLE)
result(query::Query; wait = true) = get(Int64, query, wait ? GL_QUERY_RESULT : GL_QUERY_RESULT_NO_WAIT)

function conditionally(f::Function, query::Query, mode::GLenum = GL_QUERY_WAIT)
  glBeginConditionalRender(name(query), mode)
  f()
  glEndConditionalRender()
end
