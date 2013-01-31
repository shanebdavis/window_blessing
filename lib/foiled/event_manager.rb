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
  attr_accessor :event_handlers

  def initialize
    @event_handlers = {}
    add_handler(:unhandled_event){}
    add_handler(:event_exception){}
    add_handler(:all){}
  end

  def add_handler(event_type, &block)
    event_handlers[event_type] ||= []
    event_handlers[event_type] << block
  end

  def send_to_each_handler(handlers, event, stop_on_true = true)
    raise "hell" if !handlers && event[:type] == :unhandled_event
    return handle_event :type => :unhandled_event, :event => event.clone unless handlers

    handlers.reverse_each do |handler|
      break unless begin
        handler.call event
      rescue Exception => e
        if event[:type] != :event_exception
          handle_event :type => :event_exception, :event => event.clone, :exception => e, :handler => handler
        else
          XtermLog.log "exception in :event_exception handler: #{e.inspect}"
        end
        false
      end && stop_on_true
    end
  end

  def handle_event(event)
    type = event[:type]
    send_to_each_handler(event_handlers[:all], event, false) unless type == :tick
    send_to_each_handler(event_handlers[type], event)
  end

  def handle_events(events)
    events.each {|event| handle_event(event)}
    handle_event :type => :tick
  end
end
end
