
@sdl_const GL_RED_SIZE                   0
@sdl_const GL_GREEN_SIZE                 1
@sdl_const GL_BLUE_SIZE                  2
@sdl_const GL_ALPHA_SIZE                 3
@sdl_const GL_BUFFER_SIZE                4
@sdl_const GL_DOUBLEBUFFER               5
@sdl_const GL_DEPTH_SIZE                 6
@sdl_const GL_STENCIL_SIZE               7
@sdl_const GL_ACCUM_RED_SIZE             8
@sdl_const GL_ACCUM_GREEN_SIZE           9
@sdl_const GL_ACCUM_BLUE_SIZE            10
@sdl_const GL_ACCUM_ALPHA_SIZE           11
@sdl_const GL_STEREO                     12
@sdl_const GL_MULTISAMPLEBUFFERS         13
@sdl_const GL_MULTISAMPLESAMPLES         14
@sdl_const GL_ACCELERATED_VISUAL         15
@sdl_const GL_RETAINED_BACKING           16
@sdl_const GL_CONTEXT_MAJOR_VERSION      17
@sdl_const GL_CONTEXT_MINOR_VERSION      18
@sdl_const GL_CONTEXT_EGL                19
@sdl_const GL_CONTEXT_FLAGS              20
@sdl_const GL_CONTEXT_PROFILE_MASK       21
@sdl_const GL_SHARE_WITH_CURRENT_CONTEXT 22
@sdl_const GL_FRAMEBUFFER_SRGB_CAPABLE   23
@sdl_const GL_CONTEXT_RELEASE_BEHAVIOR   24

@sdl_const GL_CONTEXT_PROFILE_CORE          0x0001
@sdl_const GL_CONTEXT_PROFILE_COMPATABILITY 0x0002
@sdl_const GL_CONTEXT_PROFILE_ES            0x0004

@sdl_const GL_CONTEXT_DEBUG_FLAG              0x0001
@sdl_const GL_CONTEXT_FORWARD_COMPATIBLE_FLAG 0x0002
@sdl_const GL_CONTEXT_ROBUST_ACCESS_FLAG      0x0004
@sdl_const GL_CONTEXT_RESET_ISOLATION_FLAG    0x0008

@sdl_const GL_CONTEXT_RELEASE_BEHAVIOR_NONE   0x0000
@sdl_const GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH  0x0001

## OpenGL functions

@sdl_function GL_LoadLibrary(path::Cstring)::Cint
@sdl_function GL_GetProcAddress(proc::Cstring)::Ptr{Void}
@sdl_function GL_UnloadLibrary()::Void;
@sdl_function GL_ExtensionSupported(extension::Cstring)::Cint
@sdl_function GL_ResetAttributes()::Void
@sdl_function GL_SetAttribute(attr::Cint, value::Cint)::Void
@sdl_function GL_GetAttribute(attr::Cint)::Cint
@sdl_function GL_CreateContext(window::Ptr{Window})::Ptr{GLContext}
@sdl_function GL_MakeCurrent(window::Ptr{Window}, context::Ptr{GLContext})::Cint
@sdl_function GL_GetCurrentWindow()::Ptr{Window}
@sdl_function GL_GetCurrentContext()::Ptr{GLContext}
@sdl_function GL_GetDrawableSize(window::Ptr{Window}, w::Ref{Cint}, h::Ref{Cint})::Void
@sdl_function GL_SetSwapInterval(internal::Cint)::Int
@sdl_function GL_GetSwapInterval()::Int
@sdl_function GL_SwapWindow(window::Ptr{Window})::Void
@sdl_function GL_DeleteContext(context::Ptr{GLContext})::Void

import PlenaryGL

PlenaryGL.GetProcAddress(s::String) = GL_GetProcAddress(s)
