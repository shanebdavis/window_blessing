module Foiled
class XtermState
  attr_accessor :state

  def initialize(event_manager)
    @size = point(-1,-1)
    @state = {}

    event_manager.add_handler :xterm_state do |event|
      state_type = event[:state_type]
      old_state = state[state_type]
      new_state = event[:state]
      state[state_type] = new_state
      if old_state!=new_state
        event_manager.add_event :type => :state_change, :state_type => state_type, :old_state => old_state, :state => new_state
      end
    end
  end

  def size; state[:size] end
end
end
