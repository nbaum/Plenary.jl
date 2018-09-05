@sdl_const WINDOW_FULLSCREEN         0x00000001
@sdl_const WINDOW_OPENGL             0x00000002
@sdl_const WINDOW_SHOWN              0x00000004
@sdl_const WINDOW_HIDDEN             0x00000008
@sdl_const WINDOW_BORDERLESS         0x00000010
@sdl_const WINDOW_RESIZABLE          0x00000020
@sdl_const WINDOW_MINIMIZED          0x00000040
@sdl_const WINDOW_MAXIMIZED          0x00000080
@sdl_const WINDOW_INPUT_GRABBED      0x00000100
@sdl_const WINDOW_INPUT_FOCUS        0x00000200
@sdl_const WINDOW_MOUSE_FOCUS        0x00000400
@sdl_const WINDOW_FULLSCREEN_DESKTOP 0x00001000 | WINDOW_FULLSCREEN
@sdl_const WINDOW_FOREIGN            0x00000800
@sdl_const WINDOW_ALLOW_HIGHDPI      0x00002000
@sdl_const WINDOW_MOUSE_CAPTURE      0x00004000

@sdl_const WINDOWPOS_UNDEFINED       0x1FFF0000
@sdl_const WINDOWPOS_CENTERED        0x2FFF0000

@sdl_const HITTEST_NORMAL             0
@sdl_const HITTEST_DRAGGABLE          1
@sdl_const HITTEST_RESIZE_TOPLEFT     2
@sdl_const HITTEST_RESIZE_TOP         3
@sdl_const HITTEST_RESIZE_TOPRIGHT    4
@sdl_const HITTEST_RESIZE_RIGHT       5
@sdl_const HITTEST_RESIZE_BOTTOMRIGHT 6
@sdl_const HITTEST_RESIZE_BOTTOM      7
@sdl_const HITTEST_RESIZE_BOTTOMLEFT  8
@sdl_const HITTEST_RESIZE_LEFT        9

## Display functions

@sdl_function GetNumVideoDrivers()::Cint
@sdl_function GetVideoDriver(index::Cint)::Cstring
@sdl_function VideoInit(driver::Cstring)::Cint
@sdl_function VideoQuit()::Void
@sdl_function GetCurrentVideoDriver()::Cstring
@sdl_function GetNumVideoDisplays()::Cint
@sdl_function GetDisplayName(index::Cint)::Cstring
@sdl_function GetDisplayBounds(index::Cint, rect::Ref{Rect})::Cint
@sdl_function GetDisplayDPI(index::Cint, ddpi::Ref{Cfloat}, hdpi::Ref{Cfloat}, vdpi::Ref{Cfloat})::Cint
@sdl_function GetNumDisplayModes(index::Cint)::Cint
@sdl_function GetDisplayMode(displayIndex::Cint, modeIndex::Cint, mode::Ref{DisplayMode})::Cint
@sdl_function GetDesktopDisplayMode(index::Cint, mode::Ref{DisplayMode})::Cint
@sdl_function GetCurrentDisplayMode(index::Cint, mode::Ref{DisplayMode})::Cint
@sdl_function GetClosestDisplayMode(index::Cint, mode::Ref{DisplayMode}, closest::Ref{DisplayMode})::Ref{DisplayMode}
@sdl_function GetWindowDisplayIndex(window::Ptr{Window})::Cint
@sdl_function SetWindowDisplayMode(window::Ptr{Window}, mode::Ref{DisplayMode})::Cint
@sdl_function GetWindowDisplayMode(window::Ptr{Window}, mode::Ref{DisplayMode})::Cint
@sdl_function GetWindowPixelFormat(window::Ptr{Window})::UInt32

## Window functions

@sdl_function CreateWindow(title::Cstring, x::Cint, y::Cint, w::Cint, h::Cint, flags::UInt32)::Ptr{Window}
@sdl_function CreateWindowFrom(data::Ptr{Void})::Ptr{Window}
@sdl_function GetWindowID(window::Ptr{Window})::UInt32
@sdl_function GetWindowFlags(window::Ptr{Window})::UInt32
@sdl_function SetWindowTitle(window::Ptr{Window}, title::Cstring)::Void
@sdl_function GetWindowTitle(window::Ptr{Window})::Cstring
@sdl_function SetWindowIcon(window::Ptr{Window}, icon::Ptr{Surface})::Void
@sdl_function SetWindowData(window::Ptr{Window}, name::Cstring, userData::Ptr{Any})::Void
@sdl_function GetWindowData(window::Ptr{Window}, name::Cstring)::Ptr{Any}
@sdl_function SetWindowPosition(window::Ptr{Window}, x::Cint, y::Cint)::Void
@sdl_function GetWindowPosition(window::Ptr{Window}, x::Ref{Cint}, y::Ref{Cint})::Void
@sdl_function SetWindowSize(window::Ptr{Window}, w::Cint, h::Cint)::Void
@sdl_function GetWindowSize(window::Ptr{Window}, w::Ref{Cint}, h::Ref{Cint})::Void
@sdl_function SetWindowMinimumSize(window::Ptr{Window}, w::Cint, h::Cint)::Void
@sdl_function GetWindowMinimumSize(window::Ptr{Window}, w::Ref{Cint}, h::Ref{Cint})::Void
@sdl_function SetWindowMaximumSize(window::Ptr{Window}, w::Cint, h::Cint)::Void
@sdl_function GetWindowMaximumSize(window::Ptr{Window}, w::Ref{Cint}, h::Ref{Cint})::Void
@sdl_function SetWindowBordered(window::Ptr{Window}, bordered::Cint)::Void
@sdl_function ShowWindow(window::Ptr{Window})::Void
@sdl_function HideWindow(window::Ptr{Window})::Void
@sdl_function RaiseWindow(window::Ptr{Window})::Void
@sdl_function MaximizeWindow(window::Ptr{Window})::Void
@sdl_function MinimizeWindow(window::Ptr{Window})::Void
@sdl_function RestoreWindow(window::Ptr{Window})::Void
@sdl_function SetWindowFullscreen(window::Ptr{Window}, flags::UInt32)::Void
@sdl_function GetWindowSurface(window::Ptr{Window})::Ptr{Surface}
@sdl_function UpdateWindowSurface(window::Ptr{Window})::Cint
@sdl_function UpdateWindowSurfaceRects(window::Ptr{Window}, rects::Ptr{Rect}, numrects::Cint)::Cint
@sdl_function SetWindowGrab(window::Ptr{Window}, grabbed::Cint)::Void
@sdl_function GetWindowGrab(window::Ptr{Window})::Cint
@sdl_function GetGrabbedWindow()::Ptr{Window}
@sdl_function SetWindowBrightness(window::Ptr{Window}, brightness::Cfloat)::Cint
@sdl_function GetWindowBrightness(window::Ptr{Window})::Cfloat
@sdl_function SetWindowGammaRamp(window::Ptr{Window}, red::Ref{UInt16}, green::Ref{UInt16}, blue::Ref{UInt16})::Cint
@sdl_function GetWindowGammaRamp(window::Ptr{Window}, red::Ref{UInt16}, green::Ref{UInt16}, blue::Ref{UInt16})::Cint
@sdl_function HitTest(window::Ptr{Window}, area::Ref{Point}, data::Ptr{Void})::Cint
@sdl_function SetWindowHitTest(window::Ptr{Window}, callback::Ptr{Function}, data::Ptr{Void})::Cint
@sdl_function DestroyWindow(window::Ptr{Window})::Void

@sdl_function IsScreenSaverEnabled()::Cint
@sdl_function EnableScreenSaver()::Void
@sdl_function DisableScreenSaver()::Void
