require "curses"

module Foiled
class Screen
  include Curses
  include Tools
  attr_accessor :sleep_delay

  def initialize
    @sleep_delay = 0.01
    @on_key_blocks = []
    @on_tick_blocks = []
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

  def event_loop
    @running = true
    while @running
      c = getch
      @on_key_blocks.each {|b|b.call(c)} if c
      @on_tick_blocks.each {|b|b.call}
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
