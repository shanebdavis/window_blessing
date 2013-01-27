#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})

Foiled::XtermScreen.new.screen do
  size = screen_size
  size.x -= 5
  ch = "a"
  while ch[0].downcase != "q"
    clear
    256.times do |t|
      cursor point(rand(size.x), rand(size.y))
      fg_256 t
      print t.to_s
    end
    fg_256 7
    cursor point(0,0)
    print "hit a key (q to quit)"
    ch = getch
  end
end
