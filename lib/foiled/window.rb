module Foiled
class Window
  include Tools
  attr_reader :requested_redraw_area, :buffer


  # you should never set the parent directly
  attr_accessor :parent
  attr_accessor :area
  attr_accessor :background

  private
  attr_reader :children

  public
  def initialize(area=rect(0,0,20,20))
    @area = area
    @buffer = Buffer.new area.size
    @children = []
    request_internal_redraw
  end

  def inspect
    "<Window:0x%x area:#{area.to_s} children:#{children.length}>"%object_id
  end

  def loc; area.loc; end

  def redraw_if_expanded(old_size, new_size)
    request_internal_redraw unless new_size <= old_size
  end

  def area=(a)
    request_redraw
    old_size = @area.size
    @buffer.size = a.size
    @area = a
    redraw_if_expanded old_size, a.size
    request_redraw
  end

  def internal_area
    rect @area.size
  end

  def background=(b)
    @background = b
    request_internal_redraw
  end

  # you should never set the parent directly
  def parent=(p) @parent = p; end

  ################################
  # Children
  ################################

  # returns nil if nothing was done, otherwise returns child
  def remove_child(child)
    length_before = children.length
    @children = children.select {|c| c!=child}
    if @children.length!=length_before
      child.request_redraw
      child.parent = nil
      child
    end
  end

  def add_child(child)
    children << child
    child.parent= self
    child.request_redraw
    child
  end

  def each_child(&block)
    children.each &block
  end

  def each_child_with_index(&block)
    children.each_with_index &block
  end

  ################################
  # DRAWING
  ################################

  def request_internal_redraw(area = internal_area)
    return if @requested_redraw_area && @requested_redraw_area.contains?(area)
    @requested_redraw_area = (internal_area | area) & @requested_redraw_area
    request_redraw area
  end

  # ask the parent to redraw all, or, if area is set, some of the area covered by this window
  def request_redraw(area = nil)
    area ||= internal_area
    area.loc += @area.loc
    parent && parent.request_internal_redraw(area)
  end

  # redraw self if there was a recent call to request_redraw
  # draw to target_buffer if set
  # returns the internal_area that was updated
  def draw(internal_area=nil, target_buffer=nil)
    internal_area ||= @requested_redraw_area
    return unless internal_area
    internal_area = internal_area | self.internal_area

    b = buffer
    b.crop(internal_area) do
      b.fill background || ' '
      children.each do |child|
        child.draw (b.crop_area - child.loc), b
      end
    end
    @requested_redraw_area = nil if internal_area.contains?(@requested_redraw_area)

    target_buffer.draw_buffer(loc, buffer, internal_area) if target_buffer

    internal_area
  end
end
end
