module WindowBlessing
class XtermState
  attr_accessor :state

  def initialize(event_manager)
    @state = {:size => point(-1,-1)}

    event_manager.add_handler :xterm_state do |event|
      state_type = event[:state_type]
      old_state = state[state_type]
      new_state = event[:state]
      state[state_type] = new_state
      if old_state!=new_state
        case state_type
        when :size
          event_manager.handle_event :type => :resize, :old_size => old_state, :size => new_state, :raw => event[:raw]
        else
          event_manager.handle_event :type => :state_change, :state_type => state_type, :old_state => old_state, :state => new_state, :raw => event[:raw]
        end

      end
    end
  end

  def size; state[:size] end
end
end
