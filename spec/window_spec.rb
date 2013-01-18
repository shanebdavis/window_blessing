require 'spec_helper'

module Foiled
describe "Window" do
  include Tools

  it "init" do
    w = Window.new rect(0,0,4,4)
    w.area.should == rect(0,0,4,4)
    w.frame_buffer.to_s.should == "    \n    \n    \n    "
  end

  it "resize" do
    w = Window.new rect(0,0,4,4)
    w.area = rect 0,0,5,5
    w.frame_buffer.to_s.should == "     \n     \n     \n     \n     "
  end
end
end
