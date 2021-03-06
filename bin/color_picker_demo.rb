#!/usr/bin/env ruby
# encoding: UTF-8
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib window_blessing})
include GuiGeo
include WindowBlessing::Tools
include WindowBlessing
include Widgets

class FadeSlider < Slider
  attr_accessor_with_redraw :c1, :c2
  def initialize(area, ev, c1, c2)
    super area, ev, key_press_step: 1/20.0
    @c1 = c1
    @c2 = c2
  end

  def draw_background
    size = buffer.size
    step = (c2 - c1) / (size.x-1).to_f
    line = size.x.times.collect do |x|
      (c1 + step * x).to_screen_color
    end
    buffer.bg_buffer = size.y.times.collect {line.clone}
    buffer.fill :string => " ", :fg => value > 0.5 ? Color.black : Color.white
    draw_handle
  end
end

class ColorPicker2D < Window
  include Evented
  attr_accessor_with_redraw :fixed_channel
  attr_reader :color_ev

  def initialize(area,color_ev,fixed_channel = :g)
    super area
    @color_ev = color_ev
    @fixed_channel = fixed_channel
    request_redraw_internal

    on :pointer do |event|
      loc = event[:loc]
      color = color_ev.get
      old_color = color.clone

      chan1, chan2 = variable_channels
      p = loc / (size - point(1.0,1.0))
      color[chan2] = bound(0.0, p.x, 1.0)
      color[chan1] = bound(0.0, p.y, 1.0)

      color_ev.set color
    end

    color_ev.on :refresh do
      request_redraw_internal
    end
  end

  def variable_channels
    [:r, :g, :b].select {|a| a!=fixed_channel}
  end

  def draw_background
    chan1, chan2 = variable_channels
    color = color_ev.get
    s = size
    c = color.clone
    c[chan1] = 0
    c[chan2] = 0
    buffer.bg_buffer = s.y.times.collect do |y|
      c[chan1] = c1 = y / (s.y-1.0)
      s.x.times.collect do |x|
        c[chan2] = c2 =x / (s.x-1.0)
        c.to_screen_color
      end
    end

    l = point color[chan2]*(size.x-1), color[chan1]*(size.y-1)
    buffer.fill :string => " "
    buffer.fill :area => rect(l.x.to_i,l.y.to_i,1,1), :string => "+"
  end
end

class ColorPreview < Window
  def initialize(area, color_ev)
    super area
    @color_ev = color_ev

    color_ev.on :refresh do
      request_redraw_internal
    end
  end

  def draw_background
    buffer.fill :string => "Mr. Hungerton, her father, really was the most tactless person upon earth, -- a fluffy, feathery, untidy cockatoo of a man, perfectly good-natured, but absolutely centered upon his own silly self.  If anything could have driven me from Gladys, it would have been the thought of such a father-in-law.  I am convinced that he really believed in his heart that I came round to the Chestnuts three days a week for the pleasure of his company, and very especially to hear his views upon bimetallism, a subject upon which he was by way of being an authority. ",
      :bg => @color_ev.get
  end
end

class ColorPicker < Window
  include DraggableBackground
  attr_accessor :gray_slider, :color_preview, :color2d
  attr_accessor :color_ev, :r_ev, :g_ev, :b_ev, :gray_ev

  def create_evented_variables(initial_color)
    @color_ev  = EventedVariable.new(initial_color)
    @r_ev      = EventedVariable.new(initial_color.r).on(:change)  {|event| color = color_ev.get; color.r = event[:value]; color_ev.set color}
    @g_ev      = EventedVariable.new(initial_color.g).on(:change)  {|event| color = color_ev.get; color.g = event[:value]; color_ev.set color}
    @b_ev      = EventedVariable.new(initial_color.b).on(:change)  {|event| color = color_ev.get; color.b = event[:value]; color_ev.set color}
    @gray_ev   = EventedVariable.new(initial_color.br).on(:change) {|event| color_ev.set color(event[:value]) }

    color_ev.on(:change) do |event|
      color = event[:value]
      r_ev.refresh color.r
      g_ev.refresh color.g
      b_ev.refresh color.b
      gray_ev.refresh color.br

      update_label
      @r_value_field.text = color.r256.to_s if @r_value_field.text != color.r256.to_s
      @g_value_field.text = color.g256.to_s if @g_value_field.text != color.g256.to_s
      @b_value_field.text = color.b256.to_s if @b_value_field.text != color.b256.to_s
    end
  end

  def current_color
    @color_ev.get
  end

  def initialize *args
    super rect(2,2,60,18)
    self.bg = gray_screen_color 0.2
    self.fg = gray_screen_color 0.5

    create_evented_variables(Color.white)

    add_child Label.new(rect(2,0,100,1),"Color Picker - Ctrl-Q to quit", :bg => self.bg, :fg => self.fg)

    @r_slider     = add_child FadeSlider.new(rect(area.size.x-15,9,12,1), r_ev,    Color.black, Color.red  )
    @g_slider     = add_child FadeSlider.new(rect(area.size.x-15,10,12,1),  g_ev,    Color.black, Color.green)
    @b_slider     = add_child FadeSlider.new(rect(area.size.x-15,11,12,1),  b_ev,    Color.black, Color.blue )
    @gray_slider  = add_child FadeSlider.new(rect(area.size.x-15,12,12,1),  gray_ev, Color.black, Color.white)

    text_field_options = {:bg => color(0.1), :fg => Color.gray, :validator => /^[0-9]{0,3}$/}
    @r_value_field = add_child TextField.new(rect(area.size.x - 15,14,4,1), "123", text_field_options)
    @g_value_field = add_child TextField.new(rect(area.size.x - 15+4,14,4,1), "123", text_field_options)
    @b_value_field = add_child TextField.new(rect(area.size.x - 15+8,14,4,1), "123", text_field_options)


    @r_value_field.fg = Color.red
    @g_value_field.fg = Color.green
    @b_value_field.fg = Color.blue

    @color2d          = add_child ColorPicker2D.new(rect(area.size.x-15,2,12,6), color_ev)

    @color_preview    = add_child ColorPreview.new(rect(2,2,area.size.x - 20, 13), color_ev)

    @color_info_label = add_child Label.new(rect(2,area.size.y - 2,100,1),"info", :bg => self.bg, :fg => rgb_screen_color(1,1,1))

    @r_slider.on(:pointer, :button1_down) {@color2d.fixed_channel = :r}
    @g_slider.on(:pointer, :button1_down) {@color2d.fixed_channel = :g}
    @b_slider.on(:pointer, :button1_down) {@color2d.fixed_channel = :b}

    @r_value_field.evented_value.on(:change) {|event|r_ev.set bound(0.0,event[:value].to_i/255.0,1.0)}
    @g_value_field.evented_value.on(:change) {|event|g_ev.set bound(0.0,event[:value].to_i/255.0,1.0)}
    @b_value_field.evented_value.on(:change) {|event|b_ev.set bound(0.0,event[:value].to_i/255.0,1.0)}

    @color_info_label.name = "info_label"

    color_ev.set Color.black

    update_label
  end

  def update_label
    @color_info_label.text = "Color: #{current_color.to_hex} / (#{"%.2f, %.2f, %.2f"%current_color.to_a}) / (#{current_color.to_a256.join(', ')})"
  end
end

WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|
  screen.root_window.add_child ColorPicker.new
  screen.root_window.add_child(ColorPicker.new).loc = point
end
