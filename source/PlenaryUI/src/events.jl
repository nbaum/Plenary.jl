
function handle end

function handle(e::SDL.WindowEvent)
end

function handle(e::SDL.KeyboardEvent)
end

function handle(e::SDL.MouseMotionEvent)
end

function handle(e::SDL.MouseButtonEvent)
end

function handle(e::SDL.MouseWheelEvent)
end

function handle(e::SDL.AudioDeviceEvent)
end

function handle(e::SDL.QuitEvent)
  exit()
end

function pollevent()
  e = Ref(SDL.CommonEvent())
  if SDL.WaitEventTimeout(e, 100) == 1
    handle(SDL.DecodeEvent(e[]))
  end
end

function eventloop()
  while true
    pollevent()
    yield()
  end
end
