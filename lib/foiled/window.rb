module Foiled
class Window
  include Tools
  attr_reader :requested_redraw_area, :frame_buffer


  # you should never set the parent directly
  attr_accessor :parent
  attr_accessor :area

  private
  attr_reader :children

  public
  def initialize(area)
    @area = area
    @frame_buffer = FrameBuffer.new area.size
    request_internal_redraw
  end

  def loc; area.loc; end

  def redraw_if_expanded(old_size, new_size)
    request_internal_redraw unless new_size <= old_size
  end

  def area=(a)
    request_redraw
    old_size = @area.size
    @frame_buffer.size = a.size
    @area = a
    redraw_if_expanded old_size, a.size
    request_redraw
  end

  def internal_area
    rect @area.size
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
    @children ||= []
    @children << child
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
  private

  def request_internal_redraw(area = internal_area)
    @requested_redraw_area = area & @requested_redraw_area
  end

  def redraw(area)
    fb = frame_buffer
    fb.crop(area) do
      fb.clear
      children && children.each {|child| child.draw fb}
    end
    @requested_redraw_area = nil if area.contains?(@requested_redraw_area)
  end

  public

  # if area is nil, only ask the parent to redraw the area covered by this window
  # if it isn't nil, set an internal redraw request AND request the parent redraw that area, too
  def request_redraw(area = nil)
    request_internal_redraw(area) if area
    area ||= internal_area
    area.loc += @area.loc
    parent && parent.request_redraw(area)
  end

  # redraw self if there was a recent call to request_redraw
  # draw to parent_frame_buffer if set
  def draw(parent_frame_buffer=nil)

    redraw @requested_redraw_area if @requested_redraw_area

    parent_frame_buffer.draw_frame(loc, frame_buffer) if parent_frame_buffer
  end
end
end
