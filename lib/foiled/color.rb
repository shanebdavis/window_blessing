module Foiled
module Color
  def rgb_to_screen_color(red, green, blue)
    16 + (red * 36) + (green * 6) + blue
  end

  # g is 0..1
  def gray_screen_color(g)
    232 + (bound(0.0,g,1.0)*23).to_i
  end

  def set_color(fg, bg=nil)
    print "\x1b[38;5;#{bound(0,fg.to_i,255)}m" if fg
    print "\x1b[48;5;#{bound(0,bg.to_i,255)}m" if bg
  end

  def reset_color
    print "\x1b[0m"
  end

  def print_color(txt, fg, bg)
    set_color(fg, bg)
    print txt
    reset_color
  end
end
end
