#
# @export type Clear
#   color::Nullable{Vec4f}
#   depth::Nullable{GLdouble}
#   stencil::Nullable{GLuint}
#   function Clear(; color::Nullable{Vec4f} = Vec4f(0, 0, 0, 1),
#                    depth::Nullable{GLdouble} = 1.0,
#                    stencil::Nullable{GLuint} = GLuint(0))
#     new(color, depth, stencil)
#   end
# end
#
# function render(s::RenderState, c::Clear)
#   mask = 0x0
#   c.color != nothing    && (mask |= GL_COLOR_BUFFER_BIT;   glClearColor(c.color...))
#   c.depth != nothing    && (mask |= GL_DEPTH_BUFFER_BIT;   glClearDepth(c.depth))
#   c.stencil != nothing  && (mask |= GL_STENCIL_BUFFER_BIT; glClearStencil(c.stencil))
#   glClear(mask)
# end
