module Foiled

# Event handlers are procs which have one input: the event.
# There can be more than one handler per event-type. Handlers for the same event type are called in the reverse of the order they were added with add_handler.
# Event handlers return a true value if they handled the event and no more handlers should be called.
#
# Events are hashs. The :type field is a symbol specifying the event type. Other key/values are event-specific
#
# Special handlers:
#   :all => gets all (real) events. Returning true will NOT stop event processing.
#       All gets access to the events first - and can alter them
#       All does NOT get :tick events
#   :unhandled_event => if the event has no handler, this handler is used instead. New event looks like this:
#       :type => :unhandled_event, :event => unhandled_event.clone
#   :event_exception => if an exception escaped the event handler, a new event is handed to this handler. New event looks like this:
#       :type => :event_exception, :event => original_event.clone, :exception => exception_caught, :handler => handler_that_threw_error
class EventManager
  attr_accessor :event_handlers, :parent

  def initialize(parent)
    @parent = parent
    @event_handlers = {}
    add_handler(:event_exception) do |e|
      XtermLog.log "#{self.class}(parent=#{parent.inspect}): event_exception: #{e[:exception].inspect}"
      XtermLog.log "  "+ e[:exception].backtrace.join("\n  ")
    end
    add_handler(){}
  end

  def add_handler(*event_type, &block)
    event_handlers[event_type] ||= []
    event_handlers[event_type] << block
  end

  def add_last_handler(*event_type, &block)
    event_handlers[event_type] = [block] + (event_handlers[event_type] || [])
  end

  def send_to_each_handler(handlers, event)
    return if !handlers && event[:type] == :unhandled_event
    return handle_event :type => :unhandled_event, :event => event.clone unless handlers

    handlers.reverse_each do |handler|
      begin
        handler.call event
      rescue Exception => e
        if event[:type] != :event_exception
          handle_event :type => :event_exception, :event => event.clone, :exception => e, :handler => handler
        else
          XtermLog.log "exception in :event_exception handler: #{e.inspect}"
        end
        false
      end
    end
  end

  def handle_event(event)
    type = event[:type]
    type = [type] unless type.kind_of?(Array)

    type.length.times.reverse_each do |l|
      send_to_each_handler(event_handlers[type[0..l]], event)
    end
    send_to_each_handler(event_handlers[[]], event) unless type == [:tick] || type == [:unhandled_event]
  end

  def handle_events(events)
    events.each {|event| handle_event(event)}
  end
end
end
