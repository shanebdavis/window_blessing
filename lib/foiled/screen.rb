require "curses"
require "highline"

module Foiled
module XTerm
  # ref: http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
  def out(str)
    $stdout.print str
  end

  def cursor(loc)
    out "\e[#{loc.y},#{loc.x}H"
  end

  def clear
    out "\e[2J"
  end

  def enable_mouse
    "\e[?1003h"
  end

  def disable_mouse
    "\e[?1003l"
  end
end

class Screen
  include Curses
  include Tools
  attr_accessor :sleep_delay
  attr_accessor :screen_buffer
  attr_accessor :cursor_loc

  def initialize
    @sleep_delay = 0.01
    @on_key_blocks = [lambda do |key|
      case key
      when ?Q, ?q then quit;true
      end
    end]
    @on_tick_blocks = []
    @screen_buffer = Buffer.new point(20,20)
    @cursor_loc = point
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
    cursor loc
    out text
  end

  def draw(loc, buffer)
    loc = loc.clone
    buffer.contents.each do |line|
      write loc, line
      loc.y += 1
    end
  end

  def update_from_screen_buffer
    if dirty_buffer = screen_buffer.dirty_subbuffer
      write point(0,1), "diry_area: #{screen_buffer.dirty_area}"
      draw screen_buffer.dirty_area.loc, dirty_buffer
      screen_buffer.clean
      cursor cursor_loc
    end
  end

  def event_loop
    @running = true
    mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION)
    on_key do |key|
      case key
      when KEY_MOUSE
        m = getmouse
        write point(0,3), "key[#{key}]: #{[m.bstate,m.x,m.y,m.z]} #{Time.now.sec}"
      end
    end

    while @running
      screen_buffer.size = point(*HighLine::SystemExtensions.terminal_size)
      c = getch
      @on_key_blocks.reverse.inject(false) {|responded,b|!responded && b.call(c)} if c
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
