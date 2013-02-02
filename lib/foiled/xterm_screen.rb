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
    process_events
    yield self
  end

  # run xterm raw-session
  def start(with_mouse=false, &block)
    output.clean_screen(with_mouse) do
      initialize_screen &block
      event_loop
    end
  end
end
end
