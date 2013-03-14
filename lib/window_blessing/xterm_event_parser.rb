require "babel_bridge"

module WindowBlessing
class XtermEventParser < BabelBridge::Parser
  rule :root, many(:event) do
    def events
      event.collect {|e| ev = e.event; ev[:string] ? ev : ev.merge(raw:e.to_s)}
    end
  end

  rule :root do # ok to have empty string
    def events; []; end
  end

  rule :event, /[^\x00-\x1f\x7F]+/ do
    def event; {type: :string_input, string: to_s} end
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
      {type: :xterm_state, state_type: :size, state: point(*numbers.to_a.reverse)}
    end
  end

  rule :event, "\e[4;", :numbers, "t" do
    include GuiGeo
    def event
      {type: :xterm_state, state_type: :display_pixel_size, state: point(*numbers.to_a.reverse)}
    end
  end

  rule(:event, "\e\x7F")              {def event;{type: [:key_press,:backspace], key: :backspace, alt:true };end}
  rule(:event, "\x7F")                {def event;{type: [:key_press,:backspace], key: :backspace};end}
  rule(:event, "\e[O")                {def event;{type: :blur};end}
  rule(:event, "\e[I")                {def event;{type: :focus};end}

  rule :event, :key_press do
    def event; {type: [:key_press,key], key: key}.merge(modifiers) end

    def modifiers
      key_press.modifier ? key_press.modifier.modifiers : {}
    end
  end

  rule(:key_press, "\e", :modifier, "B")  {def key;:down;end}
  rule(:key_press, "\e", :modifier, "D")  {def key;:left;end}
  rule(:key_press, "\e", :modifier, "E")  {def key;:begin;end}
  rule(:key_press, "\e", :modifier, "C")  {def key;:right;end}
  rule(:key_press, "\e", :modifier, "A")  {def key;:up;end}
  rule(:key_press, "\e", :modifier, "Z")  {def key;:reverse_tab;end}
  rule(:key_press, "\e", :modifier, "P")  {def key;:f1;end}
  rule(:key_press, "\e", :modifier, "Q")  {def key;:f2;end}
  rule(:key_press, "\e", :modifier, "R")  {def key;:f3;end}
  rule(:key_press, "\e", :modifier, "S")  {def key;:f4;end}
  rule(:key_press, "\e", :modifier, "F")  {def key;:home;end;}
  rule(:key_press, "\e", :modifier, "H")  {def key;:end;end; }

  rule :modifier, "\e", :modifier do
    def modifiers
      (modifier.modifiers || {}).merge alt:true
    end
  end

  MODIFER_DECODER = {
    2 => {shift: true},
    3 => {alt: true},
    4 => {shift: true, alt: true},
    5 => {control: true},
    6 => {shift: true, control: true},
    7 => {alt: true, control: true},
    8 => {shift: true, alt: true, control: true},
    9 => {alt: true},
    10 => {shift: true, alt: true},
  }

  rule :modifier, "[", :numbers do
    def modifiers
      MODIFER_DECODER[numbers.to_a[-1].to_i] || {}
    end
  end

  rule :modifier, /[\[O]/ do
    def modifiers; {}; end
  end

  KEY_MAP_DECODER = {
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
  }
  rule :event, "\e[", :number, match?(";2").as(:shift), "~" do
    def event
      key = KEY_MAP_DECODER[number.to_i]
      {
      :type => [:key_press, key],
      :key => key
      }.tap do |m|
        m[:shift]=true if shift
      end
    end
  end

  rule :event, "\e[", "M", match(/.../).as(:state) do
    def event
      s, x, y = state.to_s.unpack "CCC"
      x -= 33
      y -= 33
      button_actions = {
        32 => [:button_down, 1], 33 => [:button_down, 2], 34=> [:button_down, 3], 35=>:button_up,
        64 => :drag,
        96 => :wheel_down, 97 => :wheel_up
      }
      {
        type: [:pointer, button_actions[s&99]].flatten,
        button: button_actions[s&99],
        state: s,
        loc: point(x,y)
      }.tap do |h|
        h[:shift] = true if (s&4)!=0
        h[:alt] = true if (s&8)!=0
        h[:control] = true if (s&16)!=0
      end
    end
  end

  # catch-all for unknown xterm escape codes
  rule :event, /\e\[[^a-zA-Z]*[a-zA-Z]/ do
    def event
      {:type => :unknown_xterm_code}
    end
  end

  rule :event, /[\x00-\x1f]/ do
    def event
      char = "%c"%(to_s.getbyte(0)+"`".getbyte(0))
      {type: :key_press, key: char.to_sym, control: true}
    end
  end

end
end
