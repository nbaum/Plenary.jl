export Material, MaterialCull

using JSON

type Material
  path::String
  uniforms::Dict{String}
  passes::Dict{String, Program}
end

function Material(path)
  m = Material(path, Dict{String, Any}(), Dict{String, Program}())
  update!(m)
  # watch(m)
  m
end

function watch(mat::Material)
  @schedule while true
    watch_file(mat.path)
    update!(mat)
  end
  for include in OpenGL.includes
    @schedule while true
      watch_file(include.path)
      addinclude!(include.name, read(include.path))
      update!(mat)
    end
  end
  for (name, paths) in JSON.parse(readstring(mat.path))["passes"]
    for path in paths
      @schedule while true
        watch_file(path)
        update!(mat)
      end
    end
  end
end

function update!(mat::Material)
  data = JSON.parse(readstring(mat.path))
  passes = data["passes"]
  for (name, paths) in data["passes"]
    program = get!(() -> Program(), mat.passes, name)
    detachall!(program)
    for path in paths
      shader = if endswith(path, ".frag")
        Shader{GL_FRAGMENT_SHADER}(readstring(path), path)
      elseif endswith(path, ".vert")
        Shader{GL_VERTEX_SHADER}(readstring(path), path)
      elseif endswith(path, ".geom")
        Shader{GL_GEOMETRY_SHADER}(readstring(path), path)
      else
        throw("don't know what to do with $path")
      end
      attach!(program, shader)
    end
    link!(program)
  end
end

function render(ctx::Context, mat::Material; kwargs...)
  if haskey(mat.passes, ctx.renderpass)
    debug("$(ctx.renderpass) rendering: $(mat.passes[ctx.renderpass])")
    render(ctx, mat.passes[ctx.renderpass])
  else
    ctx.program = nothing
  end
end

type MaterialCull
  content::Any
end

function render(ctx::Context, cull::MaterialCull; kwargs...)
  if ctx.program != nothing
    render(ctx, cull.content; kwargs...)
  end
end
