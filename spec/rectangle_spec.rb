require 'spec_helper'

module Foiled
describe "Rectangle" do
  include Tools

  it "defaults" do
    rect.should == rect(0,0,0,0)
    rect.should == rect(point,point)
  end

  it "invalid init" do
    expect { rect(1,2,3,4,5) }.to raise_error
  end

  it "init with one point" do
    rect(point(1,2)).should == rect(0,0,1,2)
  end

  it "inspect" do
    rect.inspect.class.should == String
  end

  it "contains?" do
    rect(0,0,10,10).contains?(rect(2,2,5,5)).should == true
    rect(0,0,10,10).contains?(rect(8,2,5,5)).should == false
  end

  it ".overlap?" do
    # solidly overlapping
    rect(0,0,10,10).overlaps?(rect(0,0,10,10)).should == true
    rect(0,0,10,10).overlaps?(rect(0,5,10,10)).should == true
    rect(0,0,10,10).overlaps?(rect(5,0,10,10)).should == true

    # just below, just to the right, just above, just to the left
    rect(0,0,10,10).overlaps?(rect(10,0,10,10)).should == false
    rect(0,0,10,10).overlaps?(rect(0,10,10,10)).should == false
    rect(10,0,10,10).overlaps?(rect(0,0,10,10)).should == false
    rect(0,10,10,10).overlaps?(rect(0,0,10,10)).should == false

    # below, right, above, left
    rect(0,0,10,10).overlaps?(rect(11,0,10,10)).should == false
    rect(0,0,10,10).overlaps?(rect(0,11,10,10)).should == false
    rect(11,0,10,10).overlaps?(rect(0,0,10,10)).should == false
    rect(0,11,10,10).overlaps?(rect(0,0,10,10)).should == false

    # just overlapping below, right, above, left
    rect(0,0,10,10).overlaps?(rect(9,0,10,10)).should == true
    rect(0,0,10,10).overlaps?(rect(0,9,10,10)).should == true
    rect(9,0,10,10).overlaps?(rect(0,0,10,10)).should == true
    rect(0,9,10,10).overlaps?(rect(0,0,10,10)).should == true
  end

  it ".union" do
    (rect(0,0,10,10)   & rect(0,5,10,10)).should == rect(0,0,10,15)
    (rect(0,0,10,10)   & rect(5,0,10,10)).should == rect(0,0,15,10)
    (rect(20,20,10,10) & rect(0,0,10,10)).should == rect(0,0,30,30)
  end

  it ".intersection" do
    (rect(0,0,10,10)   | rect(0,0,10,10)).should == rect(0,0,10,10)
    (rect(0,0,10,10)   | rect(0,5,10,10)).should == rect(0,5,10,5)
    (rect(0,0,10,10)   | rect(5,0,10,10)).should == rect(5,0,5,10)
    (rect(0,0,10,10)   | rect(10,0,10,10)).should == rect(0,0,0,0)
    (rect(0,0,10,10)   | rect(-5,-5,10,10)).should == rect(0,0,5,5)
  end

  it ".present?" do
    rect(0,0,1,1).present?.should == true
    rect(0,0,1,0).present?.should == false
    rect(0,0,0,1).present?.should == false
    rect(0,0,0,0).present?.should == false
  end
  it ".blank?" do
    rect(0,0,1,1).blank?.should == false
    rect(0,0,1,0).blank?.should == true
    rect(0,0,0,1).blank?.should == true
    rect(0,0,0,0).blank?.should == true
  end
end
end
