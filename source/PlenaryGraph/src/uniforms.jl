export Uniforms

immutable Uniforms <: Associative{String, Any}
  dict::Dict{String, Any}
  dirty::Set{String}
  Uniforms(dict::Dict) = new(dict, Set(keys(dict)))
end

Uniforms(pairs::Pair...) = Uniforms(Dict(pairs...))

DefaultUniforms() = Uniforms("scene.projection" => Math.identity, "scene.view" => Math.identity, "scene.model" => Math.identity)

Base.getindex(u::Uniforms, name::String) = u.dict[name]

function Base.setindex!(u::Uniforms, value, name::String)
  if !haskey(u.dict, name) || u.dict[name] != value
    u.dict[name] = value
    push!(u.dirty, name)
  end
end

function merge!(dst::Uniforms, srcs::Uniforms...)
  for src in srcs
    for (key, value) in src.dict
      dst.dict[key] = value
    end
    union!(dst.dirty, keys(src.dict))
  end
end

function dirty!(u::Uniforms)
  union!(u.dirty, keys(u.dict))
end

function updategl(c::Context)
  u = c.uniforms
  unit = 0
  for name in u.dirty
    value = u.dict[name]
    loc = uniform(c.program, name)
    if loc == nothing
      # no uniform to set
    elseif isa(value, Texture)
      debug("binding $(value) to texture unit $(unit)")
      debug("setting uniform $(name) to $(unit)")
      glBindTextureUnit(unit, value.name)
      uniform!(c.program, loc, unit)
      unit += GLint(1)
    else
      debug("setting uniform $(name) to $(value)")
      uniform!(c.program, loc, value)
    end
  end
  empty!(u.dirty)
end

function render(c::Context, u::Uniforms)
  merge!(c.uniforms, u)
end
