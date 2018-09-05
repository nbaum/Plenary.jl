immutable PropCode{T} end

immutable NodeType{T} end

immutable Node{T<:NodeType}
  props::Vector
  childs::Dict{Symbol,Vector{Node}}
  Node(c::Integer) = new(Array(Any, c), Dict())
end

macro node_str(name)
  name = Expr(:quote, Symbol(name))
  :(NodeType{$name})
end

function addchild{S}(parent::Node, child::Node{NodeType{S}})
  push!(get!(parent.childs, S, Node[]), child)
end

Base.keys(node::Node) = keys(node.childs)
Base.getindex(node::Node, key::Symbol) = node.childs[key]
Base.getindex(node::Node, idx::Int64) = node.props[idx]
Base.get(node::Node, key::Symbol, default::Any) = get(node.childs, key, default)

function Base.getindex(node::Node{node"Properties70"}, key::String)
  for prop in node[:P]
    if prop[1] == key
      return collect(promote(prop.props[5:end]...))
    end
  end
  nothing
end
