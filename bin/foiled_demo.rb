#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})

Foiled.main do |main_window|
  loc = point 10, 10
  fb = Buffer.new(Point.new(10,5)).fill("!")
  draw loc, fb
  on_key do |key|
    case key
    when ?Q, ?q             then  break
    when Curses::Key::UP    then loc.y-=1
    when Curses::Key::DOWN  then loc.y+=1
    when Curses::Key::LEFT  then loc.x-=1
    when Curses::Key::RIGHT then loc.x+=1
    end
    draw loc, fb
  end

  on_tick do
    time = Time.now
    if time.sec != @last_sec
      write point(0,0), time.to_s
      @last_sec = time.sec
    end
  end
end
