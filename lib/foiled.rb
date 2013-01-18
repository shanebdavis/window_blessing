=begin
Copyright 2013 Shane Brinkman-Davis
See README for licence information.
=end

%w{
  tools
  frame_buffer
  point
  rectangle
  version
  screen
  window
}.each do |file|
  require File.join(File.dirname(__FILE__),"foiled",file)
end

module Foiled
  # Your code goes here...
class << self
  include Tools
  def test_screen
    Screen.new.open do
      loc = point 10, 10
      fb = FrameBuffer.new(Point.new(10,5)).fill("!")
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
  end
end
end

