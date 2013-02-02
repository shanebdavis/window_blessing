# ref: http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
# ref: http://www.vt100.net/docs/vt102-ug/chapter5.html

module Foiled
class XtermOutput
  include Color

  # cursor 0, 0 is the upper left hand corner
  # cursor point(0, 0) is also accepted
  def cursor(loc_or_x, y=nil)
    loc = y ? point(loc_or_x,y) : loc_or_x
    out "\e[#{loc.y+1};#{loc.x+1}H"
  end

  # raw screen output
  def out(str)
    $stdout.print s = str.to_s
    s
  end

  def out_at(loc, str)
    cursor(loc)
    out str
  end

  def show_cursor; out "\e[?25h"; end
  def hide_cursor; out "\e[?25l"; end

  # convert all \n to \n\r
  def puts(s=nil)
    out "#{s}\n".gsub("\n", "\n\r")
  end

  def clear; out "\e[2J"; end

  def enable_mouse; out "\e[?1003h"; end
  def disable_mouse; out "\e[?1003l"; end
  def enable_focus_events; out "\e[?1004h" end
  def disable_focus_events; out "\e[?1004l" end

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

  def clean_screen(with_mouse=false)
    echo_off
    clear
    enable_mouse if with_mouse
    enable_focus_events
    enable_resize_events

    yield self
  ensure
    reset_all
    puts "#{self.class}::clean_screen: Done."
#    clear
#    cursor point(0,0)
  end

  # execute passed in block with the cursor hidden, then re-show it
  def without_cursor
    hide_cursor
    yield self
  ensure
    show_cursor
  end

  # TODO: find out what stty raw -echo sends to xterm
  # INTERNAL NOTE: out "\e[12h" # should turn off echo according to doc, but didn't work
  # http://stackoverflow.com/questions/174933/how-to-get-a-single-character-without-pressing-enter
  def echo_off; system "stty raw -echo"; end

  # INTERNAL NOTE: out "\e[12l" # should turn echo back on
  def echo_on; system "stty -raw echo"; end

  # This seems to work - or at least it does SOMETHING
  def insert_mode; out "\e[4m"; end
  def replace_mode; out "\e[4l"; end

end
end
