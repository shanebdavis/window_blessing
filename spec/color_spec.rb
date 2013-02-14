require 'spec_helper'

module WindowBlessing
describe "Color" do
  include Tools

  it "to_hex" do
    color(1,0.5,0.25).to_hex.should == "#ff7f3f"
  end

  it "init" do
    c = color
    c[:r] = 1.0
    c[:g] = 0.5
    c[:b] = 0.25
    c.to_hex.should == "#ff7f3f"
    c[:r].should == 1.0
    c[:g].should == 0.5
    c[:b].should == 0.25

    c = color
    c[0] = 1.0
    c[1] = 0.5
    c[2] = 0.25
    c.to_hex.should == "#ff7f3f"
    c[0].should == 1.0
    c[1].should == 0.5
    c[2].should == 0.25
  end

  it "from hex" do
    color("#abc").to_hex.should == "#aabbcc"
    color("#abcdef").to_hex.should == "#abcdef"
  end
end
end
