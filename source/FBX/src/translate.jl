Vec = SVector

function triangulate(array::Vector{SVector{3, Float64}}, indices::Vector{Int32})
  prims = diff(vcat(0, find(indices .< 0)))
  newindices = UInt32[]
  idx = 1
  for vertcount in prims
    if vertcount == 4
      push!(newindices, idx, idx + 1, idx + 2, idx, idx + 2, idx + 3)
    elseif vertcount == 3
      push!(newindices, idx, idx + 1, idx + 2)
    elseif vertcount > 3
      append!(newindices, triangulate(array[idx:idx + vertcount - 1]) + idx - 1)
    else
      throw("Unsupported vertcount $vertcount")
    end
    idx += vertcount
  end
  newindices
end

function unweave(array::Vector, indices::Vector{Int32})
  indices = [i < 0 ? -1 - i : i for i in indices]
  array[indices + 1]
end

function translate(node::Node{node"FBX"})
  geoms = Dict{Int32, Dict}()
  conns = Dict{Int32, Int32}()
  models = Dict{String, Dict}()
  for obj in node[:Objects][1][:Geometry]
    id = obj[1]
    positions = reinterpret(Vec{3, Float64}, obj[:Vertices][1][1])
    indices = obj[:PolygonVertexIndex][1][1]::Vector{Int32}
    positions = unweave(positions, indices)
    indices = triangulate(positions, indices) .- 1
    normals = reinterpret(Vec{3, Float64}, obj[:LayerElementNormal][1][:Normals][1][1])
    if maximum(indices) < 0x100
      indices = convert(Vector{UInt8}, indices)
    elseif maximum(indices) < 0x10000
      indices = convert(Vector{UInt16}, indices)
    end
    normals = convert(Vector{Vec{3, Float32}}, normals)
    positions = convert(Vector{Vec{3, Float32}}, positions)
    geom = geoms[id] = Dict("indices" => indices, "position" => positions, "normal" => normals)
    for layer in get(obj, :LayerElementUV, [])
      index = layer[1]
      geom["uv$index"] = convert(Vector{Vec{2, Float32}}, unweave(reinterpret(Vec{2, Float64}, layer[:UV][1][1]), layer[:UVIndex][1][1]))
    end
    for layer in get(obj, :LayerElementBinormal, [])
      index = layer[1]
      geom["binormal$index"] = convert(Vector{Vec{3, Float32}}, reinterpret(Vec{3, Float64}, layer[:Binormals][1][1]))
    end
    for layer in get(obj, :LayerElementTangent, [])
      index = layer[1]
      geom["tangent$index"] = convert(Vector{Vec{3, Float32}}, reinterpret(Vec{3, Float64}, layer[:Tangents][1][1]))
    end
    for layer in get(obj, :LayerElementColor, [])
      name = layer[:Name][1][1]
      geom[name] = convert(Vector{Vec{4, Float32}}, unweave(reinterpret(Vec{4, Float64}, layer[:Colors][1][1]), layer[:ColorIndex][1][1]))
    end
  end
  for conn in node[:Connections][1][:C]
    conn[3] != 0 && haskey(geoms, conn[2]) && (conns[conn[3]] = conn[2])
  end
  for obj in node[:Objects][1][:Model]
    models[obj[2]] = Dict("mesh" => geoms[conns[obj[1]]],
                          "rotate" => obj[:Properties70][1]["Lcl Rotation"],
                          "translate" => obj[:Properties70][1]["Lcl Translation"],
                          "scale" => obj[:Properties70][1]["Lcl Scaling"])
  end
  models
end
