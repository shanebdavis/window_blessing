module Foiled
class XtermScreen
  include GuiGeo
  include GuiGeo::Tools

  attr_accessor :input, :output, :event_manager, :state

  def initialize
    @event_manager = EventManager.new
    @state = XtermState.new @event_manager
    @input = XtermInput.new
    @output = XtermOutput.new(@state)
    @running = true
    @pending_events = []

    @event_manager.add_handler :characters do |event|
      quit if event[:raw][/q/]
    end
  end

  def quit; @running = false; end
  def running?; @running; end

  def wait_for_events(max=100)
    count = max
    while event_manager.events.length==0 && count > 0
      event_manager.add_events input.read_events
      count -= 1
      sleep 0
    end
    raise "no events!" unless event_manager.events.length > 0
  end

  def process_events
    event_manager.add_events input.read_events
    event_manager.handle_events
  end

  def event_loop
    while running?
      process_events
      sleep 1/60.0
    end
  end

  def initialize_screen
    output.request_state_update
    wait_for_events
    process_events
    yield self
  end

  # run xterm raw-session
  def start(with_mouse=false, &block)
    output.clean_screen(with_mouse) do
    XtermLog.log "start 1"
      initialize_screen &block
    XtermLog.log "start 2"
      event_loop
    XtermLog.log "start 3"
    end
  end
end
end
