require "gui_geometry"

module Foiled
module Tools
  include GuiGeo::Tools

  # returns pos, span
  # on return, pos is within 0..length and pos + span.length is <= length
  def overlapping_span(pos, span, length)
    if pos <= -span.length || pos >= length || length <= 0
      return length, span.class.new
    elsif pos < 0
      span = span[-pos..-1]
      pos = 0
    end
    return pos, span[0..(length - pos - 1)]
  end

  # if the block is provided, yields the source elements and the target elements they are overlaying, in order, one at a time
  def overlay_span(pos, source_span, target_span, &block)
    pos, span = overlapping_span pos, source_span, target_span.length

    return target_span if span.length == 0

    if block
      span = span.each_with_index.collect {|s,i| yield s, target_span[i+pos]}
    end

    if pos == 0
      span + target_span[span.length..-1]
    else
      target_span[0..pos-1] + span + target_span[pos + span.length..-1]
    end
  end

  def overlay2d(loc, source, target)
    overlay_span(loc.y, source, target) do |s, t|
      overlay_span loc.x, s, t
    end
  end

  def resize2d(buffer, size, blank_element)
    blank_element = [blank_element] unless blank_element.kind_of?(String)

    if buffer.length != size.y
      buffer = buffer[0..(size.y-1)]
      blank_line = blank_element * size.x
      buffer << blank_line.clone while buffer.length < size.y
    end

    buffer.collect do |line|
      if line.length!=size.x
        line = line[0..(size.x-1)]
        line + blank_element * (size.x - line.length)
      else
        line
      end
    end
  end

  def fill_line(fill, length)
    line = fill * (length/fill.length)
    line = (line+fill)[0..length-1] if line.length != length
    line
  end

  def window(*args); Foiled::Window.new *args end
  def buffer(*args); Foiled::Buffer.new *args end
end
end
