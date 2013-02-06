module Foiled

class BufferedScreen < XtermScreen
  attr_accessor :screen_buffer

  def initialize
    super
    @screen_buffer = Buffer.new point(20,20)

    event_manager.add_handler :tick do
      update_from_screen_buffer
    end

    event_manager.add_handler :resize do |event|
      XtermLog.log "resize #{event.inspect}"
      @screen_buffer = Buffer.new event[:size]
      @screen_buffer.dirty
    end
  end

  def update_from_screen_buffer
    if dirty_buffer = screen_buffer.dirty_subbuffer
#      XtermLog.log "#{self.class}#update_from_screen_buffer() diry_area: #{screen_buffer.dirty_area}"
      output.draw_buffer screen_buffer.dirty_area.loc, dirty_buffer
      screen_buffer.clean
    end
  end

end
end
