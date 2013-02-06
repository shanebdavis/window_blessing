module Foiled
module Widget
class Slider < Foiled::Window
  attr_reader :background

  def initialize(rect, options={})
    rect.size.y = 1
    super rect
    @value = options[:value].to_f || 0.0
    self.bg = gray_screen_color(0.25)
  end

  def on_value_change(&block)
    @value_change_callback = block
  end

  def draw_internal
    super
    buffer.draw_rect rect(point(handle_x,0),point(1,1)), :string => "+"
  end

  def handle_x
    (@value * (size.x-Foiled::SMALLEST_FLOAT_DELTA)).to_i
  end

  def value=(v)
    old_value = @value
    @value = bound(0.0,v,1.0)
    @value_change_callback.call(@value, old_value) if @value_change_callback
  end

  def pointer_event(event)
    x = event[:loc].x - loc.x
    self.value = x / (size.x-Foiled::SMALLEST_FLOAT_DELTA)
    request_internal_redraw
  end

end
end
end
