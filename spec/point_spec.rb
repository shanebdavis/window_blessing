require 'spec_helper'

module Foiled
describe "Point" do
  include Tools

  it "init" do
    point.should == point(0,0)
  end

  it "+" do
    (point(1,2) + point(3,4)).should == point(4,6)
    (point(1,2) + 3).should == point(4,5)
  end

  it "-" do
    (point(9,8) - point(3,4)).should == point(6,4)
    (point(9,8) - 3).should == point(6,5)
  end

  it "*" do
    (point(9,8) * point(3,4)).should == point(27,32)
    (point(9,8) * 3).should == point(27,24)
  end

  it "/" do
    (point(36,24) / point(4,3)).should == point(9,8)
    (point(36,24) / 2).should == point(18,12)
  end

  it "==" do
    (point(3,4) == point(3,4)).should == true
    (point(3,4) == point(2,4)).should == false
    (point(3,4) == point(3,3)).should == false
  end

  it "<=" do
    (point(3,4) <= point(3,4)).should == true
    (point(3,4) <= point(2,4)).should == false
    (point(3,4) <= point(3,3)).should == false
    (point(4,4) <= point(3,4)).should == false
    (point(3,5) <= point(3,4)).should == false
  end

  it "<" do
    (point(3,4) < point(4,5)).should == true
    (point(3,4) < point(3,5)).should == false
    (point(3,4) < point(4,4)).should == false
    (point(4,4) < point(4,5)).should == false
    (point(3,5) < point(4,5)).should == false
  end

  it ">=" do
    (point(3,4) >= point(3,4)).should == true
    (point(2,4) >= point(3,4)).should == false
    (point(3,3) >= point(3,4)).should == false
    (point(3,4) >= point(4,4)).should == false
    (point(3,4) >= point(3,5)).should == false
  end

  it ">" do
    (point(4,5) > point(3,4)).should == true
    (point(3,5) > point(3,4)).should == false
    (point(4,4) > point(3,4)).should == false
    (point(4,5) > point(4,4)).should == false
    (point(4,5) > point(3,5)).should == false
  end

  it "min" do
    point(5,5).min(point(9,9)).should == point(5,5)
    point(9,9).min(point(5,5)).should == point(5,5)
    point(9,5).min(point(5,9)).should == point(5,5)
    point(5,9).min(point(9,5)).should == point(5,5)
  end

  it "max" do
    point(5,5).max(point(9,9)).should == point(9,9)
    point(9,9).max(point(5,5)).should == point(9,9)
    point(9,5).max(point(5,9)).should == point(9,9)
    point(5,9).max(point(9,5)).should == point(9,9)
  end
end
end
