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
        screen_buffer.size = event[:state]
        screen_buffer.dirty
      end
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

  #def initialize_screen(*args,&block)
  #  screen_buffer.clear
  #  super *args, &block
  #end

  # run xterm raw-session
  def start(with_mouse=false, &block)
    output.without_cursor do
      super
    end
  end

  def update_from_screen_buffer
    if dirty_buffer = screen_buffer.dirty_subbuffer
      XtermLog.log "diry_area: #{screen_buffer.dirty_area}"
      draw screen_buffer.dirty_area.loc, dirty_buffer
      screen_buffer.clean
      cursor cursor_loc
    end
  end

end
end
