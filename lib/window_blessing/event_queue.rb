module WindowBlessing
class EventQueue
  attr_accessor :queue

  def initialize
    @queue = []
  end

  def <<(a)
    case a
    when Array then @queue += a
    else @queue << a
    end
  end

  def clear; @queue = [] end
  def pop_all; @queue.tap {clear} end
  def empty?; @queue.length == 0 end
end
end
