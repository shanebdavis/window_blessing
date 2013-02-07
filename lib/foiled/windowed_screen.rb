module Foiled

class WindowedScreen < XtermScreen
  attr_accessor :root_window

  def initialize
    super
    @root_window = Window.new
    @root_window.buffer.dirty

    event_manager.add_handler :tick do
      if redraw_area = root_window.requested_redraw_area
        start = Time.now
        root_window.draw
        buffer = root_window.buffer
        output.draw_buffer buffer.dirty_area.loc, buffer.dirty_subbuffer
        buffer.clean
        stop = Time.now
        @total_time ||= 0
        @draw_count ||= 0
        @draw_count += 1
        @total_time += stop - start
        XtermLog.log "redraw time = #{((@total_time/@draw_count)*1000).to_i}ms size=#{redraw_area.size} = #{redraw_area.size.x * redraw_area.size.y}"
      end
    end

    event_manager.add_handler :resize do |event|
      root_window.size = event[:size]
      root_window.request_internal_redraw
    end

    event_manager.add_handler :mouse do |event|
      root_window.pointer_event event.clone
    end
  end

end
end
