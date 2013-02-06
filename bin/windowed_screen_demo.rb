#!/usr/bin/env ruby
# encoding: UTF-8
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled
include Tools

class DragWindow < Window
  def initialize(rect)
    super rect
  end

  def pointer_event(event)
    case event[:button]
    when :button1_down then
      @mouse_offset = event[:loc] - loc
    when :drag then
      self.loc = event[:loc] - @mouse_offset
    end
  end
end

class InstructionsWindow < Window
  def initialize
    super rect(point,point(1000,1))
    self.bg = gray_screen_color(0.2)
    self.fg = rgb_screen_color(0.8,0.8,1.0)
    self.contents = " Arrows, Home, End, PgUp, PgDown or drag with Mouse to move. Space to toggle. Q to quit."
  end
end


def color_window(r)
  size = r.size
  b = Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        c1 = rgb_screen_color y / (size.y-1).to_f, x / (size.x-1).to_f, 0
        c2 = rgb_screen_color 0, 1 - y / (size.y-1).to_f, 1 - x / (size.x-1).to_f
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => c1, :fg => c2, :string => "o"
      end
    end
  end
  b.fill :string => "▒"
  w = DragWindow.new r
  w.buffer.draw_buffer point, b
  w
end

def gray_window(r)
  size = r.size
  b = Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        g1 = gray_screen_color(x / (size.x-1).to_f)
        g2 = gray_screen_color(y / (size.y-1).to_f)
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => g1, :fg => g2, :string => "o"
      end
    end
  end
  #b.fill :string => "*"
  #"⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ "
  #http://www.csbruce.com/software/utf-8.html
  #"╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ "
  #"═ ║ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟ ╠ ╡ ╢ ╣ ╤ ╥ ╦ ╧ ╨ ╩ ╪ ╫ ╬"
  #"◠ ◡ ◦ ◧ ◨ ◩ ◪ ◫ ◬ ◭ ◮ "
  #"◰ ◱ ◲ ◳ ◴ ◵ ◶ ◷ ◸ ◹ ◺ ◿ "
  #"╬"
  # "▀▁▂▃▄▅▆▇█"
  # "▉▊▋▌▍▎▏▐"
  # "░▒▓"
  # "▔▕▖▗▘▙▚▛▜▝▞▟"
  # "▸▾"
  w = DragWindow.new r
  w.buffer.draw_buffer point, b
  w
end

WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|

  root_window = screen.root_window

  root_window.add_child gray_win = gray_window(rect(10,10,23,12))
  root_window.add_child color_win = color_window(rect(30,15,24,12))
  root_window.add_child InstructionsWindow.new


  screen.event_manager.add_handler :key_press do |event|
    XtermLog.log "key_press: #{event[:key]}"
    r = color_win.area.clone
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
    color_win.area = r
    color_win.move_onscreen
  end
end
