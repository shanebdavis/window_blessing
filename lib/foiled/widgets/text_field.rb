module Foiled
module Widgets
class TextField < Foiled::Window
  attr_accessor_with_redraw :text, :fg, :bg, :cursor_bg, :cursor_pos

  def initialize(rect, text, options={})
    super rect
    @text = text
    @fg = options[:fg] || Color.gray
    @bg = options[:bg] || Color.black
    @cursor_bg = options[:cursor_bg] || (@fg + @bg) / 2
    @cursor_pos = text.length
    request_redraw_internal
  end

  def draw_internal
    @cursor_pos = bound(0, @cursor_pos, text.length)
    buffer.contents = text
    buffer.fill :fg => fg, :bg => bg
    buffer.fill :area => rect(point(cursor_pos,0),point(1,1)), :bg => cursor_bg
  end

end
end
end
