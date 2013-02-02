require 'spec_helper'

module Foiled
describe "Buffer" do
  include Tools

  def test_frame
    buffer(point(4,4), %w{1234 2345 3456 4567})
  end

  it "blank fb" do
    buffer(point(4,4)).to_s.should == "    \n    \n    \n    "
  end

  it "string init" do
    buffer(point(4,4),"hi\nthere").to_s.should == "hi  \nther\n    \n    "
  end

  it "inspect" do
    buffer(point 4,4).inspect.class.should == String
  end

  it "invalid init" do
    expect { buffer(point(4,4),{}) }.to raise_error
  end

  it "subbuffer" do
    test_frame.subbuffer(rect(1,1,2,2)).to_s.should == "34\n45"
  end

  it "array init" do
    test_frame.to_s.should == "1234\n2345\n3456\n4567"
  end

  it "crop" do
    (f=buffer(point 4,4)).crop(rect(1,1,2,2)) do
      f.crop_area.should == rect(1,1,2,2)
      f.cropped?.should == true
    end
  end

  it "fill" do
    fb = buffer(point(4,4))
    fb.fill "-"
    fb.to_s.should == "----\n----\n----\n----"
  end

  it "cropped fill" do
    (f=test_frame).crop(rect(1,1,2,1)) do
      f.fill '-'
    end.to_s.should == "1234\n2--5\n3456\n4567"
  end

  it "draw_rect" do
    (f=buffer(point(4,4))).to_s.should == "    \n    \n    \n    "
    f.draw_rect(rect(1,0,2,2),"-")
    f.to_s.should == " -- \n -- \n    \n    "
  end

  it "clear" do
    fb = buffer(point 2,2).fill('-')
    fb.to_s.should == "--\n--"
    fb.clear
    fb.to_s.should == "  \n  "
  end

  it "draw_buffer" do
    f1 = test_frame
    f2 = buffer(point(2,2),"ab\nbc")
    f1.draw_buffer(point(1,1),f2)
    f1.to_s.should == "1234\n2ab5\n3bc6\n4567"
  end
  it "cropped draw_buffer" do
    f1 = test_frame
    f2 = buffer(point(2,2),"ab\nbc")
    f1.crop(rect(1,1,2,1)) do
      f1.draw_buffer(point(1,1),f2)
    end.to_s.should == "1234\n2ab5\n3456\n4567"
  end

  it "dirty" do
    f1 = test_frame
    f1.dirty?.should == false
    f1.dirty rect(1,2,3,4)
    f1.dirty?.should == true

    f1.dirty_area.should == rect(1,2,3,2)

    s = f1.dirty_subbuffer
    s.to_s.should == "456\n567"

    f1.clean
    f1.dirty?.should == false
  end

  it "on_dirty" do
    f1 = test_frame

    is_now_dirty = false
    f1.on_dirty do
      is_now_dirty = true
    end
    is_now_dirty.should == false
    f1.dirty
    is_now_dirty.should == true
  end
end
end
