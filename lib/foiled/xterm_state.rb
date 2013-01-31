module Foiled
class XtermState
  attr_accessor :size

  def initialize(event_manager)
    @size = point(-1,-1)
    xterm_state = self

    event_manager.instance_eval do
      add_handler :xterm_state do |event|
        xterm_state.instance_variable_set "@#{event[:state_type]}", event[:state]
      end
    end
  end
end
end
