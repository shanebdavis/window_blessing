module Foiled
class XtermScreen
  include GuiGeo
  include GuiGeo::Tools
  include Color

  attr_accessor :screen_size

  def initialize
    @screen_size = point(10,10)
    @input = XtermInput.new
  end

  # ref: http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
  # ref: http://www.vt100.net/docs/vt102-ug/chapter5.html
  def out(str)
    $stdout.print str
  end

  def response
    $stdin.readpartial 1000
  end


  # cursor 0, 0 is the upper left hand corner
  # cursor point(0, 0) is also accepted
  def cursor(loc_or_x, y=nil)
    loc = y ? point(loc_or_x,y) : loc_or_x
    out "\e[#{loc.y+1};#{loc.x+1}H"
  end

  def clear
    out "\e[2J"
  end

  def enable_mouse
    out "\e[?1003h"
  end

  def disable_mouse
    out "\e[?1003l"
  end

  def puts(s)
    $stdout.puts "#{s}\r"
  end

  def parsed_response
    key_parser.parse response
    {:raw => r, :values => $1.split(";"), :command => $3}
  end

  def request_screen_size
    out "\e[18t"
#    r = parsed_response
#    point r[:values][2].to_i, r[:values][1].to_i
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
    system "stty raw -echo"
    #out "\e[12h"
  end

  def echo_on
    #out "\e[12l"
    system "stty -raw echo"
  end

  def insert_mode
    out "\e[4m"
  end

  def replace_mode
    out "\e[4l"
  end

  def update_status
    request_screen_size
    process_events
  end

  def process_events
    @event_log ||= []
    @input.each_event do |event|
      case event[:type]
      when :characters then event[:raw][/q/i] && exit
      when :mouse then
      when :screen_size then @screen_size = event[:size]
      when :unknown_command then
      else

      end
    end
    @input.reset_events
  end

  # run xterm raw-session
  def screen(with_mouse=false,&block)
    update_status
    echo_off
    clear
    enable_mouse if with_mouse
    instance_eval &block

  ensure
    disable_mouse if with_mouse
    reset_color
    echo_on
    clear
    cursor point(0,0)
  end

  def on_key(&block)
    @on_key_blocks << block
  end

  def on_tick(&block)
    @on_tick_blocks << block
  end

end
end
