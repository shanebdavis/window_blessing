#!/usr/bin/env ruby
# encoding: UTF-8
require File.expand_path File.join(File.dirname(__FILE__), %w{.. lib foiled})
include GuiGeo
include Foiled::Tools
include Foiled


WindowedScreen.new.start(:full=>true, :utf8 => true) do |screen|

  screen.root_window.add_child Widget::Slider.new(rect 10,10,10,1)
end
