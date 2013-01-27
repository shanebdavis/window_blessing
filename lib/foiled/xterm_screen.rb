module Foiled
class XtermScreen
  include GuiGeo
  # ref: http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
  # ref: http://www.vt100.net/docs/vt102-ug/chapter5.html
  def out(str)
    $stdout.print str
  end

  def response
    $stdin.readpartial 1000
#    $stdin.read_nonblock(1000)
  end

  def cursor(loc)
    out "\e[#{loc.y};#{loc.x}H"
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


  def parsed_response
    r = response[/\e\[(\d+(;\d+)*)([a-zA-Z])/]
    {:raw => r, :values => $1.split(";"), :command => $3}
  end


  def screen_size
    out "\e[18t"
    r = parsed_response
    point r[:values][2].to_i, r[:values][1].to_i
  end

  def display_pixel_size
    out "\e[14t"
    r = parsed_response
    point r[:values][2], r[:values][1]
  end

  # echo - doesn't seem to work (?)
  # http://stackoverflow.com/questions/174933/how-to-get-a-single-character-without-pressing-enter
  #
  def echo_off
    # ESC  [   1   2   l
    system "stty raw -echo"
    #out "\e[12h"
  end

  def echo_on
    #out "\e[12l"
    system "stty -raw echo"
  end

  # color
  def fg_256(c)
    out "\e[38;5;%dm"%c
  end

  def fg_rgb(r,g,b)
    out "\e[38;2;%d;%d;%dm"%[r,g,b]
  end

  def bg_256(c)
    out "\e[48;5;%dm"%c
  end

  def bg_rgb(r,g,b)
    out "\e[48;2;%d;%d;%dm"%[r,g,b]
  end

  # run xterm raw-session
  def screen(&block)
    echo_off
    clear
    instance_eval &block
  ensure
    fg_256 7
    echo_on
    clear
    cursor point(0,0)
  end

  def getch
    $stdin.readpartial 1000
  end

end
end
