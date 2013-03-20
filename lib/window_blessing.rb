def add_load_path(path)
  full_path = File.expand_path path
  $LOAD_PATH.unshift full_path unless $LOAD_PATH.include?(path) || $LOAD_PATH.include?(full_path)
end
add_load_path File.dirname(__FILE__)

=begin
Copyright 2013 Shane Brinkman-Davis
See README for licence information.
=end

%w{
  constants
  tools
  color
  buffer
  version
  event_queue
  event_manager
  evented
  evented_variable
  xterm_event_parser
  xterm_log
  xterm_output
  xterm_state
  xterm_input
  xterm_screen
  buffered_screen
  window_redraw_areas
  window
  windowed_screen
  widgets/draggable_background
  widgets/label
  widgets/slider
  widgets/text_field
}.each do |file|
  require "window_blessing/#{file}"
end

module WindowBlessing
class << self
  include Tools
  def main(&block)
    main_window = Window.new
    Screen.new.open do
      instance_exec(main_window, &block)
      on_tick do
        main_window.area = rect(screen_buffer.size)
        main_window.draw screen_buffer
      end
    end
  end
end
end
