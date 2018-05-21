class ACircle

  attr_accessor :plane, :radius, :centre

  def initialize(*args)
    if args.length == 3
      @plane = APlane.new(args[1], args[0].x_axis, args[0].y_axis)
      @radius = args[2]
    elsif args.length == 2
      @plane = args[0]
      @radius = args[1]
    elsif args.length == 1
      @plane = GeoFunctions.world_xy
      @radius = args[0]
    else
      @plane = GeoFunctions.world_xy
      @radius = 0
    end
  end

  def is_valid?
    rad = @radius.is_a? Numeric
    @plane.is_valid? && rad && @radius > 0 ? true : false
  end

end