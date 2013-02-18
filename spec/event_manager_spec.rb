require 'spec_helper'

module WindowBlessing
describe "EventManager" do
  include Tools

  it "inspect" do
    em = EventManager.new "a parent"
    em.inspect["EventManager"].should == "EventManager"
  end

  it "custom event" do
    em = EventManager.new "a parent"
    val = 0
    em.add_handler :custom_event do |event|
      val = event[:val]
    end
    val.should == 0
    em.handle_event type: :custom_event, :val => 1
    val.should == 1
  end

  it "on_event_exception" do
    em = EventManager.new "a parent"
    exception_count = 0
    em.on_event_exception {exception_count+=1}
    em.add_handler(:custom_event) {raise "foo"}
    em.handle_event type: :custom_event
    exception_count.should == 1
  end

  it "on_every_event" do
    em = EventManager.new "a parent"
    event_count = 0
    em.on_every_event {event_count+=1}
    em.handle_event type: :custom_event
    em.handle_event type: :a_different_custom_event
    event_count.should == 2
  end

  it "on_unhandled_event" do
    em = EventManager.new "a parent"
    handled = ""
    em.add_handler(:custom_event) {handled+="a"}
    em.on_unhandled_event {handled+="b"}
    em.handle_event type: :custom_event
    em.handle_event type: :a_different_custom_event
    em.handle_event type: :b_different_custom_event
    em.handle_event type: :custom_event
    handled.should == "abba"
  end

  it "exception in on_event_exception handler" do
    em = EventManager.new "a parent"
    handled = ""
    em.on_event_exception {handled+="e";raise "foo"}
    em.add_handler(:custom_event) {handled+="c";raise "foo"}
    em.handle_event type: :custom_event
    handled.should == "ce"
  end

  it "add_last_handler" do
    em = EventManager.new "a parent"
    handled = ""
    em.add_handler :custom_event do
      handled += "a"
    end
    em.add_handler :custom_event do
      handled += "b"
    end
    em.add_last_handler :custom_event do
      handled += "!"
    end
    em.handle_event type: :custom_event
    handled.should == "ba!"
  end

  if "handle_events"
    em = EventManager.new "a parent"
    handled = ""
    em.add_handler :custom_event do
      handled += "a"
    end
    em.handle_events [{type: :custom_event},{type: :other_custom_event},{type: :custom_event}]
    handled.should == "aa"
  end

end
end
