#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled::Tools

def colorful_buffer(size)
  Foiled::Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        c1 = rgb_screen_color y / (size.y-1).to_f, x / (size.x-1).to_f, 0
        c2 = rgb_screen_color 0, 1 - y / (size.y-1).to_f, 1 - x / (size.x-1).to_f
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => c1, :fg => c2, :string => "o"
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

def draw_instructions(screen)
  b = Foiled::Buffer.new point(screen.state.size.x,1), contents: " Arrows, Home, End, PgUp, PgDown or drag with Mouse to move. Space to toggle. Q to quit.", bg: gray_screen_color(0.6), fg: rgb_screen_color(0.8,0.8,1.0)

  screen.screen_buffer.draw_buffer point, b
end

Foiled::BufferedScreen.new.start(:full=>true) do |screen|
  r = rect 10, 10, 6, 3

  grayb = gray_buffer(point 23,12)
  colorb = colorful_buffer(point 12,6)

  demo_buffer = colorb
  screen.screen_buffer.draw_buffer r.loc, demo_buffer
  draw_instructions(screen)

  r.size = demo_buffer.size
  old_r = r.clone

  screen.event_manager.add_handler :tick do |event|
    if r != old_r
      r = rect(point(0,1), screen.state.size-point(0,1)).bound(r)
      if r != old_r
        screen.screen_buffer.draw_rect old_r, :string => " ", :bg => 0
        screen.screen_buffer.draw_buffer r.loc, demo_buffer
        old_r = r.clone
      end
    end
  end

  screen.event_manager.add_handler :characters do |event|
    case event[:raw]
    when " " then
      demo_buffer = demo_buffer == grayb ? colorb : grayb
      r.size = demo_buffer.size
    end
  end

  screen.event_manager.add_handler :key_press do |event|
    Foiled::XtermLog.log "key_press: #{event[:key]}"
    case event[:key]
    when :home      then r.loc.x = 0
    when :page_up   then r.loc.y = 0
    when :page_down then r.loc.y = screen.state.size.y
    when :end       then r.loc.x = screen.state.size.x
    when :left      then r.loc.x -= 1
    when :right     then r.loc.x += 1
    when :up        then r.loc.y -= 1
    when :down      then r.loc.y += 1
    end
  end

  screen.event_manager.add_last_handler :resize do |event|
    Foiled::XtermLog.log "#{__FILE__} resize: #{event.inspect}"
    draw_instructions screen
    screen.screen_buffer.draw_buffer r.loc, demo_buffer
  end

  screen.event_manager.add_handler :mouse do |event|
    Foiled::XtermLog.log "mouse: drag #{event[:loc]}"
    r.loc = event[:loc] - demo_buffer.size/2
  end
end
