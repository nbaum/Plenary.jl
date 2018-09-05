immutable BlitMap end
immutable Window end
immutable GLContext end

immutable Point
  x::Cint
  y::Cint
end

immutable Rect
  x::Cint
  y::Cint
  w::Cint
  h::Cint
  Rect() = new(0, 0, 0, 0)
end

immutable DisplayMode
  format::UInt32
  width::Cint
  height::Cint
  refresh::Cint
  driverdata::Ptr{Void}
end

typealias Color Tuple{UInt8, UInt8, UInt8, UInt8}

immutable Palette
  ncolors::Cint
  colors::Ptr{Color}
  version::UInt32
  refcount::Cint
end

immutable PixelFormat
  format::UInt32
  palette::Ptr{Palette}
  bbp::UInt8
  padding::Tuple{UInt8, UInt8, UInt8}
  mask::Tuple{UInt32, UInt32, UInt32, UInt32}
  loss::Tuple{UInt8, UInt8, UInt8, UInt8}
  shift::Tuple{UInt8, UInt8, UInt8, UInt8}
  refcount::Cint
  next::Ptr{PixelFormat}
end

immutable Surface
  flags::UInt32
  format::Ptr{PixelFormat}
  w::Cint
  h::Cint
  pitch::Cint
  pixels::Ptr{Void}
  userdata::Ptr{Void}
  locked::Cint
  lockdata::Ptr{Void}
  cliprect::Rect
  map::Ptr{BlitMap}
  refcount::Cint
end
