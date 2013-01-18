require "curses"

module Foiled
class Screen
  include Curses
  include Tools
  attr_accessor :sleep_delay

  def initialize
    @sleep_delay = 0.01
    @on_key_block = lambda do |key|
      case key
      when ?Q, ?q then quit
      end
    end
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

  def draw(loc, frame_buffer)
    loc = loc.clone
    frame_buffer.contents.each do |line|
      setpos loc.y, loc.x
      addstr line
      loc.y += 1
    end
  end

  def event_loop
    @running = true
    while @running
      c = getch
      @on_key_block.call(c) if c
      @on_tick.call if @on_tick
      sleep sleep_delay
    end
  end

  def on_key(&block)
    @on_key_block = block
  end
  def on_tick(&block)
    @on_tick = block
  end
end
end
