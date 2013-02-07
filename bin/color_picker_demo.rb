#!/usr/bin/env ruby
# encoding: UTF-8
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled::Tools
include Foiled
include Widgets

class FadeSlider < Slider
  def initialize(area, c1, c2)
    super area
    @c1 = c1
    @c2 = c2
  end

  def draw_background
    size = buffer.size
    size.x.times do |x|
      c1[0]
    end
  end
end

class ColorPicker2D < Window
  attr_accessor :color, :fixed_channel
  def initialize(area,color,fixed_channel = :g)
    super area
    @color = color
    @fixed_channel = fixed_channel
    request_internal_redraw
  end

  def variable_channels
    [:r, :g, :b].select {|a| a!=fixed_channel}
  end

  def fixed_channel=(chan)
    old_chan = @fixed_channel
    @fixed_channel = chan
    request_internal_redraw if old_chan != @fixed_channel
  end

  def color=(color)
    old_color = @color
    @color = color
    request_internal_redraw if old_color != @color
  end

  def draw_background
    chan1, chan2 = variable_channels
    s = size
    c = color.clone
    c[chan1] = 0
    c[chan2] = 0
    buffer.bg_buffer = s.y.times.collect do |y|
      c[chan1] = c1 = y / (s.y-1.0)
      s.x.times.collect do |x|
        c[chan2] = c2 =x / (s.x-1.0)
        c.to_p
      end
    end

    l = point color[chan2]*(size.x-1), color[chan1]*(size.y-1)
    buffer.fill :string => " "
    buffer.fill rect(l.x.to_i,l.y.to_i,1,1), :string => "+"
  end

  def on_change(&block)
    @change_callback = block
  end

  def pointer_event_on_background(event)
    loc = event[:loc]
    chan1, chan2 = variable_channels
    p = loc / (size - point(1.0,1.0))
    p = rect(0,0,1,1).bound(p)
    color[chan2] = p.x
    color[chan1] = p.y
    request_internal_redraw
    @change_callback.call(color) if @change_callback
  end
end

class ColorPicker < Window
  include DraggableBackground
  attr_accessor :red_slider, :green_slider, :blue_slider, :gray_slider, :color_preview
  def initialize *args
    super rect(2,2,60,30)
    self.bg = gray_screen_color 0.2
    self.fg = gray_screen_color 0.5

    @color = color

    add_child Label.new(rect(2,0,100,1),"Color Picker - Q to quit", :bg => self.bg, :fg => self.fg)

    @red_slider = add_child Slider.new(rect 2,area.size.y - 10,area.size.x - 20,1)
    @green_slider = add_child Slider.new(rect 2,area.size.y - 8,area.size.x - 20,1)
    @blue_slider = add_child Slider.new(rect 2,area.size.y - 6,area.size.x - 20,1)
    @gray_slider = add_child Slider.new(rect 2,area.size.y - 4,area.size.x - 20,1)
    @color_preview = add_child Window.new(rect(2,2,area.size.x - 20, area.size.y - 14))
    @color2d = add_child ColorPicker2D.new(rect(area.size.x-15,area.size.y-9,12,6),color)

    @color_info_label = add_child Label.new(rect(2,area.size.y - 2,100,1),"info", :bg => self.bg, :fg => rgb_screen_color(1,1,1))

    @color_preview.buffer.fill :string => "Mr. Hungerton, her father, really was the most tactless person upon earth, -- a fluffy, feathery, untidy cockatoo of a man, perfectly good-natured, but absolutely centered upon his own silly self.  If anything could have driven me from Gladys, it would have been the thought of such a father-in-law.  I am convinced that he really believed in his heart that I came round to the Chestnuts three days a week for the pleasure of his company, and very especially to hear his views upon bimetallism, a subject upon which he was by way of being an authority. "

    red_slider.bg = rgb_screen_color(1,0,0)
    red_slider.fg = rgb_screen_color(0,0,0)
    green_slider.bg = rgb_screen_color(0,1,0)
    green_slider.fg = rgb_screen_color(0,0,0)
    blue_slider.bg = rgb_screen_color(0,0,1)
    blue_slider.fg = rgb_screen_color(1,1,1)
    gray_slider.bg = gray_screen_color(0.5)
    gray_slider.fg = rgb_screen_color(1,1,1)

    red_slider.on_change    {|v| @color2d.fixed_channel = :r;update_preview }
    green_slider.on_change  {|v| @color2d.fixed_channel = :g;update_preview }
    blue_slider.on_change   {|v| @color2d.fixed_channel = :b;update_preview }
    gray_slider.on_change   {|v| set_gray v }
    @color2d.on_change      {|v| set_color v }
    update_preview
  end

  def set_color(c)
    red_slider.value=c.r
    blue_slider.value=c.b
    green_slider.value=c.g
    update_preview
  end

  def set_gray(value)
    red_slider.value=blue_slider.value=green_slider.value=value
    update_preview
  end

  def update_preview
    @color_info_label.text = "Color: ##{@color.to_hex} / (#{"%.2f, %.2f, %.2f"%@color.to_a}) / (#{@color.to_a256.join(', ')})"
    @color = color(red_slider.value, green_slider.value, blue_slider.value)
    @color_preview.buffer.fill :bg => rgb_screen_color(*@color.to_a)
    @color_preview.request_redraw
    @color2d.color = @color
  end
end

WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|
  screen.root_window.add_child ColorPicker.new
  screen.root_window.add_child(ColorPicker.new).loc = point
end