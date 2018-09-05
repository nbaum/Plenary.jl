export Mesh
M = PlenaryMath

type Mesh
  name::String
  mode::GLenum
  count::GLuint
  buffers::Dict{String, Buffer}
  indices::Union{Void, Buffer}
  arrays::Dict{GLuint, VertexArray}
end

function Mesh(name::String, mode::GLenum, buffers::Vararg{Pair{String, Buffer}}, )
  vertcount = minimum([b.length for (_, b) in buffers])
  Mesh(name, mode, vertcount, Dict(buffers), nothing, Dict{GLuint, VertexArray}())
end

Mesh(name::String, buffers::Vararg{Pair{String, Buffer}}) = Mesh(name, GL_TRIANGLES, buffers...)

function Mesh{T<:Integer}(name::String, mode::GLenum, indices::Vector{T}, buffers::Pair{String, Buffer}...)
  vertcount = length(indices)
  Mesh(name, mode, vertcount, Dict(buffers), Buffer(indices - 1), Dict{GLuint, VertexArray}())
end

function Mesh(path::String)
  open(path) do io
    result = []
    data = deserialize(io)
    for (name, model) in data
      transform = M.identity
      model["translate"] != nothing && (transform *= M.translate(model["translate"]...))
      # @time model["rotate"] != nothing && (transform *= M.rotate((model["rotate"] / 180 * π)...))
      @time M.rotate(10.0, 20.0, 3.0)
      model["scale"] != nothing && (transform *= M.scale(model["scale"]...))
      @time mesh = Mesh(name, GL_TRIANGLES, pop!(model["mesh"], "indices"), "position" => Buffer(pop!(model["mesh"], "position")))
      for (key, data) in model["mesh"]
        mesh.buffers[key] = Buffer(data)
      end
      push!(result, Transform(mesh, matrix = transform))
    end
    result
  end
end

function render(ctx::Context, m::Mesh; instances = 1)
  program = ctx.program
  if program == nothing
    throw("No active program when rendering $(m.name)")
  end
  va = get!(m.arrays, program.name) do
    debug("making vertex array for mesh $(object_id(m))")
    va = VertexArray()
    m.indices != nothing && elements!(va, m.indices)
    binding = 0
    for (name, buffer) = m.buffers
      loc = input(program, name)
      if loc != nothing
        debug("  attribute for `$name' is at $loc")
        format!(va, loc, glsize(buffer), gltype(buffer))
        attach!(va, binding, buffer, 0, glstride(buffer))
        bind!(va, binding, loc, buffer, glsize(buffer), gltype(buffer), glstride(buffer))
        binding += 1
      else
        debug("  no attribute for `$name'")
      end
    end
    va
  end
  updategl(ctx)
  draw(va, instances = instances)
end
