require 'spec_helper'

module WindowBlessing
describe "XtermEventParser" do
  include Tools

  def parse(str)
    events = XtermEventParser.new.parse(str).events
    events.length.should == 1
    events[0]
  end

  it "blur and focus" do
    {:type=>:blur, :raw=>"\e[O"}.should == parse("\e[O")
    {:type=>:focus, :raw=>"\e[I"}.should == parse("\e[I")
  end

  it "escape, tab, enter/return" do
    {:type=>[:key_press, :escape], :key=>:escape, :raw=>"\e"}.should == parse("\e")
    {:type=>[:key_press, :enter], :key=>:enter, :raw=>"\r"}.should == parse("\r")
    {:type=>[:key_press, :tab], :key=>:tab, :raw=>"\t"}.should == parse("\t")
    {:type=>[:key_press, :reverse_tab], :key=>:reverse_tab, :raw=>"\e[Z"}.should == parse("\e[Z")
  end

  it "arrow keys" do
    {:type=>[:key_press, :down], :key=>:down, :alt=>true, :raw=>"\e\e[B"}.should == parse("\e\e[B")
    {:type=>[:key_press, :down], :key=>:down, :raw=>"\e[B"}.should == parse("\e[B")
    {:type=>[:key_press, :down], :key=>:down, :shift=>true, :alt=>true, :raw=>"\e[1;10B"}.should == parse("\e[1;10B")
    {:type=>[:key_press, :down], :key=>:down, :shift=>true, :raw=>"\e[1;2B"}.should == parse("\e[1;2B")
    {:type=>[:key_press, :left], :key=>:left, :alt=>true, :raw=>"\e\e[D"}.should == parse("\e\e[D")
    {:type=>[:key_press, :left], :key=>:left, :raw=>"\e[D"}.should == parse("\e[D")
    {:type=>[:key_press, :left], :key=>:left, :shift=>true, :alt=>true, :raw=>"\e[1;10D"}.should == parse("\e[1;10D")
    {:type=>[:key_press, :left], :key=>:left, :shift=>true, :raw=>"\e[1;2D"}.should == parse("\e[1;2D")
    {:type=>[:key_press, :right], :key=>:right, :alt=>true, :raw=>"\e\e[C"}.should == parse("\e\e[C")
    {:type=>[:key_press, :right], :key=>:right, :raw=>"\e[C"}.should == parse("\e[C")
    {:type=>[:key_press, :right], :key=>:right, :shift=>true, :alt=>true, :raw=>"\e[1;10C"}.should == parse("\e[1;10C")
    {:type=>[:key_press, :right], :key=>:right, :shift=>true, :raw=>"\e[1;2C"}.should == parse("\e[1;2C")
    {:type=>[:key_press, :up], :key=>:up, :alt=>true, :raw=>"\e\e[A"}.should == parse("\e\e[A")
    {:type=>[:key_press, :up], :key=>:up, :raw=>"\e[A"}.should == parse("\e[A")
    {:type=>[:key_press, :up], :key=>:up, :shift=>true, :alt=>true, :raw=>"\e[1;10A"}.should == parse("\e[1;10A")
    {:type=>[:key_press, :up], :key=>:up, :shift=>true, :raw=>"\e[1;2A"}.should == parse("\e[1;2A")
  end

  it "control-a" do
    {:type=>:key_press, :key=>:a, :control=>true, :raw=>"\x01"}.should == parse("\x01")
  end

  it "size" do
    {:type=>:xterm_state, :state_type=>:size, :state=>point(99,68), :raw=>"\e[8;68;99t"}.should == parse("\e[8;68;99t")
  end

  it "f-keys" do
    {:type=>[:key_press, :f1], :key=>:f1, :raw=>"\eOP"}.should == parse("\eOP")
    {:type=>[:key_press, :f1], :key=>:f1, :shift=>true, :raw=>"\e[1;2P"}.should == parse("\e[1;2P")
    {:type=>[:key_press, :f2], :key=>:f2, :raw=>"\eOQ"}.should == parse("\eOQ")
    {:type=>[:key_press, :f2], :key=>:f2, :shift=>true, :raw=>"\e[1;2Q"}.should == parse("\e[1;2Q")
    {:type=>[:key_press, :f3], :key=>:f3, :raw=>"\eOR"}.should == parse("\eOR")
    {:type=>[:key_press, :f3], :key=>:f3, :shift=>true, :raw=>"\e[1;2R"}.should == parse("\e[1;2R")
    {:type=>[:key_press, :f4], :key=>:f4, :raw=>"\eOS"}.should == parse("\eOS")
    {:type=>[:key_press, :f4], :key=>:f4, :shift=>true, :raw=>"\e[1;2S"}.should == parse("\e[1;2S")
    {:type=>[:key_press, :f5], :key=>:f5, :shift=>false, :raw=>"\e[15~"}.should == parse("\e[15~")
    {:type=>[:key_press, :f5], :key=>:f5, :shift=>true, :raw=>"\e[15;2~"}.should == parse("\e[15;2~")
    {:type=>[:key_press, :f6], :key=>:f6, :shift=>false, :raw=>"\e[17~"}.should == parse("\e[17~")
    {:type=>[:key_press, :f6], :key=>:f6, :shift=>true, :raw=>"\e[17;2~"}.should == parse("\e[17;2~")
    {:type=>[:key_press, :f7], :key=>:f7, :shift=>false, :raw=>"\e[18~"}.should == parse("\e[18~")
    {:type=>[:key_press, :f7], :key=>:f7, :shift=>true, :raw=>"\e[18;2~"}.should == parse("\e[18;2~")
    {:type=>[:key_press, :f8], :key=>:f8, :shift=>false, :raw=>"\e[19~"}.should == parse("\e[19~")
    {:type=>[:key_press, :f8], :key=>:f8, :shift=>true, :raw=>"\e[19;2~"}.should == parse("\e[19;2~")
    {:type=>[:key_press, :f9], :key=>:f9, :shift=>false, :raw=>"\e[20~"}.should == parse("\e[20~")
    {:type=>[:key_press, :f9], :key=>:f9, :shift=>true, :raw=>"\e[20;2~"}.should == parse("\e[20;2~")
    {:type=>[:key_press, :f10], :key=>:f10, :shift=>false, :raw=>"\e[21~"}.should == parse("\e[21~")
    {:type=>[:key_press, :f10], :key=>:f10, :shift=>true, :raw=>"\e[21;2~"}.should == parse("\e[21;2~")
  end

  it "mouse" do
    {:type=>[:pointer, :button_down, 1], :button=>[:button_down, 1], :state=>32, :loc=>point(23,51), :shift=>false, :alt=>false, :control=>false, :raw=>"\e[M 8T"}.should == parse("\e[M 8T")
    {:type=>[:pointer, :button_up], :button=>:button_up, :state=>35, :loc=>point(33,50), :shift=>false, :alt=>false, :control=>false, :raw=>"\e[M#BS"}.should == parse("\e[M#BS")
    {:type=>[:pointer, :button_down, 1], :button=>[:button_down, 1], :state=>36, :loc=>point(22,31), :shift=>true, :alt=>false, :control=>false, :raw=>"\e[M$7@"}.should == parse("\e[M$7@")
    {:type=>[:pointer, :button_up], :button=>:button_up, :state=>39, :loc=>point(22,31), :shift=>true, :alt=>false, :control=>false, :raw=>"\e[M'7@"}.should == parse("\e[M'7@")
    {:type=>[:pointer, :drag], :button=>:drag, :state=>64, :loc=>point(24,51), :shift=>false, :alt=>false, :control=>false, :raw=>"\e[M@9T"}.should == parse("\e[M@9T")
    {:type=>[:pointer, :drag], :button=>:drag, :state=>68, :loc=>point(34,30), :shift=>true, :alt=>false, :control=>false, :raw=>"\e[MDC?"}.should == parse("\e[MDC?")
    {:type=>[:pointer, :wheel_down], :button=>:wheel_down, :state=>96, :loc=>point(28,44), :shift=>false, :alt=>false, :control=>false, :raw=>"\e[M`=M"}.should == parse("\e[M`=M")
    {:type=>[:pointer, :wheel_up], :button=>:wheel_up, :state=>97, :loc=>point(28,44), :shift=>false, :alt=>false, :control=>false, :raw=>"\e[Ma=M"}.should == parse("\e[Ma=M")
  end
end
end
