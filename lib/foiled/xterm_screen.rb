module Foiled
class XtermScreen
  include GuiGeo
  include GuiGeo::Tools

  attr_accessor :screen_size, :input, :output, :event_manager, :state

  def initialize
    @screen_size = point(10,10)
    @input = XtermInput.new
    @output = XtermOutput.new
    @event_manager = EventManager.new
    @state = XtermState.new @event_manager
    @running = true

    @event_manager.add_handler :characters do |event|
      quit if event[:raw][/q/]
    end
  end

  def quit; @running = false; end
  def running?; @running; end

  def update_state
    output.request_state_update
    process_events
  end

  def process_events
    event_manager.handle_events input.read_events
  end

  def event_loop
    while running?
      process_events
      sleep 1/60.0
    end
  end

  # run xterm raw-session
  def start(with_mouse=false)
    output.clean_screen(with_mouse) do
      update_state
      yield self
      event_loop
    end
  end
end
end
