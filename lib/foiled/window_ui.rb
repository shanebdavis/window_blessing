module Foiled

class WindowUI < XtermScreen
  attr_accessor :screen_buffer
  include GuiGeo


  def initialize
    @screen_buffer = Buffer.new point(20,20)

    event_manager.add_handler :tick do
      update_from_screen_buffer
    end
  end

  def quit
    @running = false
  end

  def open(&block)
    start_curses
    instance_eval &block
    event_loop
  ensure
    end_curses
  end

  def draw(loc, buffer)
    loc = loc.clone
    buffer.contents.each do |line|
      output.out_at loc, line
      loc.y += 1
    end
  end

  def initialize_screen
    screen_buffer.clear
    super
  end

  def update_from_screen_buffer
    if dirty_buffer = screen_buffer.dirty_subbuffer
      write point(0,1), "diry_area: #{screen_buffer.dirty_area}"
      draw screen_buffer.dirty_area.loc, dirty_buffer
      screen_buffer.clean
      cursor cursor_loc
    end
  end

end
end
