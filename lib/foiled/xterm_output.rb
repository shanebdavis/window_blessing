# ref: http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
# ref: http://www.vt100.net/docs/vt102-ug/chapter5.html

module Foiled

class XtermOutput
  module SetColor
    def set_color(fg, bg=nil)
      out "\x1b[38;5;#{fg}m" if fg
      out "\x1b[48;5;#{bg}m" if bg
    end

    # fg and bg are r-g-b arrays: [0..255, 0..255, 0..255]
    # This is not supported by iTerm2: http://code.google.com/p/iterm2/issues/detail?id=218
    # konsole supports it: https://github.com/robertknight/konsole/blob/master/user-doc/README.moreColors
    def set_color_24bit(fg, bg=nil)
      out "\x1b[38;2;#{fg.join(';')}m" if fg
      out "\x1b[48;2;#{bg.join(';')}m" if bg
    end

    def reset_color
      out "\x1b[0m"
    end

    def out_color(txt, fg, bg)
      set_color(fg, bg)
      out txt
      reset_color
    end

    def set_bold; out "\x1b[1m" end
    def set_underline; out "\x1b[4m" end
  end
  include SetColor

  module SetState
    def show_cursor; out "\e[?25h"; end
    def hide_cursor; out "\e[?25l"; end

    def enable_mouse; out "\e[?1003h"; end
    def disable_mouse; out "\e[?1003l"; end

    def enable_focus_events; out "\e[?1004h" end
    def disable_focus_events; out "\e[?1004l" end

    def enable_utf8; out "\e%G" end
    def disable_utf8; out "\e%@" end

    def enable_alternate_screen
      out "\e7"
      out "\e[?47h"
    end

    def disable_alternate_screen
      out "\e[?47l"
      out "\e8"
    end

    # TODO: find out what stty raw -echo sends to xterm
    # INTERNAL NOTE: out "\e[12h" # should turn off echo according to doc, but didn't work
    # http://stackoverflow.com/questions/174933/how-to-get-a-single-character-without-pressing-enter
    def echo_off; system "stty raw -echo"; end

    # INTERNAL NOTE: out "\e[12l" # should turn echo back on
    def echo_on; system "stty -raw echo"; end

=begin
raw may set the following:
00830         option(x + "-icrnl", ""); /* map CR to NL on input */
00831         option(x + "-ixon", "");  /* enable start/stop output control */
00832         option(x + "-opost", ""); /* perform output processing */
00833         option(x + "-onlcr", ""); /* Map NL to CR-NL on output */
00834         option(x + "-isig", "");  /* enable signals */
00835         option(x + "-icanon", "");/* canonical input (erase and kill enabled) */
00836         option(x + "-iexten", "");/* enable extended functions */
00837         option(x + "-echo", "");  /* enable echoing of input characters */

=end

    # This seems to work - or at least it does SOMETHING
    # def insert_mode; out "\e[4m"; end
    # def replace_mode; out "\e[4l"; end

  end
  include SetState

  attr_accessor :xterm_state

  def initialize(xterm_state)
    @xterm_state = xterm_state
  end

  # cursor 0, 0 is the upper left hand corner
  # cursor point(0, 0) is also accepted
  def cursor(loc_or_x, y=nil)
    loc = y ? point(loc_or_x,y) : loc_or_x
    out "\e[#{loc.y+1};#{loc.x+1}H"
  end

  # raw screen output
  def out(str)
    $stdout.print str
    str
  end

  def out_at(loc, str)
    cursor(loc)
    out str
  end

  def out_at_with_color(loc, str, fg, bg)
    cursor loc
    str.chars.zip(fg,bg).each do |c,f,b|
      set_color f, b
      out c
    end
  end

  def draw_buffer(loc, buffer)
    loc = loc.clone
    buffer.each_line do |line,fg,bg|
      out_at_with_color loc, line, fg, bg
      loc.y += 1
    end
  end

  # convert all \n to \n\r
  def puts(s=nil)
    width = xterm_state.size.x
    lines = "#{s}\n".split("\n").collect do |line|
      line + " " * (width - (line.length % width))
    end
    out lines.flatten.join "\n"
  end

  def clear; out "\e[2J"; end


  # INTERNAL NOTE: xterm returns 3 numbers: ?, height, width
  # Xterm sends back response as an escape sequence. EventParser knows how to capture and interpret the result.
  def request_xterm_size; out "\e[18t"; end

  # INTERNAL NOTE: xterm returns 3 numbers: ?, height, width
  # This returns the entire screen size in pixels - not just the pixel-size of the x-term
  def request_display_pixel_size; out "\e[14t"; end

  def request_cursor_position; out "\e[?6n"; end

  def request_state_update
    request_xterm_size
    request_display_pixel_size
  end

  def enable_resize_events
    Signal.trap "SIGWINCH" do
      request_xterm_size
    end
  end

  def disable_resize_events
    Signal.trap "SIGWINCH", "DEFAULT"
  end

  def reset_all
    disable_focus_events
    disable_mouse
    disable_resize_events
    reset_color
    show_cursor
    echo_on
  end
end
end
