#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})


Foiled.main do |main_window|
#  raise main_window.inspect
  (c1 = window(rect(10,10,15,7))).background='-='
  main_window.add_child c1

  on_key do |key|
    case key
    when ?Q, ?q             then  break
    when Curses::Key::UP    then c1.area += point(0,-1)
    when Curses::Key::DOWN  then c1.area += point(0,1)
    when Curses::Key::LEFT  then c1.area += point(-1,0)
    when Curses::Key::RIGHT then c1.area += point(1,0)
    end
  end

  on_tick do
    time = Time.now
    if time.sec != @last_sec
      write point(0,0), time.to_s
      @last_sec = time.sec
    end
  end
end
