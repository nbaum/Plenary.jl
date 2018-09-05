import Base: show

show(io::IO, node::Node) = show(IOContext(io, indent = 0), node)

function show{T}(io::IOContext, node::Node{NodeType{T}})
  io = IOContext(io, indent = 2 + get(io, :indent, 0))
  indent = " " ^ io[:indent]
  println(io)
  print(io, indent, T)
  for prop in node.props
    print(io, " ")
    if isa(prop, Array)
      print(io, eltype(prop), [size(prop)...])
    else
      show(io, prop)
    end
  end
  for (name, childs) in node.childs
    for child in childs
      show(io, child)
    end
  end
end
