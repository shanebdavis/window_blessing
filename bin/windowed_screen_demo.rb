#!/usr/bin/env ruby
# encoding: UTF-8
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib window_blessing})
include GuiGeo
include WindowBlessing
include Widgets
include Tools

class DragWindow < Window
  include DraggableBackground
  def initialize(loc,buffer)
    super rect(loc,buffer.size)
    @buffer.draw_buffer point, buffer
    clean

    on :key_press do |event|
      XtermLog.log "key_press: #{event[:key]}"
      r = area.clone
      case event[:key]
      when :home      then r.loc.x = 0
      when :page_up   then r.loc.y = 0
      when :page_down then r.loc.y = parent.size.y
      when :end       then r.loc.x = parent.size.x
      when :left      then r.loc.x -= 1
      when :right     then r.loc.x += 1
      when :up        then r.loc.y -= 1
      when :down      then r.loc.y += 1
      end
      self.area = r
      self.move_onscreen
    end
  end
end

def color_window(r)
  size = r.size
  DragWindow.new r.loc, (Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        c1 = rgb_screen_color y / (size.y-1).to_f, x / (size.x-1).to_f, 0
        c2 = rgb_screen_color 0, 1 - y / (size.y-1).to_f, 1 - x / (size.x-1).to_f
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => c1, :fg => c2, :string => "▒"
      end
    end
  end)
end

def gray_window(r)
  size = r.size
  DragWindow.new r.loc, (Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        g1 = gray_screen_color(x / (size.x-1).to_f)
        g2 = gray_screen_color(y / (size.y-1).to_f)
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => g1, :fg => g2, :string => "o"
      end
    end
  end)
end

WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|

  root_window = screen.root_window

  root_window.add_child gray_win = gray_window(rect(10,10,25,13))
  root_window.add_child color_win = color_window(rect(30,15,24,12))
  root_window.add_child Label.new rect(point,point(1000,1)),
    " Arrows, Home, End, PgUp, PgDown or drag with Mouse to move. Space to toggle. Ctrl-Q to quit.",
    :bg => color(0.25)

end
