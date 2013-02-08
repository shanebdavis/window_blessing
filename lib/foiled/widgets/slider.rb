module Foiled
module Widgets
class Slider < Foiled::Window
  include Evented
  attr_reader :background, :evented_value

  def initialize(rect, evented_value)
    rect.size.y = 1
    super rect
    @evented_value = evented_value
    self.bg = gray_screen_color(0.25)

    on :pointer do |event|
      x = event[:loc].x
      evented_value.set bound(0.0, x / screen_value_range, 1.0)
    end

    evented_value.on :refresh do |event|
      request_redraw_internal
    end
  end

  def draw_internal
    super
    buffer.fill :area => rect(point(handle_x,0),point(1,1)), :string => "+"
  end

  def handle_x;           (value * screen_value_range).to_i end
  def screen_value_range; size.x - 1.0 end
  def value;              evented_value.get end
end
end
end
