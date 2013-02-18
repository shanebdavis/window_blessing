require 'spec_helper'

module WindowBlessing
describe "EventedVariable" do
  include Tools

  it "get" do
    e = EventedVariable.new 4
    e.get.should == 4
  end

  it "set (no listeners)" do
    e = EventedVariable.new 4
    e.set(5).should == 4
    e.get.should == 5
  end

  it "inspect" do
    e = EventedVariable.new 4
    (!!e.inspect["4"]).should == true
  end

  it "set (with listeners)" do
    e = EventedVariable.new 4
    handled = ""
    e.on(:change) {handled+="c"}
    e.on(:refresh) {handled+="r"}
    e.set(5).should == 4
    e.get.should == 5
    handled.should == "rc"
  end

  it "refresh (with listeners)" do
    e = EventedVariable.new 4
    handled = ""
    e.on(:change) {handled+="c"}
    e.on(:refresh) {handled+="r"}
    e.refresh(5).should == 4
    e.get.should == 5
    handled.should == "r"
  end
end
end
