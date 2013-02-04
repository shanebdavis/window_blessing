=begin
NOTE: Unlike bitmap graphics, it is often going to be faster to clone bitmap frames rather than do special logic to extract data from frames in-place. This is due the relatively small amount of data for a console-window "buffer" (cols * lines ~= a few kilobytes) and Ruby having optimized routines to handle strings as single units.

For example, it's actually going to be faster to draw a sub-region from one buffer onto another by first copying out the subbuffer from the source buffer and then copying it into the target buffer.

NOTE: I'm just making intelligent guesses here. Haven't actually profiled. It keeps the code simpler, too.

=end
module Foiled
class Buffer
  include Tools

  attr_accessor :size
  attr_accessor :contents
  attr_accessor :crop_area
  attr_reader :dirty_area

  # color buffers. 2D arrays. Each element is a number, 0-255.
  attr_accessor :fg_buffer, :bg_buffer

  def Buffer.default_bg; 0; end
  def Buffer.default_fg; 7; end

  def initialize(size, init=nil, bg_color = Buffer.default_bg, fg_color = Buffer.default_fg)
    @contents = case init
    when String then init.gsub("\t"," "*tab_size).split("\n")
    when Array then init
    when nil then []
    else raise ArgumentError.new "invalid initailizer: #{init.inspect}"
    end
    @size = point
    @fg_buffer = []
    @bg_buffer = []
    self.size = size
  end

  def size=(new_size)
    return unless size != new_size
    @size = new_size
    @crop_area = rect new_size
    @contents = resize2d @contents, size, " "
    @fg_buffer = resize2d @bg_buffer, size, Buffer.default_bg
    @bg_buffer = resize2d @bg_buffer, size, Buffer.default_fg
  end

  def on_dirty(&block)
    @on_dirty = block
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
    "<Buffer size:#{size.inspect}>"
  end

  def to_s
    contents.join "\n"
  end

  def tab_size
    2
  end

  def internal_area
    rect(size)
  end

  def subbuffer(area)
    area = internal_area | area
    return buffer unless area.present?

    x_range = area.x_range

    buffer area.size, (contents[area.y_range].collect do |line|
      line[x_range]
    end)
  end

  def dirty_subbuffer
    @dirty_area && subbuffer(@dirty_area)
  end

  #########
  # DRAWING
  #########

  def clear
    fill ' '
  end

  def dirty?
    !!@dirty_area
  end

  def clean
    @dirty_area = nil
  end

  def dirty(area = internal_area)
    @dirty_area = (area & @dirty_area) | internal_area
    @on_dirty.call if @on_dirty
    @dirty_area
  end

  def fill(str)
    if cropped?
      draw_rect(crop_area,str)
    else
      dirty internal_area
      line = fill_line(str, size.x)
      @contents = size.y.times.collect {line.clone}
      self
    end
  end

  def draw_rect(rectangle, fill_string)
    rectangle = rectangle | crop_area if crop_area
    draw_buffer rectangle.loc, buffer(rectangle.size).fill(fill_string)
  end

  def draw_buffer(loc, buffer, source_area = nil)
    source_area = (source_area || buffer.internal_area) | (crop_area - loc)
    return unless source_area.present?

    unless source_area == buffer.internal_area
      loc += source_area.loc
      buffer = buffer.subbuffer(source_area)
    end

    dirty rect(loc, buffer.size)
    @contents = overlay2d(loc, buffer.contents, contents)
    self
  end

end
end
