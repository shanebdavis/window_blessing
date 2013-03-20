require 'spec_helper'

module WindowBlessing
describe "WindowRedrawAreas" do
  include Tools

  it "basic init" do
    wra = WindowRedrawAreas.new
    wra.areas.should == []
    wra << rect(5,5,10,10)
    wra.areas.should == [rect(5,5,10,10)]
  end

  it "two non overlapping areas" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,10,10)
    wra << rect(50,5,10,10)
    wra.areas.should == [rect(5,5,10,10),rect(50,5,10,10)]
  end

  it "two overlapping areas" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,10,10)
    wra << rect(10,5,10,10)
    wra.areas.should == [rect(5,5,15,10)]
  end

  it "three areas collaps to one" do
    wra = WindowRedrawAreas.new
    wra << rect(0,0,2,10)
    wra << rect(2,5,5,5)
    wra.areas.should == [rect(0,0,2,10),rect(2,5,5,5)]
    wra << rect(0,9,3,1)
    wra.areas.should == [rect(0,0,7,10)]
  end

  it "tl overlap" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,10,10)
    wra << rect(0,0,10,10)
    wra.areas.should == [rect(0,0,15,15)]
  end

  it "tr overlap" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,10,10)
    wra << rect(10,0,10,10)
    wra.areas.should == [rect(5,0,15,15)]
  end

  it "bl overlap" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,10,10)
    wra << rect(0,10,10,10)
    wra.areas.should == [rect(0,5,15,15)]
  end

  it "br overlap" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,10,10)
    wra << rect(10,10,10,10)
    wra.areas.should == [rect(5,5,15,15)]
  end

  it "just barely no overlap" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,5,10)
    wra << rect(10,5,5,10)
    wra.areas.should == [rect(5,5,5,10),rect(10,5,5,10)]
  end

  it "just barely overlap" do
    wra = WindowRedrawAreas.new
    wra << rect(5,5,5,10)
    wra << rect(9,5,5,10)
    wra.areas.should == [rect(5,5,9,10)]
  end
end
end
