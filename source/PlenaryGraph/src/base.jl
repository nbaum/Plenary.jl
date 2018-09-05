
@export type RenderState
  ctx::Context
end

@export immutable OnRender
  func::Function
end

@export function render(rs::RenderState, on::OnRender)
  on.func(rs)
end

@export function render(rs::RenderState, a::Vector)
  [render(rs, e) for e in a]
end
