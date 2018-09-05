
macro coalesce(expr, exprs...)
  if exprs == ()
    esc(expr)
  else
    quote
      e = $(esc(expr))
      if e != nothing
        e
      else
        @coalesce $([esc(expr) for expr in exprs]...)
      end
    end
  end
end

macro mixin(expr)
  realtype = eval(expr)
  names = fieldnames(realtype)
  types = [fieldtype(realtype, name) for name in names]
  exprs = [:($(name)::$(typ)) for name in names, typ in types]
  quote $(exprs...) end
end

macro dynamic(expr)
  block = esc(expr.args[1])
  args = expr.args[2:end]
  temps = [gensym() for _ in args]
  store = [:($var = $(esc(val.args[1]))) for (var, val) in zip(temps, args)]
  assign = [:($(esc(arg))) for arg in args]
  restore = [:($(esc(val.args[1])) = $var) for (var, val) in zip(temps, args)]
  quote
    $(store...)
    try
      $(assign...)
      $block
    finally
      $(restore...)
    end
  end
end
