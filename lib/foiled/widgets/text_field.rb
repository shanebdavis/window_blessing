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

    on :pointer do |event|
      focus
      self.cursor_pos = event[:loc].x
    end

    on :focus do
      request_redraw_internal
    end

    on :blur do
      request_redraw_internal
    end
  end

  def draw_internal
    @cursor_pos = bound(0, @cursor_pos, text.length)
    buffer.contents = text
    buffer.fill :fg => fg, :bg => bg
    buffer.fill :area => rect(point(cursor_pos,0),point(1,1)), :bg => cursor_bg if focused?
  end

end
end
end
