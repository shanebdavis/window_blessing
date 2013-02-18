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
    em.on(:custom_event) {|event|val = event[:val]}
    val.should == 0
    em.handle_event type: :custom_event, :val => 1
    val.should == 1
  end

  it "on_event_exception" do
    em = EventManager.new "a parent"
    exception_count = 0
    em.on(:event_exception) {exception_count+=1}
    em.on(:custom_event)    {raise "foo"}
    em.handle_event type: :custom_event
    exception_count.should == 1
  end

  it "on_every_event" do
    em = EventManager.new "a parent"
    event_count = 0
    em.on {event_count+=1}
    em.handle_event type: :custom_event
    em.handle_event type: :a_different_custom_event
    event_count.should == 2
  end

  it "on_unhandled_event" do
    em = EventManager.new "a parent"
    handled = ""

    em.on(:custom_event)    {handled+="a"}
    em.on(:unhandled_event) {handled+="b"}

    em.handle_event type: :custom_event
    em.handle_event type: :a_different_custom_event
    em.handle_event type: :b_different_custom_event
    em.handle_event type: :custom_event
    handled.should == "abba"
  end

  it "exception in on_event_exception handler" do
    em = EventManager.new "a parent"
    handled = ""

    em.on(:event_exception) {handled+="e";raise "foo"}
    em.on(:custom_event)    {handled+="c";raise "foo"}

    em.handle_event type: :custom_event
    handled.should == "ce"
  end

  it "on_last" do
    em = EventManager.new "a parent"
    handled = ""

    em.on(:custom_event) {handled += "a"}
    em.on(:custom_event) {handled += "b"}
    em.on_last(:custom_event) {handled += "!"}

    em.handle_event type: :custom_event
    handled.should == "ba!"
  end

  it "handle_events" do
    em = EventManager.new "a parent"
    handled = ""
    em.on(:custom_event) {handled += "a"}
    em.handle_events [{type: :custom_event},{type: :other_custom_event},{type: :custom_event}]
    handled.should == "aa"
  end

  it "layered event types" do
    em = EventManager.new "a parent"
    handled = ""
    em.on(:custom_event) {handled += "C"}
    em.on(:custom_event, :sub_type_a) {handled += "ca"}
    em.on(:custom_event, :sub_type_b) {handled += "cb"}

    em.handle_event :type => :custom_event
    handled.should == "C"

    handled = ""
    em.handle_event :type => [:custom_event]
    handled.should == "C"

    handled = ""
    em.handle_event :type => [:custom_event, :sub_type_a]
    handled.should == "caC"

    handled = ""
    em.handle_event :type => [:custom_event, :sub_type_b]
    handled.should == "cbC"
  end
end
end
