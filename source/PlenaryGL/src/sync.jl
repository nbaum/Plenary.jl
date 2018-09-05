
immutable Sync
  name::GLsync
end

valid(sync::Sync) = glIsSync(sync.name)
delete(s::Sync) = glDeleteSync(s.name)

FenceSync() = finalizer(Sync(glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)))

wait(sync::Sync; timeout::UInt64 = typemax(UInt64), flush = true) = glClientWaitSync(sync.name, flush ? GL_SYNC_FLUSH_COMMANDS_BIT : 0, timeout)

get(sync::Sync, pname::GLenum) = getone(GLint, v -> glGetSynciv(sync.name, pname, 1, C_NULL, v))

signaled(sync::Sync) = get(sync, GL_SYNC_STATUS)

function label(sync::Sync)
  buffer = Array{UInt8}(8192)
  glGetObjectPtrLabel(name(sync), length(buffer), C_NULL, pointer(buffer))
  String(buffer)
end

function label!(sync::Sync, label::String)
  glObjectPtrLabel(name(sync), length(label), pointer(label))
  sync
end
