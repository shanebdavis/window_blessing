#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo

Foiled::WindowUI.new.start(true) do |win|
  include Foiled::Color
  r = rect 10, 10, 6, 3

  s = point 12,6
  colorful = Foiled::Buffer.new s
  s.y.times do |y|
    s.x.times do |x|
      c = rgb_to_screen_color y / (s.y-1).to_f, x / (s.x-1).to_f, 0
      colorful.draw_rect rect(point(x,y),point(1,1)), :bg => c
    end
  end
  win.screen_buffer.draw_buffer r.loc, colorful

  r.size = colorful.size
  old_r = r.clone

  win.event_manager.add_handler :tick do |event|
    if r != old_r
      r = rect(win.state.size).bound(r)
      if r != old_r
        win.screen_buffer.draw_rect old_r, :string => " "
        win.screen_buffer.draw_buffer r.loc, colorful
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
