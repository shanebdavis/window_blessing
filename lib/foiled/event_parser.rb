require "babel_bridge"

module Foiled
class EventParser < BabelBridge::Parser
  rule :root, many(:event) do
    def events
      event.collect {|e| e.event.merge(raw:e.to_s)}
    end
  end

  rule :root do # ok to have empty string
    def events; []; end
  end

  rule :event, /[^\e]+/ do
    def event; {:type => :characters} end
  end

  rule :command, /[a-zA-Z]/
  rule :number, /[0-9]+/ do
    def to_i; to_s.to_i; end
  end
  rule :numbers, many(:number,";") do
    def to_a; @array||= number.collect{|n| n.to_i} end
  end

  rule :event, "\e[8;", :numbers, "t" do
    include GuiGeo
    def event
      {:type => :xterm_state, :state_type => :size, :state => point(*numbers.to_a.reverse)}
    end
  end

  rule :event, "\e[4;", :numbers, "t" do
    include GuiGeo
    def event
      {:type => :xterm_state, :state_type => :display_pixel_size, :state => point(*numbers.to_a.reverse)}
    end
  end

  rule(:event, "\e[O")                {def event;{:type => :blur};end}
  rule(:event, "\e[I")                {def event;{:type => :focus};end}

  rule :event, :key_press do
    def event; {:type => :key_press, :key => key, :modifiers => modifiers} end

    def modifiers
      m = key_press.modifier
      m && m.modifiers
    end
  end

  rule(:key_press, "\x7F")                {def key;:backspace;end}
  rule(:key_press, "\e", :modifier, "B")  {def key;:down;end}
  rule(:key_press, "\e", :modifier, "D")  {def key;:left;end}
  rule(:key_press, "\e", :modifier, "E")  {def key;:begin;end}
  rule(:key_press, "\e", :modifier, "C")  {def key;:right;end}
  rule(:key_press, "\e", :modifier, "A")  {def key;:up;end}
  rule(:key_press, "\e", :modifier, "Z")  {def key;:reverse_tab;end}
  rule(:key_press, "\e", :modifier, "H")  {def key;:home;end}
  rule(:key_press, "\e", :modifier, "F")  {def key;:end;end}
  rule(:key_press, "\e", :modifier, "P")  {def key;:f1;end}
  rule(:key_press, "\e", :modifier, "Q")  {def key;:f2;end}
  rule(:key_press, "\e", :modifier, "R")  {def key;:f3;end}
  rule(:key_press, "\e", :modifier, "S")  {def key;:f4;end}
  rule(:key_press, "\e", :modifier, "F")  {def key;:home;end}
  rule(:key_press, "\e", :modifier, "H")  {def key;:end;end}

  rule :modifier, "[", :numbers do
    def modifiers
      {
      2 => [:shift],
      3 => [:alt],
      4 => [:shift, :alt],
      5 => [:control],
      6 => [:shift, :control],
      7 => [:alt, :control],
      8 => [:shift, :alt, :control],
      }[numbers[-1].to_i]
    end
  end

  rule :modifier, /[\[O]/ do
    def modifiers; []; end
  end

  rule :event, "\e[", :number, "~" do
    def event
      {
      :type => :key_press,
      :key => {
        3 => :delete,
        2 => :insert,
        6 => :page_down,
        5 => :page_up,
        13 => :f3,
        14 => :f4,
        15 => :f5,
        17 => :f6,
        18 => :f7,
        19 => :f8,
        20 => :f9,
        21 => :f10,
        23 => :f11,
        24 => :f12,
        }[number.to_i]
      }
    end
  end

  rule :event, "\e[", "M", match(/.../).as(:state) do
    def event
      s, x, y = state.to_s.unpack "CCC"
      x -= 33
      y -= 33
      button_actions = {
        32 => :button1_down, 33 => :button2_down, 34=> :button3_down, 35=>:button_up,
        64 => :drag,
        96 => :wheel_down, 97 => :wheel_up
      }
      {
        type: :mouse,
        button: button_actions[s&99],
        state: s,
        x: x,
        y: y
      }.tap do |h|
        h[:shift_down] = true if (s&4)!=0
        h[:alt_down] = true if (s&8)!=0
        h[:control_down] = true if (s&16)!=0
      end
    end
  end

  # catch-all for unknown xterm escape codes
  rule :event, /\e\[[^a-zA-Z]*[a-zA-Z]/ do
    def event
      {:type => :unknown_xterm_code}
    end
  end
end
end
