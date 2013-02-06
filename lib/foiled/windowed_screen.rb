module Foiled

class WindowedScreen < XtermScreen
  attr_accessor :root_window

  def initialize
    super
    @root_window = Window.new
    @root_window.buffer.dirty

    event_manager.add_handler :tick do
      if redraw_area = root_window.requested_redraw_area
        root_window.draw
        buffer = root_window.buffer
        output.draw_buffer buffer.dirty_area.loc, buffer.dirty_subbuffer
        buffer.clean
      end
    end

    event_manager.add_handler :resize do |event|
      root_window.size = event[:size]
    end

    event_manager.add_handler :mouse do |event|
      root_window.mouse_event event.clone
    end
  end

end
end
