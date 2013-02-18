require 'spec_helper'

module WindowBlessing
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

  it 'add_child' do
    w = window rect(0,0,4,4)
    c = window rect(1,1,1,2)
    c.buffer.contents = "*\n*"
    c.clean
    w.add_child c
    w.draw
    w.buffer.to_s.should == "    \n *  \n *  \n    "
  end

  it 'remove_child' do
    w = window rect(0,0,4,4)
    (c=w.add_child(window rect(1,1,1,2))).buffer.fill :string=> "*"
    w.draw
    (w.remove_child c).should == c
    w.draw
    w.buffer.to_s.should == "    \n    \n    \n    "
  end

  it 'stacked children' do
    w = window rect(0,0,4,4)
    (c1=w.add_child(window(rect(1,1,2,2)))).buffer.fill :string=>"*"
    (c2=w.add_child(window(rect(2,0,2,2)))).buffer.fill :string=>"@"
    c1.clean
    c2.clean
    w.draw
    w.buffer.to_s.should == "  @@\n *@@\n ** \n    "
  end

  it "each_child" do
    w = window rect(0,0,4,4)
    (c1=w.add_child(window(rect(1,1,2,2)))).buffer.fill :string=>"*"
    (c2=w.add_child(window(rect(2,0,2,2)))).buffer.fill :string=>"@"
    w.each_child.collect{|a|a}.should == [c1,c2]
    w.each_child_with_index.collect{|a,i|[a,i]}.should == [[c1,0],[c2,1]]
  end

  it "route_poiner_event" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w1.add_child w2
    handled = ""
    w1.on(:pointer) {handled+="w1"}
    w2.on(:pointer) {handled+="w2"}
    w1.route_pointer_event type: :pointer, loc: point()
    handled.should == "w1"

    handled=""
    w1.route_pointer_event type: :pointer, loc: point(2,0)
    handled.should == "w1"

    handled=""
    w1.route_pointer_event type: [:pointer, :button_up], loc: point(2,0)
    handled.should == "w1"

    handled=""
    w1.route_pointer_event type: :pointer, loc: point(2,0)
    handled.should == "w2"
  end

  it "blur and focus" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w3 = window rect(0,2,4,4)
    w4 = window rect(0,2,4,4)
    w1.add_child w2
    w2.add_child w4
    w1.add_child w3

    handled = ""
    w1.on(:focus) {handled+="w1f"}
    w1.on(:blur)  {handled+="w1b"}
    w2.on(:focus) {handled+="w2f"}
    w2.on(:blur)  {handled+="w2b"}
    w3.on(:focus) {handled+="w3f"}
    w3.on(:blur)  {handled+="w3b"}
    w4.on(:focus) {handled+="w4f"}
    w4.on(:blur)  {handled+="w4b"}

    w1.focus
    handled.should == "w1f"

    handled = ""
    w4.focus
    handled.should == "w2fw4f"

    handled = ""
    w3.focus
    handled.should == "w4bw2bw3f"
  end

  it "move and redraw" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w1.add_child w2
    w1.draw

    w1.redraw_requested?.should == false
    w2.redraw_requested?.should == false

    w2.area = rect(0,0,4,4)
    w1.redraw_requested?.should == true
    w2.redraw_requested?.should == false
  end

  it "resize smaller and redraw" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w1.add_child w2
    w1.draw

    w1.redraw_requested?.should == false
    w2.redraw_requested?.should == false

    w2.area = rect(2,0,4,3)
    w1.redraw_requested?.should == true
    w2.redraw_requested?.should == false
  end

  it "resize larger and redraw" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w1.add_child w2
    w1.draw

    w1.redraw_requested?.should == false
    w2.redraw_requested?.should == false

    w2.area = rect(2,0,4,5)
    w1.redraw_requested?.should == true
    w2.redraw_requested?.should == true
  end

  it "redirect_keyboard_event" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w1.add_child w2

    handled = ""
    w1.on(:key_press) {handled+="w1kp"}
    w2.on(:key_press) {handled+="w2kp"}

    w1.route_keyboard_event type: :key_press
    handled.should == "w1kp"

    handled = ""
    w2.focus
    w1.route_keyboard_event type: :key_press
    handled.should == "w2kpw1kp"
  end

  it "path & parent_path" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(2,0,4,4)
    w1.add_child w2
    w1.name = "foo"
    w2.name = "bar"

    w2.path.should == "WindowBlessing::Window(0,0,10,10):foo,WindowBlessing::Window(2,0,4,4):bar"
    w2.parent_path.should == "WindowBlessing::Window(0,0,10,10):foo"
  end

  it "move_onscreen" do
    w1 = window rect(0,0,10,10)
    w2 = window rect(8,0,4,4)
    w1.add_child w2

    w2.move_onscreen
    w2.area.should == rect(6,0,4,4)

  end
end
end
