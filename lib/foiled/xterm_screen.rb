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
      sleep 0.01
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
  end

  # run xterm raw-session
  # options
  #
  def start(options={})
    clean_screen(options) do
      initialize_screen
      yield self
      event_loop
    end
  end


  # options
  #   :mouse => true
  #   :no_cursor => true
  #   :alternate_screen => true
  #   :full => true (enables all features)
  def clean_screen(options = {})
    output.echo_off
    output.enable_alternate_screen  if options[:full] || options[:alternate_screen]
    output.enable_mouse             if options[:full] || options[:mouse]
    output.hide_cursor              if options[:full] || options[:no_cursor]
    output.enable_focus_events
    output.enable_resize_events
    output.clear

    yield self
  ensure
    output.reset_all
    output.disable_alternate_screen if options[:full] || options[:alternate_screen]
  end

  def alternate_screen
    yield
  ensure
    out "\e[?47l"
  end

  # execute passed in block with the cursor hidden, then re-show it
  def without_cursor
    hide_cursor
    yield self
  ensure
    show_cursor
  end

end
end
