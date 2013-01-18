module Foiled
class Point < Struct.new(:x, :y)
  include Tools

  def initialize(*args)
    self.x = self.y = 0
    super if args.length!=0
  end

  def min(b); point(super(x, b.x), super(y, b.y)); end
  def max(b); point(super(x, b.x), super(y, b.y)); end

  def inspect; "Point(#{x},#{y})" end
  def to_s; "(#{x},#{y})" end

  def >=(b) x>=b.x && y>=b.y end
  def <=(b) x<=b.x && y<=b.y end
  def >(b) x>b.x && y>b.y end
  def <(b) x<b.x && y<b.y end

  def +(b) b.kind_of?(Point) ? point(x+b.x, y+b.y) : point(x+b, y+b) end
  def -(b) b.kind_of?(Point) ? point(x-b.x, y-b.y) : point(x-b, y-b) end
  def *(b) b.kind_of?(Point) ? point(x*b.x, y*b.y) : point(x*b, y*b) end
  def /(b) b.kind_of?(Point) ? point(x/b.x, y/b.y) : point(x/b, y/b) end
end
end
