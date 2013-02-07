module Foiled
module Widgets
class Label < Foiled::Window
  attr_accessor_with_redraw :text, :fg, :bg

  def initialize(rect, text, fill_options={})
    super rect
    @text = text
    @fg = fill_options[:fg]
    @bg = fill_options[:bg]
    request_redraw_internal
  end

  def pointer_inside?(loc) false; end

  def draw_internal
    buffer.contents = text
    buffer.fill :fg => fg, :bg => bg
  end

end
end
end
