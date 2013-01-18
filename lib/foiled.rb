=begin
Copyright 2013 Shane Brinkman-Davis
See README for licence information.
=end

%w{
  tools
  buffer
  point
  rectangle
  version
  screen
  window
}.each do |file|
  require File.join(File.dirname(__FILE__),"foiled",file)
end

module Foiled
  # Your code goes here...
class << self
  include Tools
  def main(&block)
    main_window = Window.new
    Screen.new.open do
      instance_exec(main_window, &block)
      on_tick do
        main_window.area = rect(screen_buffer.size)
        write point(0,3), "main_window.requested_redraw_area = #{main_window.requested_redraw_area}"
        main_window.draw screen_buffer
        write point(0,4), "screen_buffer.dirty_area = #{screen_buffer.dirty_area.inspect}"
      end
    end
  end
end
end
