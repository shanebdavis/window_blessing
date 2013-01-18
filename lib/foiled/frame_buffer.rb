=begin
NOTE: Unlike bitmap graphics, it is often going to be faster to clone bitmap frames rather than do special logic to extract data from frames in-place. This is due the relatively small amount of data for a console-window "frame" (cols * lines ~= a few kilobytes) and Ruby having optimized routines to handle strings as single units.

For example, it's actually going to be faster to draw a sub-region from one frame onto another by first copying out the subframe from the source frame and then copying it into the target frame.

NOTE: I'm just making intelligent guesses here. Haven't actually profiled. It keeps the code simpler, too.

=end
module Foiled
class FrameBuffer
  include Tools

  attr_accessor :size
  attr_accessor :contents
  attr_accessor :crop_area

  def initialize(size, init=nil)
    @contents = case init
    when String then init.gsub("\t"," "*tab_size).split("\n")
    when Array then init
    when nil then []
    else raise ArgumentError.new "invalid initailizer: #{init.inspect}"
    end
    @size = point
    self.size = size
  end

  def crop(area)
    old_crop_area = @crop_area
    @crop_area = area | (old_crop_area || area)
    yield
    self
  ensure
    @crop_area = old_crop_area
  end

  def cropped?
    crop_area != rect(size)
  end

  def inspect
    "<FrameBuffer size:#{size.inspect}>"
  end

  def to_s
    contents.join "\n"
  end

  def tab_size
    2
  end

  def resize_y(y)
    raise ArgumentError.new("y must be >= 1") unless y >= 1
    @size.y = y
    @contents = contents[0..y-1]
    @contents += (y - contents.length).times.collect {""}
  end

  def resize_x(x)
    raise ArgumentError.new("x must be >= 1") unless x >= 1
    @size.x = x
    contents.collect! do |line|
      line = line[0..x-1]
      line += " " * (x - line.length)
    end
  end

  def size=(new_size)
    @crop_area = rect new_size
    resize_y new_size.y
    resize_x new_size.x
  end

  def internal_area
    rect(size)
  end

  def subframe(area)
    area = internal_area | area
    return frame unless area.present?

    x_range = area.x_range

    frame area.size, (contents[area.y_range].collect do |line|
      line[x_range]
    end)
  end

  #########
  # DRAWING
  #########

  def clear
    fill ' '
  end

  def fill(str)
    if cropped?
      draw_rect(crop_area,str)
    else
      line = fill_line(str, size.x)
      @contents = size.y.times.collect {line.clone}
      self
    end
  end

  def draw_frame(loc, frame_buffer)
    source_area = frame_buffer.internal_area | (crop_area - loc)
    return unless source_area.present?

    unless source_area == frame_buffer.internal_area
      loc += source_area.loc
      frame_buffer = frame_buffer.subframe(source_area)
    end

    @contents = overlay_span(loc.y, frame_buffer.contents, contents) do |s, t|
      overlay_span loc.x, s, t
    end
    self
  end

  def draw_rect(rectangle, fill_string)
    rectangle = rectangle | crop_area if crop_area
    draw_frame rectangle.loc, frame(rectangle.size).fill(fill_string)
  end

end
end
