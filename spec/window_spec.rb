require 'spec_helper'

module Foiled
describe "Window" do
  include Tools

  it "init" do
    w = window rect(0,0,4,4)
    w.area.should == rect(0,0,4,4)
    w.buffer.to_s.should == "    \n    \n    \n    "
  end

  it "inspect" do
    w = window rect(0,0,4,4)
    w.inspect.class.should == String
  end

  it "resize" do
    w = window rect(0,0,4,4)
    w.area = rect 0,0,5,5
    w.buffer.to_s.should == "     \n     \n     \n     \n     "
  end

  it 'set background' do
    w = window rect(0,0,4,4)
    w.background = "frank"
    w.buffer.to_s.should == "    \n    \n    \n    "
    w.draw
    w.buffer.to_s.should == "fran\nkfra\nnkfr\nankf"
  end

  it 'add_child' do
    w = window rect(0,0,4,4)
    c = window rect(1,1,1,2)
    c.background = "*"
    w.add_child c
    w.draw
    w.buffer.to_s.should == "    \n *  \n *  \n    "
  end

  it 'remove_child' do
    w = window rect(0,0,4,4)
    (c=w.add_child(window rect(1,1,1,2))).background = "*"
    w.draw
    (w.remove_child c).should == c
    w.draw
    w.buffer.to_s.should == "    \n    \n    \n    "
  end

  it 'stacked children' do
    w = window rect(0,0,4,4)
    w.add_child(window(rect(1,1,2,2))).background="*"
    w.add_child(window(rect(2,0,2,2))).background="@"
    w.draw
    w.buffer.to_s.should == "  @@\n *@@\n ** \n    "
  end

  it "each_child" do
    w = window rect(0,0,4,4)
    (c1=w.add_child(window(rect(1,1,2,2)))).background="*"
    (c2=w.add_child(window(rect(2,0,2,2)))).background="@"
    w.each_child.collect{|a|a}.should == [c1,c2]
    w.each_child_with_index.collect{|a,i|[a,i]}.should == [[c1,0],[c2,1]]
  end
end
end
