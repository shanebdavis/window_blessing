require "curses"

module Foiled
class Screen
  include Curses
  include Tools
  attr_accessor :sleep_delay
  attr_accessor :screen_buffer

  def initialize
    @sleep_delay = 0.01
    @on_key_blocks = [lambda do |key|
      case key
      when ?Q, ?q then quit;true
      end
    end]
    @on_tick_blocks = []
    @screen_buffer = Buffer.new point(20,20)
  end

  def quit
    @running = false
  end

  def start_curses
    noecho # do not show typed chars
    nonl # turn off newline translation
    stdscr.keypad(true) # enable arrow keys
    raw # give us all other keys
    stdscr.nodelay = 1 # do not block -> we can use timeouts
    init_screen
  end

  def end_curses
    clear # needed to clear the menu/status bar on windows
    close_screen
  end

  def open(&block)
    start_curses
    instance_eval &block
    event_loop
  ensure
    end_curses
  end

  def cursor(loc)
    setpos loc.y, loc.x
  end

  def write(loc, text)
    setpos loc.y, loc.x
    addstr text
  end

  def draw(loc, buffer)
    loc = loc.clone
    buffer.contents.each do |line|
      setpos loc.y, loc.x
      addstr line
      loc.y += 1
    end
  end

  def update_from_screen_buffer
    if dirty_buffer = screen_buffer.dirty_subbuffer
      write point(0,1), "diry_area: #{screen_buffer.dirty_area}"
      draw screen_buffer.dirty_area.loc, dirty_buffer
      screen_buffer.clean
    end
  end

  def event_loop
    @running = true
    while @running
      c = getch
      @on_key_blocks.reverse.each {|b|break if b.call(c)} if c
      @on_tick_blocks.each {|b|b.call}
      update_from_screen_buffer
      sleep sleep_delay
    end
  end

  def on_key(&block)
    @on_key_blocks << block
  end
  def on_tick(&block)
    @on_tick_blocks << block
  end
end
end
