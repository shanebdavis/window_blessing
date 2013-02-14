module WindowBlessing
class Color < Struct.new(:r, :g, :b)
  class <<self

    def black;  Color.new(0) end
    def white;  Color.new(1) end
    def gray;   Color.new(0.5) end

    def red;    Color.new(1,0,0) end
    def green;  Color.new(0,1,0) end
    def blue;   Color.new(0,0,1) end

    def yellow; Color.new(1,1,0) end
    def cyan;   Color.new(0,1,1) end
    def magenta;Color.new(1,0,1) end
  end

  def initialize(r=0.0, g=r, b=r)
    case r
    when String then self.hex=r
    else super r, g, b
    end
  end

  def br
    (r + g + b) / 3.0
  end

  def hex=(hex)
    raise "invalid hex color #{hex.inspect}" unless hex[/#?(((..)(..)(..))|((.)(.)(.)))/]
    self.r = ($3 || ($7*2)).hex/255.0
    self.g = ($4 || ($8*2)).hex/255.0
    self.b = ($5 || ($9*2)).hex/255.0
  end

  def inspect; "color#{self}" end
  def to_s; "(#{r},#{g},#{b})" end
  def to_hex; "#%02x%02x%02x"%to_a256 end
  def to_a256; [r256,g256,b256] end
  def to_a; [r,g,b] end

  # to xterm pallette color
  def to_screen_color; rgb_screen_color(r,g,b) end

  def [](i)
    case i
    when 0, :r then r
    when 1, :g then g
    when 2, :b then b
    end
  end

  def []=(key,v)
    case key
    when 0, :r then self.r = v
    when 1, :g then self.g = v
    when 2, :b then self.b = v
    end
  end

  def r256; (r*255).to_i end
  def g256; (g*255).to_i end
  def b256; (b*255).to_i end

  def +(v) v.kind_of?(Color) ? Color.new(r + v.r, g + v.g, b + v.b) : Color.new(r + v, g + v, b + v) end
  def -(v) v.kind_of?(Color) ? Color.new(r - v.r, g - v.g, b - v.b) : Color.new(r - v, g - v, b - v) end
  def *(v) v.kind_of?(Color) ? Color.new(r * v.r, g * v.g, b * v.b) : Color.new(r * v, g * v, b * v) end
  def /(v) v.kind_of?(Color) ? Color.new(r / v.r, g / v.g, b / v.b) : Color.new(r / v, g / v, b / v) end

end
end
