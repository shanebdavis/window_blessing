require 'spec_helper'

module WindowBlessing
describe "EventQueue" do
  include Tools

  it "new" do
    em = EventQueue.new
    em.queue.should == []
  end

  it "<<" do
    em = EventQueue.new
    em << 1
    em.queue.should == [1]
    em << [2,3]
    em.queue.should == [1,2,3]
  end

  it "clear" do
    em = EventQueue.new
    em << 1
    em.clear
    em.queue.should == []
  end

  it "clear" do
    em = EventQueue.new
    em.empty?.should == true
    em << 1
    em.empty?.should == false
    em.clear
    em.empty?.should == true
  end

  it "pop_all" do
    em = EventQueue.new
    em << 1
    em << 2
    a = em.pop_all
    a.should == [1,2]
    em.queue.should == []
  end

end
end
