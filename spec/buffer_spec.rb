require 'spec_helper'

module WindowBlessing
describe "Buffer" do
  include Tools

  def test_frame(options={})
    buffer(point(4,4), {:contents => %w{1234 2345 3456 4567}}.merge(options))
  end

  it "blank fb" do
    buffer(point(4,4)).to_s.should == "    \n    \n    \n    "
  end

  it "string init" do
    buffer(point(4,4),:contents => ["hi","there"]).to_s.should == "hi  \nther\n    \n    "
    buffer(point(4,4),:contents => "hi\nthere").to_s.should == "hi  \nther\n    \n    "
    buffer(point(4,4),:contents => "hi\n\t\0here").to_s.should == "hi  \n??he\n    \n    "
  end

  it "inspect" do
    buffer(point 4,4).inspect.class.should == String
  end

  it "invalid init" do
    expect { buffer(point(4,4),:contents => 1) }.to raise_error
  end

  it "subbuffer" do
    test_frame.subbuffer(rect(1,1,2,2)).to_s.should == "34\n45"
  end

  it "array init" do
    test_frame.to_s.should == "1234\n2345\n3456\n4567"
  end

  it "crop" do
    (f=buffer(point 4,4)).cropped(rect(1,1,2,2)) do
      f.crop_area.should == rect(1,1,2,2)
      f.cropped?.should == true
    end
  end

  it "fill" do
    fb = buffer(point(4,4))
    fb.fill :string => "-"
    fb.to_s.should == "----\n----\n----\n----"
  end

  it "fill out of bounds" do
    fb = buffer(point(4,4))
    fb.fill :area => rect(0,-4,1,1), :string => "-", :bg=>color(0,0,0)
    fb.to_s.should == "    \n    \n    \n    "
  end

  it "cropped fill" do
    (f=test_frame).cropped(rect(1,1,2,1)) do
      f.fill :string => '-'
    end.to_s.should == "1234\n2--5\n3456\n4567"
  end

  it "draw_rect" do
    (f=buffer(point(4,4))).to_s.should == "    \n    \n    \n    "
    f.draw_rect(rect(1,0,2,2),:string => "-")
    f.to_s.should == " -- \n -- \n    \n    "
  end

  it "clear" do
    fb = buffer(point 2,2).fill(:string => '-')
    fb.to_s.should == "--\n--"
    fb.clear
    fb.to_s.should == "  \n  "
  end

  it "draw_buffer" do
    f1 = test_frame
    f2 = buffer(point(2,2), :contents => "ab\nbc")
    f1.draw_buffer(point(1,1),f2)
    f1.to_s.should == "1234\n2ab5\n3bc6\n4567"
  end

  it "cropped draw_buffer" do
    f1 = test_frame
    f2 = buffer(point(2,2), :contents => "ab\nbc")
    f1.cropped(rect(1,1,2,1)) do
      f1.draw_buffer(point(1,1),f2)
    end.to_s.should == "1234\n2ab5\n3456\n4567"
  end

  it "fill only overwrites what is provided" do
    f0 = test_frame :bg => 9, :fg => 8

    f1 = f0.clone
    f1.to_s.should == "1234\n2345\n3456\n4567"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9]]

    f1.fill :string => "!"
    f1.to_s.should == "!!!!\n!!!!\n!!!!\n!!!!"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9]]

    f1 = f0.clone
    f1.fill :bg => 0
    f1.to_s.should == "1234\n2345\n3456\n4567"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]

    f1 = f0.clone
    f1.fill :fg => 0
    f1.to_s.should == "1234\n2345\n3456\n4567"
    f1.fg_buffer.should == [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9]]
  end

  it "cropped fill only overwrites what is provided" do
    f0 = test_frame :bg => 9, :fg => 8

    f1 = f0.clone
    f1.to_s.should == "1234\n2345\n3456\n4567"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9]]

    f1.cropped(rect(1,1,2,2)) {f1.fill :string => "!"}
    f1.to_s.should == "1234\n2!!5\n3!!6\n4567"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9]]

    f1 = f0.clone
    f1.cropped(rect(1,1,2,2)) {f1.fill :bg => 0}
    f1.to_s.should == "1234\n2345\n3456\n4567"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 0, 0, 9], [9, 0, 0, 9], [9, 9, 9, 9]]

    f1 = f0.clone
    f1.cropped(rect(1,1,2,2)) {f1.fill :fg => 0}
    f1.to_s.should == "1234\n2345\n3456\n4567"
    f1.fg_buffer.should == [[8, 8, 8, 8], [8, 0, 0, 8], [8, 0, 0, 8], [8, 8, 8, 8]]
    f1.bg_buffer.should == [[9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9], [9, 9, 9, 9]]
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

  it "color buffers" do
    f1 = test_frame

    f1.fg_buffer.should == [[7, 7, 7, 7], [7, 7, 7, 7], [7, 7, 7, 7], [7, 7, 7, 7]]
    f1.bg_buffer.should == [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
  end

  it "sanitize_contents" do
    f1 = test_frame
    f1.contents = "hi\t!\nthere"
    f1.to_s.should == "hi?!\nther\n    \n    "
    f1.contents[1]="boo\x00"
    f1.to_s.should == "hi?!\nboo\x00\n    \n    "
    f1.sanitize_contents 2..-1
    f1.to_s.should == "hi?!\nboo\x00\n    \n    "
    f1.sanitize_contents 1..1
    f1.to_s.should == "hi?!\nboo?\n    \n    "
  end

  it "each_line" do
    f1 = test_frame
    f1.each_line.collect{|a|a}.should == [
      ["1234", [7, 7, 7, 7], [0, 0, 0, 0]],
      ["2345", [7, 7, 7, 7], [0, 0, 0, 0]],
      ["3456", [7, 7, 7, 7], [0, 0, 0, 0]],
      ["4567", [7, 7, 7, 7], [0, 0, 0, 0]]
    ]
  end

  it "fg_buffer=" do
    f1 = test_frame
    f1.fg_buffer = [[8],[6,7,8]]
    f1.fg_buffer.should == [[8, 7, 7, 7], [6, 7, 8, 7], [7, 7, 7, 7], [7, 7, 7, 7]]
    f1.bg_buffer.should == [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
  end

  it "bg_buffer=" do
    f1 = test_frame
    f1.bg_buffer = [[8],[6,7,8]]
    f1.fg_buffer.should == [[7, 7, 7, 7], [7, 7, 7, 7], [7, 7, 7, 7], [7, 7, 7, 7]]
    f1.bg_buffer.should == [[8, 0, 0, 0], [6, 7, 8, 0], [0, 0, 0, 0], [0, 0, 0, 0]]
  end
end
end
