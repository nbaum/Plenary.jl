load(path::String) = open(io -> read(io, Node{node"FBX"}), path, "r")

function read(io::IOStream, T::Type{Node{node"FBX"}})
  node = T(0)
  seek(io, 23)
  version = read(io, Int32)
  @show version
  while true
    subnode = read(io, Node)
    subnode == nothing && break
    addchild(node, subnode)
  end
  node
end

function readarray{T}(io::IOStream, ::Type{T})
  len = read(io, UInt32)
  enc = read(io, UInt32) == 1
  clen = read(io, UInt32)
  @show [Int32(len), Int32(enc), Int32(clen)]
  @show data = read(io, UInt8, clen)
  reinterpret(T, enc ? decompress(data) : data)
end

read(io::IOStream, ::Type{PropCode{'B'}}) = read(io, Int8) == 1
read(io::IOStream, ::Type{PropCode{'C'}}) = read(io, Int8)
read(io::IOStream, ::Type{PropCode{'Y'}}) = read(io, Int16)
read(io::IOStream, ::Type{PropCode{'I'}}) = @show read(io, Int32)
read(io::IOStream, ::Type{PropCode{'L'}}) = read(io, Int64)
read(io::IOStream, ::Type{PropCode{'F'}}) = read(io, Float32)
read(io::IOStream, ::Type{PropCode{'D'}}) = read(io, Float64)
read(io::IOStream, ::Type{PropCode{'b'}}) = readarray(io, Int8) == 1
read(io::IOStream, ::Type{PropCode{'c'}}) = readarray(io, Int8)
read(io::IOStream, ::Type{PropCode{'y'}}) = readarray(io, Int8)
read(io::IOStream, ::Type{PropCode{'i'}}) = readarray(io, Int32)
read(io::IOStream, ::Type{PropCode{'l'}}) = readarray(io, Int64)
read(io::IOStream, ::Type{PropCode{'f'}}) = readarray(io, Float32)
read(io::IOStream, ::Type{PropCode{'d'}}) = readarray(io, Float64)
read(io::IOStream, ::Type{PropCode{'S'}}) = split(String(read(io, read(io, UInt32))), '\x00', limit=2)[1]
read(io::IOStream, ::Type{PropCode{'R'}}) = read(io, read(io, UInt32))

skip(::Type{node"FBXHeaderExtension"}) = true
skip(::Type{node"FileId"}) = true
skip(::Type{node"CreationTime"}) = true
skip(::Type{node"Creator"}) = true
skip(::Type{node"Documents"}) = true
skip(::Type{node"GlobalSettings"}) = true
skip(::Type{node"Definitions"}) = true
skip(::Type{node"References"}) = true
skip(::Type{node"Takes"}) = true
skip(::Type) = false

function read(io::IOStream, ::Type{Node})
  nextnode = read(io, UInt32)
  propcount = read(io, UInt32)
  proplen = read(io, UInt32)
  namelen = read(io, UInt8)
  @show [Int32(x) for x in [nextnode, propcount, proplen, namelen]]
  name = Symbol(String(read(io, UInt8, namelen)))
  nextnode == 0 && return nothing
  nodetype = NodeType{Symbol(name)}
  #if skip(nodetype)
  #  seek(io, nextnode)
  #  return read(io, Node)
  #end
  node = Node{nodetype}(propcount)
  for i in 1:propcount
    kode = read(io, UInt8)
    @show kode
    node.props[i] = read(io, PropCode{Char(kode)})
  end
  while position(io) < nextnode
    subnode = read(io, Node)
    subnode != nothing && addchild(node, subnode)
  end
  node
end
