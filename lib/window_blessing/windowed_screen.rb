module WindowBlessing

class WindowedScreen < XtermScreen
  attr_accessor :root_window

  def time(category,info)
    start = Time.now
    yield
    stop = Time.now
    @total_time ||= 0
    @draw_count ||= 0
    @draw_count += 1
    @total_time += stop - start
    XtermLog.log "#{category} time = #{((@total_time/@draw_count)*1000).to_i}ms #{info}"
  end

  def initialize
    super
    @root_window = Window.new
    @root_window.buffer.dirty
    @root_window.name = "root_window"

    event_manager.on :tick do
      if root_window.redraw_requested?
        root_window.draw
        buffer = root_window.buffer
        output.draw_buffer buffer.dirty_area.loc, buffer.dirty_subbuffer if buffer.dirty_area
        buffer.clean
      end
    end

    event_manager.on :key_press do |event|
      root_window.route_keyboard_event event
    end

    event_manager.on :string_input do |event|
      root_window.route_keyboard_event event
    end

    event_manager.on :resize do |event|
      root_window.size = event[:size]
      root_window.request_redraw_internal
    end

    event_manager.on :pointer do |event|
      root_window.route_pointer_event event.clone
    end
  end

end
end
