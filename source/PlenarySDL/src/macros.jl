sdl_promote{T<:Integer}(::Type{T}) = Integer
sdl_promote{T<:Real}(::Type{T}) = Real
sdl_promote(::Type{Cstring}) = String
sdl_promote{T}(::Type{Ref{T}}) = Ref{T}
sdl_promote{T}(::Type{Ptr{T}}) = Ptr{T}

Base.convert(::Type{Cstring}, s::String) = pointer(s)

macro sdl_function(specifier)
  arguments = map(specifier.args[1].args[2:end]) do arg
    isa(arg, Symbol) ? Expr(:(::), arg) : arg
  end
  arg_names       = map(arg -> Expr(:(::), arg.args[1], sdl_promote(eval(arg.args[2]))), arguments)
  arg_exprs       = map(arg -> Expr(:call, :convert, arg.args[2], arg.args[1]), arguments)
  # arg_exprs       = map(arg -> arg.args[1], arguments)
  return_type     = specifier.args[2]
  input_types     = map(arg->arg.args[2], arguments)
  func_name       = specifier.args[1].args[1]
  func_name_sym   = Expr(:quote, Symbol("SDL_$func_name"))
  func_name_str   = string(func_name)
  ret = quote
    $func_name($(arg_names...)) = ccall(($func_name_sym, "libSDL2"), $return_type, ($(input_types...),), $(arg_exprs...))
    export $(func_name)
  end
  return esc(ret)
end

macro img_function(specifier)
  arguments = map(specifier.args[1].args[2:end]) do arg
    isa(arg, Symbol) ? Expr(:(::), arg) : arg
  end
  arg_names       = map(arg -> arg.args[1], arguments)
  arg_exprs       = map(arg -> Expr(:call, :convert, arg.args[2], arg.args[1]), arguments)
  # arg_exprs       = map(arg -> arg.args[1], arguments)
  return_type     = specifier.args[2]
  input_types     = map(arg->arg.args[2], arguments)
  func_name       = specifier.args[1].args[1]
  func_name_sym   = Expr(:quote, Symbol("IMG_$func_name"))
  func_name_str   = string(func_name)
  ret = quote
    $func_name($(arg_names...)) = ccall(($func_name_sym, "libSDL2_image"), $return_type, ($(input_types...),), $(arg_exprs...))
    export $(func_name)
  end
  return esc(ret)
end

macro sdl_const(name, value)
  quote
    $(esc(name)) = convert(UInt32, $(esc(value)))
    export $(esc(name))
  end
end
