
@enum(EventType::UInt32,
      FIRSTEVENT                  = 0,
      QUIT                        = 0x100,
      APP_TERMINATING,
      APP_LOWMEMORY,
      APP_WILLENTERBACKGROUND,
      APP_DIDENTERBACKGROUND,
      APP_WILLENTERFOREGROUND,
      APP_DIDENTERFOREGROUND,
      WINDOWEVENT                 = 0x200,
      SYSWMEVENT,
      KEYDOWN                     = 0x300,
      KEYUP,
      TEXTEDITING,
      TEXTINPUT,
      KEYMAPCHANGED,
      MOUSEMOTION                 = 0x400,
      MOUSEBUTTONDOWN,
      MOUSEBUTTONUP,
      MOUSEWHEEL,
      JOYAXISMOTION               = 0x600,
      JOYBALLMOTION,
      JOYHATMOTION,
      JOYBUTTONDOWN,
      JOYBUTTONUP,
      JOYDEVICEADDED,
      JOYDEVICEREMOVED,
      CONTROLLERAXISMOTION        = 0x650,
      CONTROLLERBUTTONDOWN,
      CONTROLLERBUTTONUP,
      CONTROLLERDEVICEADDED,
      CONTROLLERDEVICEREMOVED,
      CONTROLLERDEVICEREMAPPED,
      FINGERDOWN                  = 0x700,
      FINGERUP,
      FINGERMOTION,
      DOLLARGESTURE               = 0x800,
      DOLLARRECORD,
      MULTIGESTURE,
      CLIPBOARDUPDATE             = 0x900,
      DROPFILE                    = 0x1000,
      AUDIODEVICEADDED            = 0x1100,
      AUDIODEVICEREMOVED,
      RENDER_TARGETS_RESET        = 0x2000,
      RENDER_DEVICE_RESET,
      USEREVENT                   = 0x8000,
      EVENTTYPE_SIZER             = 0x10000)

@enum(WindowEventType::Int8,
      WINDOWEVENT_NONE=0,
      WINDOWEVENT_SHOWN=1,
      WINDOWEVENT_HIDDEN=2,
      WINDOWEVENT_EXPOSED=3,
      WINDOWEVENT_MOVED=4,
      WINDOWEVENT_RESIZED=5,
      WINDOWEVENT_SIZE_CHANGED=6,
      WINDOWEVENT_MINIMIZED=7,
      WINDOWEVENT_MAXIMIZED=8,
      WINDOWEVENT_RESTORED=9,
      WINDOWEVENT_ENTER=10,
      WINDOWEVENT_LEAVE=11,
      WINDOWEVENT_FOCUS_GAINED=12,
      WINDOWEVENT_FOCUS_LOST=13,
      WINDOWEVENT_CLOSE=14)

abstract Event

immutable CommonEvent <: Event
  typ::EventType
  timestamp::UInt32
  padding::NTuple{6, UInt64}
  CommonEvent() = new(0, 0, (0, 0, 0, 0, 0, 0))
end

immutable WindowEvent <: Event
  typ::EventType
  timestamp::UInt32
  windowID::UInt32
  event::WindowEventType
  padding::NTuple{3, UInt8}
  data1::Int32
  data2::Int32
end

immutable KeyboardEvent <: Event
  typ::EventType
  timestamp::UInt32
  windowID::UInt32
  state::UInt8
  repeat::UInt8
  padding::NTuple{2, UInt8}
  keysym::Cuint
end

immutable MouseMotionEvent <: Event
  typ::EventType
  timestamp::UInt32
  windowID::UInt32
  which::UInt32
  state::UInt32
  x::Int32
  y::Int32
  xrel::Int32
  yrel::Int32
end

immutable MouseButtonEvent <: Event
  typ::EventType
  timestamp::UInt32
  windowID::UInt32
  which::UInt32
  state::UInt32
  clicks::UInt8
  padding::NTuple{1, UInt8}
  x::Int32
  y::Int32
end

immutable MouseWheelEvent <: Event
  typ::EventType
  timestamp::UInt32
  windowID::UInt32
  which::UInt32
  x::Int32
  y::Int32
  direction::UInt32
end

immutable QuitEvent <: Event
  typ::EventType
  timestamp::UInt32
end

immutable OSEvent <: Event
  typ::EventType
  timestamp::UInt32
end

immutable AudioDeviceEvent <: Event
  typ::EventType
  timestamp::UInt32
  which::UInt32
  capture::UInt8
  padding::NTuple{3, UInt8}
end

@sdl_const ADDEVENT  0
@sdl_const PEEKEVENT 1
@sdl_const GETEVENT  2

@sdl_function PeepEvents(events::Ref{CommonEvent}, numevents::Cint, action::Cint, minType::UInt32, maxType::UInt32)::Cint

@sdl_function HasEvent(typ::UInt32)::Cint
@sdl_function HasEvents(minType::UInt32, maxType::UInt32)::Cint

@sdl_function FlushEvent(typ::UInt32)::Void
@sdl_function FlushEvents(minType::UInt32, maxType::UInt32)::Void

@sdl_function PollEvent(event::Ref{CommonEvent})::Cint
@sdl_function WaitEvent(event::Ref{CommonEvent})::Cint
@sdl_function WaitEventTimeout(event::Ref{CommonEvent}, timeout::Int)::Cint

@sdl_function PushEvent(event::Ref{CommonEvent})::Cint

@sdl_function AddEventWatch(filter::Ref{Function}, userdata::Ptr{Any})::Cint
@sdl_function DelEventWatch(filter::Ref{Function}, userdata::Ptr{Any})::Cint

function DecodeEvent(ev::CommonEvent)
  typ = DecodeEventType(Val{ev.typ}())
  ref = Ref(ev)
  ptr = Base.unsafe_convert(Ptr{Void}, Ref(ev))
  ptr = convert(Ptr{WindowEvent}, ptr)
  unsafe_load(convert(Ptr{typ}, Base.unsafe_convert(Ptr{Void}, Ref(ev))))
end

DecodeEventType(::Val{QUIT})                      = QuitEvent
# DecodeEventType(::Val{APP_TERMINATING})           =
# DecodeEventType(::Val{APP_LOWMEMORY})             =
# DecodeEventType(::Val{APP_WILLENTERBACKGROUND})   =
# DecodeEventType(::Val{APP_DIDENTERBACKGROUND})    =
# DecodeEventType(::Val{APP_WILLENTERFOREGROUND})   =
# DecodeEventType(::Val{APP_DIDENTERFOREGROUND})    =
DecodeEventType(::Val{WINDOWEVENT})               = WindowEvent
# DecodeEventType(::Val{SYSWMEVENT})                =
DecodeEventType(::Val{KEYDOWN})                   = KeyboardEvent
DecodeEventType(::Val{KEYUP})                     = KeyboardEvent
DecodeEventType(::Val{TEXTEDITING})               = KeyboardEvent
DecodeEventType(::Val{TEXTINPUT})                 = KeyboardEvent
DecodeEventType(::Val{KEYMAPCHANGED})             = KeyboardEvent
DecodeEventType(::Val{MOUSEMOTION})               = MouseMotionEvent
DecodeEventType(::Val{MOUSEBUTTONDOWN})           = MouseButtonEvent
DecodeEventType(::Val{MOUSEBUTTONUP})             = MouseButtonEvent
DecodeEventType(::Val{MOUSEWHEEL})                = MouseWheelEvent
# DecodeEventType(::Val{JOYAXISMOTION})             =
# DecodeEventType(::Val{JOYBALLMOTION})             =
# DecodeEventType(::Val{JOYHATMOTION})              =
# DecodeEventType(::Val{JOYBUTTONDOWN})             =
# DecodeEventType(::Val{JOYBUTTONUP})               =
# DecodeEventType(::Val{JOYDEVICEADDED})            =
# DecodeEventType(::Val{JOYDEVICEREMOVED})          =
# DecodeEventType(::Val{CONTROLLERAXISMOTION})      =
# DecodeEventType(::Val{CONTROLLERBUTTONDOWN})      =
# DecodeEventType(::Val{CONTROLLERBUTTONUP})        =
# DecodeEventType(::Val{CONTROLLERDEVICEADDED})     =
# DecodeEventType(::Val{CONTROLLERDEVICEREMOVED})   =
# DecodeEventType(::Val{CONTROLLERDEVICEREMAPPED})  =
# DecodeEventType(::Val{FINGERDOWN})                =
# DecodeEventType(::Val{FINGERUP})                  =
# DecodeEventType(::Val{FINGERMOTION})              =
# DecodeEventType(::Val{DOLLARGESTURE})             =
# DecodeEventType(::Val{DOLLARRECORD})              =
# DecodeEventType(::Val{MULTIGESTURE})              =
# DecodeEventType(::Val{CLIPBOARDUPDATE})           =
# DecodeEventType(::Val{DROPFILE})                  =
DecodeEventType(::Val{AUDIODEVICEADDED})          = AudioDeviceEvent
DecodeEventType(::Val{AUDIODEVICEREMOVED})        = AudioDeviceEvent
# DecodeEventType(::Val{RENDER_TARGETS_RESET})      =
# DecodeEventType(::Val{RENDER_DEVICE_RESET})       =
# DecodeEventType(::Val{USEREVENT})                 =
