require "gui_geometry"

module WindowBlessing
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

  def clone_value(v)
    case v
    when Fixnum, Bignum, Float then v
    else v.clone
    end
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

  def resize2d(array2d, size, blank_element)
    array2d ||= []
    blank_element = [blank_element] unless blank_element.kind_of?(String)

    if array2d.length != size.y
      array2d = array2d[0..(size.y-1)]
      blank_line = blank_element * size.x
      array2d += (size.y - array2d.length).times.collect {blank_line.clone}
    end

    array2d.collect do |line|
      if line.length!=size.x
        line = line[0..(size.x-1)]
        line + blank_element * (size.x - line.length)
      else
        line
      end
    end
  end


  def subarray2d(array2d, area)
    size = point(array2d[0].length,array2d.length)
    area = area | rect(size)
    x_range = area.x_range
    array2d[area.y_range].collect do |line|
      line[x_range]
    end
  end

  def fill_line(fill, length)
    line = fill * (length/fill.length)
    line = (line+fill)[0..length-1] if line.length != length
    line
  end

  def gen_array2d(size, fill)
    fill = case fill
    when String, Array then fill
    else [fill]
    end

    a = (size.x * size.y)
    full = fill * ((a / fill.length) + 1)

    if fill.kind_of?(String)
      full.scan /.{#{size.x}}/
    else
      full.each_slice(size.x).collect {|a|a}
    end[0..size.y-1]

  end


  # r, g, b are in 0..1
  def rgb_screen_color(r, g, b)
    return gray_screen_color(r) if r==g && g==b
    16 + (r*5.9).to_i * 36 + (g*5.9).to_i * 6 + (b*5.9).to_i
  end

  # g is in 0..1
  def gray_screen_color(g)
    g = (g*24.9).to_i
    case g
    when 0 then 0
    when 24 then 15
    else 232 + g
    end
  end

  def log(str); XtermLog.log "#{self.inspect}: #{str}" end
  def color(*args); WindowBlessing::Color.new *args end
  def window(*args); WindowBlessing::Window.new *args end
  def buffer(*args); WindowBlessing::Buffer.new *args end
end
end
