module Foiled
module Widgets
class Label < Foiled::Window
  attr_accessor :text, :fill_options

  def initialize(rect, text, fill_options={})
    super rect
    @text = text
    @fill_options = fill_options
    request_internal_redraw
  end

  def draw_internal
    self.contents = text
    buffer.fill fill_options
  end

  def text=(text)
    @text = text
    request_internal_redraw
  end

  def fg=(fg)
    fill_options[:fg] = fg
    request_internal_redraw
  end

  def bg=(bg)
    fill_options[:bg] = bg
    request_internal_redraw
  end

end
end
end
