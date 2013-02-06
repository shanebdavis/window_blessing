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
  buffer
  version
  event_parser
  event_manager
  xterm_log
  xterm_output
  xterm_state
  xterm_input
  xterm_screen
  buffered_screen
  window
  windowed_screen
  widgets/slider
}.each do |file|
  require "foiled/#{file}"
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
        main_window.draw screen_buffer
      end
    end
  end
end
end
