=begin
NOTE: Unlike bitmap graphics, it is often going to be faster to clone bitmap frames rather than do special logic to extract data from frames in-place. This is due the relatively small amount of data for a console-window "buffer" (cols * lines ~= a few kilobytes) and Ruby having optimized routines to handle strings as single units.

For example, it's actually going to be faster to draw a sub-region from one buffer onto another by first copying out the subbuffer from the source buffer and then copying it into the target buffer.

NOTE: I'm just making intelligent guesses here. Haven't actually profiled. It keeps the code simpler, too.

=end
module Foiled
class Buffer
  include Tools

  attr_reader :size
  attr_accessor :contents

  # used as the default color when resizing
  attr_accessor :bg, :fg

  # color buffers. 2D arrays. Each element is a number, 0-255.
  attr_accessor :fg_buffer, :bg_buffer

  attr_accessor :crop_area
  attr_reader :dirty_area

  def Buffer.default_bg; 0; end
  def Buffer.default_fg; 7; end

  # init-options
  #   :bg_bufer => 2D array of 0-255 values
  #   :fg_bufer => 2D array of 0-255 values
  #   :contents => array of strings or string with new-lines
  # fill options (will override init-options)
  #   :string, :bg, :fg -- see #fill
  def initialize(size, options={})
    @size = size

    @contents  = options[:contents]
    @fg_buffer = options[:fg_buffer]
    @bg_buffer = options[:bg_buffer]

    @contents = @contents.split("\n") if @contents.kind_of?(String)

    fill options
    normalize
    clean
  end

  def each_line(&block)
    @contents.zip(fg_buffer,bg_buffer).each &block
  end

  def normalize
    @contents  = resize2d @contents , size, " "
    @fg_buffer = resize2d @fg_buffer, size, Buffer.default_fg
    @bg_buffer = resize2d @bg_buffer, size, Buffer.default_bg
  end

  def on_dirty(&block)
    @on_dirty = block
  end

  def crop_area
    @crop_area || rect(size)
  end

  def crop(area)
    old_crop_area = @crop_area
    @crop_area = area | crop_area
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

    buffer area.size,
      :contents  => subarray2d(contents,area),
      :fg_buffer => subarray2d(fg_buffer,area),
      :bg_buffer => subarray2d(bg_buffer,area),
      :fg => fg,
      :bg => bg
  end

  def dirty_subbuffer
    @dirty_area && subbuffer(@dirty_area)
  end

  #########
  # dirty?
  #########
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

  #########
  # DRAWING
  #########

  def clear
    @contents = @bg_buffer = @fg_buffer = nil
    normalize
    self
  end

  # options
  #  :bg => background color OR 1d array of bg-color pattern - nil => don't touch bg
  #  :fg => foreground color OR 1d array of fg-color pattern - nil => don't touch fb
  #  :string => string - length 1 or more, use to fill-init @contents - nil => don't touch @contents
  def fill(options = {})
    if cropped?
      c = crop_area
      draw_buffer c.loc, buffer(c.size, options)
    else
      dirty internal_area

      string = options[:string]
      fg = options[:fg]
      bg = options[:bg]

      @contents  = gen_array2d(size,string) if string
      @fg_buffer = gen_array2d(size,fg)     if fg
      @bg_buffer = gen_array2d(size,bg)     if bg
    end
    self
  end

  # options - see #fill options
  def draw_rect(rectangle, options={})
    rectangle = rectangle | crop_area
    draw_buffer rectangle.loc, buffer(rectangle.size, options)
    self
  end

  def draw_buffer(loc, buffer, source_area = nil)
    source_area = (source_area || buffer.internal_area) | (crop_area - loc)
    return unless source_area.present?

    unless source_area == buffer.internal_area
      loc += source_area.loc
      buffer = buffer.subbuffer(source_area)
    end

    dirty rect(loc, buffer.size)
    @contents  = overlay2d(loc, buffer.contents, contents)
    @fg_buffer = overlay2d(loc, buffer.fg_buffer, fg_buffer)
    @bg_buffer = overlay2d(loc, buffer.bg_buffer, bg_buffer)
    self
  end

end
end
