class AVector

  attr_accessor :x, :y, :z

  # X and Y can be an APoint Instance, x subs from and y subs to
  def initialize(x=0, y=0,z=0)
    if x.is_a? Numeric
      if y.is_a? Numeric
        @x = x
        @y = y
        @z = z
      end
    else
      @x = y.x - x.x
      @y = y.y - x.y
      @z = y.z - x.z
    end
  end

  def length
    Math.sqrt(@x * @x + @y * @y + @z * @z)
  end

  def normalize
    c_length = length
    AVector.new(@x / c_length, @y / c_length, @z / c_length)
  end

  # axis is an AVector instance
  def rotate(angle, axis)
    axis = axis.normalize if axis.length != 1.0
    cos0 = Math.cos(angle)
    cos1 = 1 - cos0
    sin0 = Math.sin(angle)
    xval = ((cos0 + (axis.x * axis.x) * cos1) * @x) + (((axis.x * axis.y * cos1) - (axis.z * sin0)) * @y) + (((axis.x * axis.z * cos1) + (axis.y * sin0)) * @z)
    yval = (((axis.x * axis.y * cos1) + (axis.z * sin0)) * @x) + ((cos0 + (axis.y * axis.y) * cos1) * @y) + (((axis.y * axis.z * cos1) - (axis.x * sin0)) * @z)
    zval = (((axis.x * axis.z * cos1) - (axis.y * sin0)) * @x) + (((axis.y * axis.z * cos1) + (axis.x * sin0)) * @y) + ((cos0 + (axis.z * axis.z) * cos1) * @z)
    AVector.new(xval, yval, zval)
  end

  def is_valid?
    [@x, @y, @z].all? {|i| i.is_a? Numeric}
  end

end