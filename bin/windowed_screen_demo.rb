#!/usr/bin/env ruby
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled::Tools

class DragWindow < Foiled::Window
  def initialize(rect)
    super rect
  end

  def mouse_event(event)
    case event[:button]
    when :button1_down then
      @mouse_offset = event[:loc] - loc
    when :drag then
      self.loc = event[:loc] - @mouse_offset
    end
  end
end

class InstructionsWindow < Foiled::Window
  def initialize
    super rect(point,point(1000,1))
    @buffer = Foiled::Buffer.new size, contents: " Arrows, Home, End, PgUp, PgDown or drag with Mouse to move. Space to toggle. Q to quit.", bg: gray_screen_color(0.6), fg: rgb_screen_color(0.8,0.8,1.0)
  end

  def draw(target_buffer=nil, internal_area=nil)
    super
  end
end


def color_window(r)
  size = r.size
  b = Foiled::Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        c1 = rgb_screen_color y / (size.y-1).to_f, x / (size.x-1).to_f, 0
        c2 = rgb_screen_color 0, 1 - y / (size.y-1).to_f, 1 - x / (size.x-1).to_f
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => c1, :fg => c2, :string => "o"
      end
    end
  end
  w = DragWindow.new r
  w.buffer.draw_buffer point, b
  w
end

def gray_window(r)
  size = r.size
  b = Foiled::Buffer.new(size).tap do |buffer|
    size.y.times do |y|
      size.x.times do |x|
        g1 = gray_screen_color(x / (size.x-1).to_f)
        g2 = gray_screen_color(y / (size.y-1).to_f)
        buffer.draw_rect rect(point(x,y),point(1,1)), :bg => g1, :fg => g2, :string => "o"
      end
    end
  end
  w = DragWindow.new r
  w.buffer.draw_buffer point, b
  w
end

def draw_instructions(screen)
  b = Foiled::Buffer.new point(screen.state.size.x,1), contents: " Arrows, Home, End, PgUp, PgDown or drag with Mouse to move. Space to toggle. Q to quit.", bg: gray_screen_color(0.6), fg: rgb_screen_color(0.8,0.8,1.0)

  screen.screen_buffer.draw_buffer point, b
end

Foiled::WindowedScreen.new.start(:full=>true) do |screen|
  r = rect 10, 10, 6, 3

  root_window = screen.root_window

  gray_win = gray_window(rect(10,10,23,12))
  color_win = color_window(rect(30,15,12,6))

  #gray_win.bg = rgb_screen_color(0.5,0.5,0.5)
  #color_win.bg = rgb_screen_color(0.0,0.0,1.0)

  root_window.add_child gray_win
  root_window.add_child color_win
  root_window.add_child InstructionsWindow.new

  screen.event_manager.add_handler :key_press do |event|
    Foiled::XtermLog.log "key_press: #{event[:key]}"
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
