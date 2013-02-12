module Foiled
module Widgets
class Slider < Foiled::Window
  include Evented
  attr_reader :background, :evented_value
  attr_accessor :key_press_step

  # options
  #   :key_press_step => 0.1
  def initialize(rect, evented_value, options={})
    rect.size.y = 1
    super rect
    @evented_value = evented_value = case evented_value
    when EventedVariable then evented_value
    when Float then EventedVariable.new(evented_value)
    else raise ArgumentError.new "invalid text type #{evented_value.inspect}(#{evented_value.class})"
    end
    self.bg = gray_screen_color(0.25)
    @key_press_step = options[:key_press_step] || 0.1

    on :pointer do |event|
      x = event[:loc].x
      evented_value.set bound(0.0, x / screen_value_range, 1.0)
    end

    evented_value.on :refresh do |event|
      request_redraw_internal
    end

    on :key_press do |event|
      case event[:key]
      when :home      then self.value = 0
      when :end       then self.value = 1
      when :left      then
        self.value = max(0.0, self.value - @key_press_step) if @key_press_step
      when :right     then
        self.value = min(1.0, self.value + @key_press_step) if @key_press_step
      end
    end
  end

  def draw_internal
    super
    buffer.fill :area => rect(point(handle_x,0),point(1,1)), :string => "+"
  end

  def handle_x;           (value * screen_value_range).to_i end
  def screen_value_range; size.x - 1.0 end
  def value;              evented_value.get end
  def value=(v)           evented_value.set(v) end
end
end
end
