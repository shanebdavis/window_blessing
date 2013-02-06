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

  def r256; (r*255+0.5).to_i end
  def g256; (g*255+0.5).to_i end
  def b256; (b*255+0.5).to_i end

  def +(v) v.kind_of?(Color) ? Color(r + v.r, g + v.g, b + v.b) : Color(r + v, g + v, b + v) end
  def -(v) v.kind_of?(Color) ? Color(r - v.r, g - v.g, b - v.b) : Color(r - v, g - v, b - v) end
  def *(v) v.kind_of?(Color) ? Color(r * v.r, g * v.g, b * v.b) : Color(r * v, g * v, b * v) end
  def /(v) v.kind_of?(Color) ? Color(r / v.r, g / v.g, b / v.b) : Color(r / v, g / v, b / v) end

end
end
