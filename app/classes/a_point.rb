class APoint

  attr_accessor :x, :y, :z

  def initialize(x=0, y=0, z=0)
    @x = x
    @y = y
    @z = z
  end

  def is_valid?
    [@x, @y, @z].all? {|i| i.is_a? Numeric}
  end

  # pt is an APoint instance
  def distance_to(pt)
    return unless pt.is_valid?
    dx = pt.x - @x
    dy = pt.y - @y
    dz = pt.z - @z
    Math.sqrt(dx * dx + dy * dy + dz * dz)
  end

end