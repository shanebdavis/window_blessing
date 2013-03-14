module WindowBlessing

# There are two events to subscribe to on evented variables:
#
# on :change
#   Subscribe if you need to update the Model when the value changes
#   NOTE: a :refresh event is fired before every :change event
#   Ex: if the user change a Slider, this event is fired allowing you to respond to that change
#
# on :refresh
#   Subscribe if you only need to update the View when the value changes
#   Ex: Sliders subscribe to :refresh to update their view when the value changes
#       If you want to update the position of the slider, but not trigger any :change events, call .refresh(value)
#
# both :change and :refresh events only fire if the value actually changed
class EventedVariable
  include Evented
  include Tools

  def initialize(value)
    @value = value
  end

  # set a block to be called to processes the set value
  # block should return the processed value
  def before_filter(&block)
    @before_filter = block
  end

  def inspect
    "<#{self.class}:#{object_id} value:#{@value.inspect}>"
  end

  def get; clone_value(@value) end

  # update the value & trigger :change and :refresh events
  # returns the old value
  def set(value)
    old_value = refresh(value)
    handle_event :type => :change, :old_value => old_value, :value => @value if old_value != @value
    old_value
  end

  # update the value & only trigger :refresh events
  # subscribe to :refresh events if you need to know when the value changes, but you shouldn't change any model-state because of it
  # if you are changing model-state, subscribe to :change
  def refresh(value)
    value = @before_filter.call(value,@value) if @before_filter
    old_value = @value
    @value = value
    handle_event :type => :refresh, :old_value => old_value, :value => value if old_value != value
    old_value
  end

end
end
