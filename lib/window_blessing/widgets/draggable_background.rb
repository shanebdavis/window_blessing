module WindowBlessing
module Widgets
module DraggableBackground

  def initialize(*args)
    super *args
    on :pointer, :button1_down do |event| @mouse_offset = event[:loc] end
    on :pointer, :drag         do |event| self.loc += event[:loc] - @mouse_offset end
  end

end
end
end
