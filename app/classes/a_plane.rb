class APlane

  attr_accessor :origin, :x_axis, :y_axis, :z_axis , :quaternion

  def initialize(*args)
    if args.length == 0
      @origin = GeoFunctions.origin
      @x_axis = GeoFunctions.x_axis
      @y_axis = GeoFunctions.y_axis
      @z_axis = GeoFunctions.z_axis
    elsif args.length == 3
      if args[0].kind_of?(APoint)
        @origin = args[0]
        @x_axis = args[1].normalize
        @y_axis = args[2].normalize
        @z_axis = GeoFunctions.vector_cross_product(@x_axis, @y_axis)
      end
    elsif args.length == 4
      @origin = args[0]
      @x_axis = args[1]
      @y_axis = args[2]
      @z_axis = args[3]
    elsif args.length == 6
      ap = APoint.new(args[0], args[1], args[2])
      pl = APlane.new(ap , GeoFunctions.x_axis, GeoFunctions.y_axis)
      pl = pl.rotate(args[5], pl.z_axis)
      pl = pl.rotate(args[4], pl.y_axis)
      pl = pl.rotate(args[3], pl.x_axis)
      @origin = pl.origin
      @x_axis = pl.x_axis
      @y_axis = pl.y_axis
      @z_axis = pl.z_axis
    else
      nil
    end
    @quaternion = generate_quaternion
    @quaternion = @quaternion.normalize
  end

  def is_valid?
    @origin.is_valid? || @x_axis.is_valid? || @y_axis.is_valid? || @z_axis.is_valid? ? true : false
  end

  def rotate(angle, axis)
    x_a = @x_axis.rotate(angle, axis)
    y_a = @y_axis.rotate(angle, axis)
    APlane.new(@origin, x_a, y_a)
  end

  def generate_quaternion
    r11 = @x_axis.x
    r21 = @x_axis.y
    r31 = @x_axis.z

    r12 = @y_axis.x
    r22 = @y_axis.y
    r32 = @y_axis.z

    r13 = @z_axis.x
    r23 = @z_axis.y
    r33 = @z_axis.z

    tr = r11+r22+r33
    tr1 = r11-r22-r33
    tr2 = -r11+r22-r33
    tr3 = -r11-r22+r33

    if tr>0
      q0 = Math.sqrt(1+tr)/2
      q1 = (r32-r23)/(4*q0)
      q2 = (r13-r31)/(4*q0)
      q3 = (r21-r12)/(4*q0)
      elsif (tr1>tr2) && (tr1>tr3)
      q1 = Math.sqrt(1+tr1)/2
      q0 = (r32-r23)/(4*q1)
      q2 = (r21+r12)/(4*q1)
      q3 = (r31+r13)/(4*q1)
      elsif (tr2>tr3) && (tr2>tr3)
      q2 = Math.sqrt(1+tr2)/2
      q0 = (r13-r31)/(4*q2)
      q1 = (r21+r12)/(4*q2)
      q3 = (r32+r23)/(4*q2)
    else
      q3 = Math.sqrt(1+tr3)/2
      q0 = (r21-r12)/(4*q3)
      q1 = (r31+r13)/(4*q3)
      q2 = (r32+r23)/(4*q3)
    end

    AQuaternion.new(q0,q1,q2,q3)
  end

  # Takes an instance of APoint
  def distance_to(pt)
    if pt.is_valid?
      vect = GeoFunctions.point_minus_point(pt,@origin)
      GeoFunctions.vector_dot_product(vect, @z_axis)
    else
      nil
    end
  end

  # Takes an instance of APoint
  def closest_point(pt)
    if pt.is_valid?
      vect = GeoFunctions.point_minus_point(pt, @origin)
      dist = GeoFunctions.vector_dot_product(vect, @z_axis)
      delta = GeoFunctions.vector_times(@z_axis, dist)
      GeoFunctions.point_minus_vector(pt, delta)
    else
      GeoFunctions.invalid_a_point
    end
  end

  def point_at(*args)
    if args[2]
      delta = GeoFunctions.vector_times(@x_axis, args[0])
      delta = GeoFunctions.vector_plus_vector(delta, GeoFunctions.vector_times(@y_axis, args[1]))
      delta = GeoFunctions.vector_plus_vector(delta, GeoFunctions.vector_times(@z_axis, args[2]))
      GeoFunctions.point_plus_vector(@origin,delta)
    else
      delta = GeoFunctions.vector_times(@x_axis, args[0])
      delta = GeoFunctions.vector_plus_vector(delta, GeoFunctions.vector_times(@y_axis, args[1]))
      GeoFunctions.point_plus_vector(@origin,delta)
    end
  end

end