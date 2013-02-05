module Foiled

class WindowUI < XtermScreen
  attr_accessor :screen_buffer
  include GuiGeo


  def initialize
    super
    @screen_buffer = Buffer.new point(20,20)

    event_manager.add_handler :tick do
      update_from_screen_buffer
    end

    event_manager.add_handler :state_change do |event|
      if event[:state_type]==:size
        @screen_buffer = Buffer.new event[:state]
        @screen_buffer.dirty
      end
    end
  end

  def quit
    @running = false
  end

  # run xterm raw-session
  def start(with_mouse=false, &block)
    output.without_cursor do
      super
    end
  end

  def update_from_screen_buffer
    if dirty_buffer = screen_buffer.dirty_subbuffer
      XtermLog.log "#{self.class}#update_from_screen_buffer() diry_area: #{screen_buffer.dirty_area}"
      output.draw_buffer screen_buffer.dirty_area.loc, dirty_buffer
      screen_buffer.clean
    end
  end

end
end
