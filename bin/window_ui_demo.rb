#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled::Tools

def colorful_buffer(size)
  Foiled::Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        c = rgb_screen_color y / (size.y-1).to_f, x / (size.x-1).to_f, 0
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => c
      end
    end
  end
end

def gray_buffer(size)
  Foiled::Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        g1 = gray_screen_color(x / (size.x-1).to_f)
        g2 = gray_screen_color(y / (size.y-1).to_f)
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => g1, :fg => g2, :string => "o"
      end
    end
  end
end

Foiled::WindowUI.new.start(:full=>true) do |win|
  r = rect 10, 10, 6, 3

  demo_buffer = gray_buffer(point 23,12)
  demo_buffer = colorful_buffer(point 12,6)
  win.screen_buffer.draw_buffer r.loc, demo_buffer

  r.size = demo_buffer.size
  old_r = r.clone

  win.event_manager.add_handler :tick do |event|
    if r != old_r
      r = rect(win.state.size).bound(r)
      if r != old_r
        win.screen_buffer.draw_rect old_r, :string => " "
        win.screen_buffer.draw_buffer r.loc, demo_buffer
        old_r = r.clone
      end
    end
  end

  win.event_manager.add_handler :key_press do |event|
    Foiled::XtermLog.log "key_press: #{event[:key]}"
    case event[:key]
    when :home      then r.loc.x = 0
    when :page_up   then r.loc.y = 0
    when :page_down then r.loc.y = win.state.size.y
    when :end       then r.loc.x = win.state.size.x
    when :left      then r.loc.x -= 1
    when :right     then r.loc.x += 1
    when :up        then r.loc.y -= 1
    when :down      then r.loc.y += 1
    end
  end

  win.event_manager.add_handler :mouse do |event|
    Foiled::XtermLog.log "mouse: drag #{event[:loc]}"
    r.loc = event[:loc]
  end
end
