
@sdl_const INIT_TIMER          0x00000001
@sdl_const INIT_AUDIO          0x00000010
@sdl_const INIT_VIDEO          0x00000020
@sdl_const INIT_JOYSTICK       0x00000200
@sdl_const INIT_HAPTIC         0x00001000
@sdl_const INIT_GAMECONTROLLER 0x00002000
@sdl_const INIT_EVENTS         0x00004000
@sdl_const INIT_NOPARACHUTE    0x00100000
@sdl_const INIT_EVERYTHING     INIT_TIMER | INIT_AUDIO | INIT_VIDEO | INIT_EVENTS | INIT_JOYSTICK | INIT_HAPTIC | INIT_GAMECONTROLLER

@sdl_function Init(flags::UInt32)::Cint

@sdl_function GetError()::Cstring
