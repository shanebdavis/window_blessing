module Foiled
class XtermScreen
  include GuiGeo
  include GuiGeo::Tools

  attr_accessor :input, :output, :event_manager, :state, :event_queue

  def initialize
    @event_manager = EventManager.new(self)
    @state = XtermState.new @event_manager
    @input = XtermInput.new
    @output = XtermOutput.new(@state)
    @running = true
    @pending_events = []
    @event_queue = EventQueue.new

    @event_manager.add_handler :key_press do |event|
      quit if event[:key]==:control_q
    end
  end

  def inspect
    "<#{self.class}:#{object_id}>"
  end

  def quit; @running = false; end
  def running?; @running; end

  def queue_event(e); event_queue << e end
  def queued_events?; !event_queue.empty? end

  def queue_pending_xterm_events
    event_queue << input.read_events
  end

  def wait_for_events(max=100)
    count = max
    while !queued_events? && count > 0
      queue_pending_xterm_events
      count -= 1
      sleep 0.01
    end
    raise "no events!" unless queued_events?
  end

  def process_queued_events
    event_manager.handle_events event_queue.pop_all
  end

  def process_events
    queue_pending_xterm_events
    queue_event :type => :tick
    process_queued_events
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
    in_xterm_state(options) do
      initialize_screen
      yield self
      event_loop
    end
  end


  # options
  #   :mouse => true
  #   :no_cursor => true
  #   :alternate_screen => true
  #   :full => true (enables all above features)
  #   :utf8
  def in_xterm_state(options = {})
    output.echo_off
    output.enable_alternate_screen  if options[:full] || options[:alternate_screen]
    output.enable_mouse             if options[:full] || options[:mouse]
    output.hide_cursor              if options[:full] || options[:no_cursor]
    output.enable_utf8              if options[:utf8]
    output.enable_focus_events
    output.enable_resize_events
    output.clear

    yield self
  ensure
    output.reset_all
    output.disable_utf8             if options[:utf8]
    if options[:full] || options[:alternate_screen]
      output.reset_color
      output.clear
      output.disable_alternate_screen
    end
  end

end
end
