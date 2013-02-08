module Foiled
module Evented
  def event_manager
    @event_manager ||= EventManager.new(self)
  end

  # define event handler
  def on(*args,&block)
    event_manager.add_handler *args, &block
    self
  end

  def handle_event(event)
    event_manager.handle_event(event)
  end

end
end
