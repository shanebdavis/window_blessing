#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})

Foiled::XtermScreen.new.screen(false) do
  size = screen_size
  size.x -= 5
  ch = "a"
  puts size
=begin
  while ch[0].downcase != "q"
    clear
    256.times do |t|
      cursor point(rand(size.x), rand(size.y))
      set_color t
      print t.to_s
    end
    reset_color

    ss = screen_size
    ss.y -= 2
    cursor ss
    out "hi"
    @last && @last.each_with_index do |l,i|
      cursor point(0,1+i)
      out "key: #{l.inspect} "+(l.split(//).map { |b| "%02x" % b.unpack("C") }.join ' ')
    end


    cursor point(0,0)
    print "hit a key (q to quit)"
    ch = getch
  end
=end
while true #gets[0]!="q"
  process_events
  sleep 0.010
end
end
