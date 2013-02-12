module Foiled
module Widgets
class TextField < Foiled::Window
  NON_NEGATIVE_INTEGER_VALIDATOR = /^[0-9]*$/
  attr_accessor_with_redraw :cursor_bg, :cursor_pos
  attr_accessor :validator
  attr_accessor :evented_value

  def initialize(rect, evented_value, options={})
    super rect
    @evented_value = evented_value = case evented_value
    when EventedVariable then evented_value
    when String then EventedVariable.new(evented_value)
    else raise ArgumentError.new "invalid text type #{evented_value.inspect}(#{evented_value.class})"
    end

    @validator = options[:validator]

    @fg = options[:fg] || Color.gray
    @bg = options[:bg] || Color.black
    @cursor_bg = options[:cursor_bg] || (@fg + @bg) / 2
    @cursor_pos = text.length
    request_redraw_internal

    on :pointer do |event|
      self.cursor_pos = event[:loc].x
    end

    evented_value.on :refresh do |event|
      request_redraw_internal
    end

    on :string_input do |event|
      p = cursor_pos
      s = event[:string]

      self.text = if p==0
        s + text
      elsif p==text.length
        text + s
      else
        text[0..p] + s + text[p+1..-1]
      end
      self.cursor_pos += s.length
    end

    on :key_press do |event|
      case event[:key]
      when :backspace then
        if cursor_pos > 0
          p = cursor_pos
          before = text
          self.text = if cursor_pos == 1
            text[1..-1]
          elsif cursor_pos == text.length
            self.text = text[0..-2]
          else
            self.text = text[0..p-2] + text[p..-1]
          end
          log " before = #{before.inspect} after = #{text.inspect}"
          self.cursor_pos -= 1
        end

      when :home      then self.cursor_pos = 0
      when :end       then self.cursor_pos = text.length
      when :left      then self.cursor_pos -= 1
      when :right     then self.cursor_pos += 1
      end
    end

    on :focus do
      request_redraw_internal
    end

    on :blur do
      request_redraw_internal
    end
  end

  def text; evented_value.get end
  def text=(t); evented_value.set(t) if !validator || t[validator] end

  def draw_internal
    @cursor_pos = bound(0, @cursor_pos, text.length)
    buffer.contents = text
    buffer.fill :fg => fg, :bg => bg
    buffer.fill :area => rect(point(cursor_pos,0),point(1,1)), :bg => cursor_bg if focused?
  end

end
end
end
