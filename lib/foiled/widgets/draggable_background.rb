module Foiled
module Widgets
module DraggableBackground

  def pointer_event_on_background(event)
    case event[:button]
    when :button1_down then
      @mouse_offset = event[:loc]
    when :drag then
      self.loc += event[:loc] - @mouse_offset
    end
  end

end
end
end
