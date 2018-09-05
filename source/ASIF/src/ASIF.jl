__precompile__()
module ASIF
  using StaticArrays

  TYPE_NULL     = b"\x00"
  TYPE_RUNE     = b"\x01"
  TYPE_BOOL     = b"\x02"
  TYPE_INT8     = b"\x03"
  TYPE_INT16    = b"\x04"
  TYPE_INT32    = b"\x05"
  TYPE_INT64    = b"\x06"
  TYPE_INT128   = b"\x07"
  TYPE_UINT8    = b"\x08"
  TYPE_UINT16   = b"\x09"
  TYPE_UINT32   = b"\x0A"
  TYPE_UINT64   = b"\x0B"
  TYPE_UINT128  = b"\x0C"
  TYPE_FLOAT16  = b"\x0D"
  TYPE_FLOAT32  = b"\x0E"
  TYPE_FLOAT64  = b"\x0F"
  TYPE_FLOAT128 = b"\x10"
  TYPE_FLOAT256 = b"\x11"
  TYPE_TUPLE    = b"\x12"
  TYPE_ARRAY    = b"\x13"
  TYPE_DICT     = b"\x14"
  TYPE_STRING   = b"\x15"
  TYPE_ANY      = b"\xff"

  writetype(io::IO, ::Type{Void})    = write(io, TYPE_NULL)
  writetype(io::IO, ::Type{Char})    = write(io, TYPE_RUNE)
  writetype(io::IO, ::Type{Int8})    = write(io, TYPE_INT8)
  writetype(io::IO, ::Type{Int16})   = write(io, TYPE_INT16)
  writetype(io::IO, ::Type{Int32})   = write(io, TYPE_INT32)
  writetype(io::IO, ::Type{Int64})   = write(io, TYPE_INT64)
  writetype(io::IO, ::Type{Int128})  = write(io, TYPE_INT128)
  writetype(io::IO, ::Type{Bool})    = write(io, TYPE_BOOL)
  writetype(io::IO, ::Type{UInt8})   = write(io, TYPE_UINT8)
  writetype(io::IO, ::Type{UInt16})  = write(io, TYPE_UINT16)
  writetype(io::IO, ::Type{UInt32})  = write(io, TYPE_UINT32)
  writetype(io::IO, ::Type{UInt64})  = write(io, TYPE_UINT64)
  writetype(io::IO, ::Type{UInt128}) = write(io, TYPE_UINT128)
  writetype(io::IO, ::Type{Float16}) = write(io, TYPE_FLOAT16)
  writetype(io::IO, ::Type{Float32}) = write(io, TYPE_FLOAT32)
  writetype(io::IO, ::Type{Float64}) = write(io, TYPE_FLOAT64)
  writetype(io::IO, ::Type{String})  = write(io, TYPE_STRING)

  dump_(io::IO, data::Union{Bool,Char,Int8,Int16,Int32,Int64,UInt8,UInt16,UInt32,UInt64,Float16,Float32,Float64}) = begin
    writetype(io, typeof(data))
    write(io, data)
  end

  dump_(io::IO, data::Void) = writetype(io, typeof(data))

  dump_{T, N}(io::IO, data::Array{T, N}) = begin
    write(io, TYPE_ARRAY, TYPE_ANY, UInt8(N))
    for s in size(data)
      write(io, UInt32(s))
    end
    for i in linearindices(data)
      dump_(io, data[i])
    end
  end

  dump_{T, N}(io::IO, data::Array{T, N}, typecode::Vector{UInt8}) = begin
    write(io, TYPE_ARRAY, typecode, UInt8(N))
    for s in size(data)
      write(io, UInt32(s))
    end
    write(io, data)
  end

  dump_{N}(io::IO, data::Array{Bool, N}) =  dump_(io, data, TYPE_BOOL)
  dump_{N}(io::IO, data::Array{Char, N}) =  dump_(io, data, TYPE_RUNE)

  dump_{N}(io::IO, data::Array{Int8, N}) =  dump_(io, data, TYPE_INT8)
  dump_{N}(io::IO, data::Array{Int16, N}) =  dump_(io, data, TYPE_INT16)
  dump_{N}(io::IO, data::Array{Int32, N}) =  dump_(io, data, TYPE_INT32)
  dump_{N}(io::IO, data::Array{Int64, N}) =  dump_(io, data, TYPE_INT64)

  dump_{N}(io::IO, data::Array{UInt8, N}) =  dump_(io, data, TYPE_UINT8)
  dump_{N}(io::IO, data::Array{UInt16, N}) =  dump_(io, data, TYPE_UINT16)
  dump_{N}(io::IO, data::Array{UInt32, N}) =  dump_(io, data, TYPE_UINT32)
  dump_{N}(io::IO, data::Array{UInt64, N}) =  dump_(io, data, TYPE_UINT64)

  dump_{N}(io::IO, data::Array{Float16, N}) =  dump_(io, data, TYPE_FLOAT16)
  dump_{N}(io::IO, data::Array{Float32, N}) =  dump_(io, data, TYPE_FLOAT32)
  dump_{N}(io::IO, data::Array{Float64, N}) =  dump_(io, data, TYPE_FLOAT64)

  dump_{N,M,T}(io::IO, data::Array{SVector{M, T}, N}) = begin
    data2 = reinterpret(T, data)
    data3 = reshape(data2, (size(data)..., M))
    dump_(io, data3)
  end

  dump_(io::IO, data::String) = begin
    write(io, TYPE_STRING, UInt32(length(data)), data)
  end

  dump_(io::IO, data::Dict) = begin
    write(io, TYPE_DICT, TYPE_ANY, TYPE_ANY, UInt32(length(data)))
    for (k, v) in data
      dump_(io, k)
      dump_(io, v)
    end
  end

  dump(io::IO, data) = begin
    write(io, "ASIF", UInt32(0x0000), UInt32(0x1234))
    dump_(io, data)
  end

end
