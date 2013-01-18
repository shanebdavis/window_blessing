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
      instance_eval &block
      on_tick do
        main_window.draw
      end
    end
  end
end
end

