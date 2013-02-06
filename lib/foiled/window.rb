module Foiled
class Window
  include Tools
  attr_reader :requested_redraw_area, :buffer


  # you should never set the parent directly
  attr_accessor :parent
  attr_accessor :area
  attr_accessor :bg

  private
  attr_reader :children

  public
  def initialize(area=rect(0,0,20,20))
    raise "rectangle area required" unless area.kind_of? GuiGeo::Rectangle
    raise "size must be at least 1x1" unless area.size > point
    XtermLog.log "new window area = #{area.inspect}"
    @area = area
    @bg = Buffer.default_bg
    @buffer = Buffer.new area.size, :bg => @bg
    @children = []
  end

  def bg=(bg)
    @bg = bg
    request_internal_redraw
  end

  def redraw_requested?
    !!requested_redraw_area
  end

  def inspect
    "<Window:0x%x area:#{area.to_s} children:#{children.length}>"%object_id
  end

  def loc; area.loc; end

  def size_changed(old_size)
    if area.size <= old_size
      @buffer = @buffer.subbuffer(rect(area.size))
      request_redraw
    else
      @buffer = Buffer.new area.size
      request_internal_redraw
    end
  end

  def area=(a)
    return if a==@area
    request_redraw

    old_size = @area.size
    @area = a

    if a.size != old_size
      size_changed(old_size)
    else
      request_redraw
    end
  end

  def loc; area.loc; end
  def size; area.size; end
  def size=(new_size) self.area = rect area.loc, new_size end
  def loc=(new_loc) self.area = rect new_loc, area.size end

  def move_onscreen
    return unless parent
    parent_area = rect(point, parent.area.size)
    self.area = parent_area.bound(area)
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

  def mouse_event(event)
    event[:loc] -= area.loc
    XtermLog.log "event=#{event}"
    @mouse_focused || children.reverse_each do |child|
      if child.area.contains? event[:loc]
        @mouse_focused=child
        break
      end
    end
    @mouse_focused.mouse_event event if @mouse_focused
    @mouse_focused = nil if event[:button] == :button_up
  end

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
  def draw(target_buffer=nil, internal_area=nil)
    internal_area ||= @requested_redraw_area
    return unless internal_area
    internal_area = internal_area | self.internal_area
    return if internal_area.size <= point

    if @requested_redraw_area
      b = buffer
      b.crop(internal_area) do
        b.fill :string => ' ', :bg => bg
        children.each do |child|
          child.draw b, (b.crop_area - child.loc)
        end
      end
      @requested_redraw_area = nil if internal_area.contains?(@requested_redraw_area)
    end

    target_buffer.draw_buffer(loc, buffer, internal_area) if target_buffer

    internal_area
  end
end
end
