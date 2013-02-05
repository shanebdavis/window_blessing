=begin
Copyright 2013 Shane Brinkman-Davis
See README for licence information.
=end

%w{
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
  window
  window_ui
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
        main_window.draw screen_buffer
      end
    end
  end
end
end
