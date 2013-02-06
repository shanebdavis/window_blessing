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

class ColorPicker < Window
  include DraggableBackground
  attr_accessor :red_slider, :green_slider, :blue_slider, :gray_slider, :color_preview
  def initialize *args
    super rect(2,2,60,30)
    self.bg = gray_screen_color 0.2
    self.fg = gray_screen_color 0.5

    @color = color

    add_child Label.new(rect(2,0,100,1),"Color Picker - Q to quit", :bg => self.bg, :fg => self.fg)

    @red_slider = add_child Slider.new(rect 10,area.size.y - 10,area.size.x - 20,1)
    @blue_slider = add_child Slider.new(rect 10,area.size.y - 8,area.size.x - 20,1)
    @green_slider = add_child Slider.new(rect 10,area.size.y - 6,area.size.x - 20,1)
    @gray_slider = add_child Slider.new(rect 10,area.size.y - 4,area.size.x - 20,1)
    @color_preview = add_child Window.new(rect(10,2,area.size.x - 20, area.size.y - 14))

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

    red_slider.on_change    {|v| update_preview }
    green_slider.on_change  {|v| update_preview }
    blue_slider.on_change   {|v| update_preview }
    gray_slider.on_change   {|v| set_gray v }
    update_preview
  end

  def set_gray(value)
    red_slider.value=blue_slider.value=green_slider.value=value
    update_preview
  end

  def update_preview
    @color_info_label.text = "Color: ##{@color.to_hex} / (#{"%.2f, %.2f, %.2f"%@color.to_a}) / (#{@color.to_a256.join(', ')})"
    @color = color(red_slider.value, blue_slider.value, green_slider.value)
    @color_preview.buffer.fill :bg => rgb_screen_color(*@color.to_a)
    @color_preview.request_redraw
  end
end

WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|
  screen.root_window.add_child ColorPicker.new
end
