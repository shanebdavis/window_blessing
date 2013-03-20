module WindowBlessing
class WindowRedrawAreas
  include Tools
  attr_reader :areas

  def initialize
    @areas = []
  end

  # first pass merging algorithm:
  # merge all overlapping areas with area until no overlapping areas
  # This creates a non-overlapping set of areas, but it may be much bigger total area than before.
  # TODO - for "two-point" overlaps - just shrink one of the rectangles so they don't overlap but still cover the same area
  def <<(area)
    overlapping, non_overlapping = @areas.partition {|a| a.overlaps?(area)}
    while overlapping.length > 0
      overlapping.each {|a| area &= a}
      overlapping, non_overlapping = non_overlapping.partition {|a| a.overlaps?(area)}
    end
    @areas = non_overlapping + [area]
  end
end
end
