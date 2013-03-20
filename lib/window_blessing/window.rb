module WindowBlessing
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

  include Evented
  attr_accessor :name

  def initialize(area=rect(0,0,20,20))
    @area = rect
    @children = []
    @bg = Buffer.default_bg
    @fg = Buffer.default_fg
    @buffer = Buffer.new area.size, :bg => @bg, :fg => @fg
    self.area = area
  end

  def inspect
    "<Window:#{name || object_id} area:#{area.to_s} children:#{children.length}>"
  end

  # event is in parent-space
  def route_pointer_event(event)
    focus
    event = event.clone
    event[:loc] -= area.loc

    @pointer_focused ||= children.reverse_each.find do |child|
      child.pointer_inside? event[:loc]
    end || :background

    if @pointer_focused == :background
      handle_event(event)
    else
      @pointer_focused.route_pointer_event event
    end

    @pointer_focused = nil if event[:type][1] == :button_up
  end

  module KeyboardFocus
    # keyboard focusing
    attr_reader :focused_child, :focused

    # for internal use only
    def focused_child=(child)
      @focused_child = child
    end

    def focus
      return if focused?
      if parent
        parent.focus
        parent_focused_child = parent.focused_child
        parent_focused_child.blur if parent_focused_child
        parent.focused_child = self
      end

      @focused = true
      handle_event :type => :focus
    end

    def blur
      return if blurred?
      if focused_child
        focused_child.blur
        @focused_child = nil
      end

      @focused = false
      handle_event :type => :blur
    end

    def blurred?; !@focused end
    def focused?; !!@focused end

    def route_keyboard_event(event)
      if focused_child
        focused_child.route_keyboard_event event
      end
      handle_event event
    end
  end
  include KeyboardFocus

  module Geometry
    attr_reader :area
    def area=(area)
      raise "rectangle area required" unless area.kind_of? GuiGeo::Rectangle
      raise "size must be at least 1x1" unless area.size > point
      return if area == @area
      request_redraw  # request redraw before changing the area

      old_size = @area.size
      @area = area

      if area.size != old_size
        resize_buffer old_size
        children.each {|c| c.handle_event type: :parent_resize, old_size:old_size, size:area.size }
        handle_event :type => :resize, :old_size => old_size, :size => area.size
      else
        # only location changed, request external redraw at the new location
        request_redraw
      end
    end

    def internal_area; rect @area.size end

    def loc; area.loc; end
    def loc=(new_loc) self.area = rect new_loc, area.size end

    def size; area.size; end
    def size=(new_size) self.area = rect area.loc, new_size end

    def pointer_inside?(loc) area.contains? loc end

    def move_onscreen
      return unless parent
      parent_area = rect(point, parent.area.size)
      self.area = parent_area.bound(area)
    end

    private
    def resize_buffer(old_size)
      if area.size <= old_size
        @buffer = @buffer.subbuffer(rect(area.size))
        request_redraw
      else
        @buffer = Buffer.new area.size
        request_redraw_internal
      end
    end
  end
  include Geometry

  module ParentsAndChildren
    attr_reader :parent
    attr_reader :children

    # returns nil if nothing was done, otherwise returns child
    def remove_child(child)
      length_before = children.length
      @children = children.select {|c| c!=child}
      if @children.length!=length_before
        child.request_redraw
        child.parent= nil
        child
      end
    end

    def add_child(child)
      children << child
      child.parent= self
      child.request_redraw
      child
    end

    # for internal use only!
    def parent=(p)
      @parent = p
      handle_event type: :parent_set
    end

    def each_child(&block)
      children.each &block
    end

    def each_child_with_index(&block)
      children.each_with_index &block
    end

    def path
      [parent && parent.path,"#{self.class}#{self.area}#{":"+name if name}"].flatten.compact.join(',')
    end

    def parent_path
      parent && parent.path
    end
  end
  include ParentsAndChildren

  module Drawing
    Window.attr_accessor_with_redraw :bg, :fg
    attr_reader :redraw_areas, :buffer

    def redraw_areas
      (@redraw_areas && @redraw_areas.areas || [])
    end

    def add_redraw_area(area)
      area = area | internal_area
      (@redraw_areas ||= WindowRedrawAreas.new) << area
      area
    end

    # return redraw_areas after clearing it (returns [] if none)
    def clear_redraw_areas
      ret = redraw_areas
      @redraw_areas = nil
      ret
    end

    def request_redraw_internal(area = internal_area)
      request_redraw add_redraw_area(area)
    end

    # ask the parent to redraw all, or, if area is set, some of the area covered by this window
    def request_redraw(redraw_area = nil)
      redraw_area ||= internal_area
      parent && parent.request_redraw_internal(redraw_area + loc)
    end

    def redraw_requested?; redraw_areas.length > 0 end

    # Reset @buffer to the designated background. The default implementation resets it to the ' ' character with @bg and @fg colors.
    #
    # NOTE: Buffer may have a cropping area set
    #
    # NOTE: Safe to override. Calling 'super' is optional. Should fully replace all character, foreground and background colors for @buffer's current croparea.
    def draw_background
      buffer.fill :string => ' ', :bg => bg, :fg => fg
    end

    # Update @buffer
    #
    # The default implementation calls #draw_background and then calls #draw on each child.
    #
    # NOTE: Buffer may have a cropping area set
    #
    # NOTE: Safe to override. Calling 'super' is optional.
    def draw_internal(area = nil)
      buffer.cropped(area) do
        draw_background
        children.each do |child|
          child.draw buffer, buffer.crop_area - child.loc
        end
      end
    end

    # perform the request redraws
    # return the areas redrawn (returns [] if none)
    def redraw
      clear_redraw_areas.each {|area| draw_internal area}
    end

    # Draw the window:
    #
    # 1) Draw all requested internal redraw areas, and clear all requests.
    # 2) Draw @buffer to target_buffer. Optionally, only draw the specified internal_area.
    # 3) return an array of internal areas redrawn
    def draw(target_buffer = nil, internal_area = self.internal_area)
      ret = redraw
      target_buffer.draw_buffer loc, buffer, internal_area if target_buffer
      ret
    end
  end
  include Drawing
end
end
