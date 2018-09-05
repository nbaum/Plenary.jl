export Transform

type Transform
  matrix::Mat4f
  children::Vector
end

function Transform(children...;
                   translate = nothing,
                   rotate = nothing,
                   scale = nothing,
                   matrix = Math.identity)
  t = Transform(matrix, collect(children))
  translate != nothing && (t.matrix *= Math.translate(translate...))
  rotate != nothing && (t.matrix *= Math.rotate(rotate...))
  scale != nothing && (t.matrix *= Math.scale(scale...))
  t
end

function render(c::Context, t::Transform; kwargs...)
  @dynamic let c["scene.model"]  *= t.matrix
    render(c, t.children; kwargs...)
  end
end
