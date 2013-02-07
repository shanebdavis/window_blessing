module Foiled
class Color < Struct.new(:r, :g, :b)

  def initialize(r=0.0,g=r,b=r)
    super r, g, b
  end

  def inspect; "color#{self}" end
  def to_s; "(#{r},#{g},#{b})" end
  def to_hex; "%02x%02x%02x"%to_a256 end
  def to_a256; [r256,g256,b256] end
  def to_a; [r,g,b] end

  # to xterm pallette color
  def to_p; rgb_screen_color(r,g,b) end

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

  def +(v) v.kind_of?(Color) ? Color(r + v.r, g + v.g, b + v.b) : Color(r + v, g + v, b + v) end
  def -(v) v.kind_of?(Color) ? Color(r - v.r, g - v.g, b - v.b) : Color(r - v, g - v, b - v) end
  def *(v) v.kind_of?(Color) ? Color(r * v.r, g * v.g, b * v.b) : Color(r * v, g * v, b * v) end
  def /(v) v.kind_of?(Color) ? Color(r / v.r, g / v.g, b / v.b) : Color(r / v, g / v, b / v) end

end
end
