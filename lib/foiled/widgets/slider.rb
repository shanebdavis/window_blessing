module Foiled
module Widgets
class Slider < Foiled::Window
  attr_reader :background, :value

  def initialize(rect, options={})
    rect.size.y = 1
    super rect
    @value = options[:value].to_f || 0.0
    self.bg = gray_screen_color(0.25)
  end

  def on_change(&block)
    @change_callback = block
  end

  def draw_internal
    super
    buffer.cropped(rect(point(handle_x,0),point(1,1))) {buffer.fill :string => "+"}
  end

  def handle_x
    (@value * screen_value_range).to_i
  end

  def screen_value_range
    size.x - 1.0
  end

  def value=(v)
    old_value = @value
    @value = bound(0.0,v,1.0)
    request_redraw_internal
  end

  # triggers callbacks
  def set_value(v)
    old_value = v
    self.value = v
    @change_callback.call(@value, old_value) if @change_callback
  end

  def pointer_event_on_background(event)
    x = event[:loc].x
    set_value x / screen_value_range
    request_redraw_internal
  end

end
end
end
