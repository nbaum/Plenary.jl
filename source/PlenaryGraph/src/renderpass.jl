export Renderpass

type Renderpass
  name::String
  content::Any
end

function render(ctx::Context, rp::Renderpass; kwargs...)
  @dynamic let ctx.renderpass = rp.name
    render(ctx, rp.content; kwargs...)
  end
end
