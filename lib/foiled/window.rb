module Foiled
class Window
  include Tools

  class << self
    def Window.attr_accessor_with_redraw( *symbols )
      symbols.each do | symbol |
        class_eval <<ENDCODE
        def #{symbol}
          @#{symbol}
        end

        def #{symbol}=(value)
          old_value = @#{symbol}
          @#{symbol} = value
          request_redraw_internal if old_value != @#{symbol}
        end
ENDCODE
      end
    end
  end

  attr_accessor_with_redraw :bg, :fg

  attr_reader :requested_redraw_area, :buffer

  # you should never set the parent directly
  attr_reader :parent
  attr_accessor :area

  attr_reader :children

  def initialize(area=rect(0,0,20,20))
    @area = rect
    self.area = area
    @bg = Buffer.default_bg
    @fg = Buffer.default_fg
    @buffer = Buffer.new area.size, :bg => @bg, :fg => @fg
    @children = []
    @requested_redraw_area = nil
  end


  def fill(options={})
    @requested_redraw_area = nil
    @buffer.fill options
    request_redraw
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
      request_redraw_internal
    end
  end

  def area=(area)
    raise "rectangle area required" unless area.kind_of? GuiGeo::Rectangle
    raise "size must be at least 1x1" unless area.size > point
    return if area==@area
    request_redraw

    old_size = @area.size
    @area = area

    if area.size != old_size
      size_changed(old_size)
    else
      request_redraw
    end
  end

  def loc; area.loc; end
  def size; area.size; end
  def size=(new_size) self.area = rect area.loc, new_size end
  def loc=(new_loc) self.area = rect new_loc, area.size end

  def pointer_inside?(loc) area.contains? loc end

  def move_onscreen
    return unless parent
    parent_area = rect(point, parent.area.size)
    self.area = parent_area.bound(area)
  end

  def internal_area
    rect @area.size
  end

  # for internal use only!
  def set_parent(p) @parent = p; end

  # override; event is in local-space
  def pointer_event_on_background(event)
  end

  # event is in parent-space
  def pointer_event(event)
    event[:loc] -= area.loc
    @pointer_focused ||= children.reverse_each.find do |child|
      child.pointer_inside? event[:loc]
    end || :background
    if @pointer_focused==:background
      pointer_event_on_background(event)
    else
      @pointer_focused.pointer_event event
    end
    @pointer_focused = nil if event[:button] == :button_up
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
      child.set_parent nil
      child
    end
  end

  def add_child(child)
    children << child
    child.set_parent self
    child.request_redraw
    child
  end

  def each_child(&block)
    children.each &block
  end

  def each_child_with_index(&block)
    children.each_with_index &block
  end

  def path
    [parent && parent.path,"#{self.class}#{self.area}"].flatten.compact.join(',')
  end

  def parent_path
    parent && parent.path
  end

  ################################
  # DRAWING
  ################################

  # sometimes you want to know where redraw requests are coming from
  # Since request_redraw_internal is recursive, you don't want to log the stack trace with every call - just the first one
  # This will log a stack-trace once per call
  def log_request_redraw_internal
    trace = Kernel.caller
    return if trace.count {|line| line["request_redraw_internal"]} > 1
    XtermLog.log "request_redraw_internal trace @requested_redraw_area=#{@requested_redraw_area} path:#{path}\n  "+ trace.join("\n  ")
  end

  def request_redraw_internal(area = internal_area)
    return if @requested_redraw_area && @requested_redraw_area.contains?(area)
    @requested_redraw_area = internal_area | (area & @requested_redraw_area)
    #log_request_redraw_internal
    request_redraw @requested_redraw_area
  end

  # ask the parent to redraw all, or, if area is set, some of the area covered by this window
  def request_redraw(area = nil)
    area ||= internal_area
    area.loc += @area.loc
    parent && parent.request_redraw_internal(area)
  end

  def draw_background
    buffer.fill :string => ' ', :bg => bg, :fg => fg
  end

  def draw_internal
    draw_background
    children.each do |child|
      child.draw buffer, (buffer.crop_area - child.loc)
    end
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
      buffer.cropped(internal_area) {draw_internal}
      @requested_redraw_area = nil if @requested_redraw_area && internal_area.contains?(@requested_redraw_area | self.internal_area)
    end

    target_buffer.draw_buffer(loc, buffer, internal_area) if target_buffer

    internal_area
  end
end
end
