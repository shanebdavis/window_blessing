module WindowBlessing
module Evented
  def event_manager
    @event_manager ||= EventManager.new(self)
  end

  # define event handler
  def on(*args,&block)
    event_manager.on *args, &block
    self
  end

  def handle_event(event)
    event[:object] = self
    event_manager.handle_event(event)
  end

end
end
