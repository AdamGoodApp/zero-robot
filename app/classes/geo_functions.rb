class GeoFunctions

  # Robot geometry constants
  def self.botgeo_ee
    75.00
  end

  def self.botgeo_z
    213.278
  end

  def self.botgeo_bicep
    300.0
  end

  def self.botgeo_arm
    225.0
  end

  def self.l1
    245.00
  end

  def self.l2
    58.00
  end

  def self.l3
    273.00
  end

  def self.l4
    58.00
  end

  def self.l5
    242.00
  end

  def self.l6
    58.00
  end

  def self.l7
    159.75
  end

  # Environment constants
  def self.origin
    APoint.new(0, 0, 0)
  end

  def self.invalid_a_point
    APoint.new("", "", "")
  end

  def self.x_axis
    AVector.new(1, 0, 0)
  end

  def self.y_axis
    AVector.new(0, 1, 0)
  end

  def self.z_axis
    AVector.new(0, 0, 1)
  end

  def self.world_xy
    APlane.new(origin, x_axis, y_axis)
  end

  def self.world_yz
    APlane.new(origin, y_axis, z_axis)
  end

  def self.world_xz
    APlane.new(origin, x_axis, z_axis)
  end

  def self.invalid_a_vector
    AVector.new("", "", "")
  end

  def self.invalid_plane
    APlane.new(invalid_a_point, invalid_a_vector, invalid_a_vector)
  end

  def self.invalid_a_line
    ALine.new(invalid_a_point, invalid_a_point)
  end


  def self.invalid_circle
    ACircle.new(invalid_plane, "")
  end

  def self.plus_point(p0, p1)
    APoint.new(p0.x + p1.x, p0.y + p1.y, p0.z + p1.z)
  end

  def self.point_plus_vector(p, v)
    APoint.new(p.x + v.x, p.y + v.y, p.z + v.z)
  end

  def self.point_minus_vector(p, v)
    APoint.new(p.x - v.x, p.y - v.y, p.z - v.z)
  end

  def self.point_times(p, val)
    APoint.new(p.x*val, p.y*val, p.z*val)
  end

  def self.point_divide(p, val)
    APoint.new(p.x / val, p.y / val, p.z / val)
  end

  def self.point_minus_point(to, from)
    AVector.new(to.x - from.x, to.y - from.y, to.z - from.z)
  end

  def self.vector_plus_vector(v1, v2)
    AVector.new(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
  end

  def self.vector_minus_vector(v1, v2)
    AVector.new(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
  end

  def self.vector_minus(v)
    AVector.new(-v.x, -v.y, -v.z)
  end

  def self.vector_divide(v, val)
    AVector.new(v.x / val, v.y / val, v.z / val)
  end

  def self.vector_times(v, val)
    AVector.new(v.x * val, v.y * val, v.z * val)
  end

  def self.vector_angle(va, vb)
    va = va.normalize
    vb = vb.normalize
    angle = (va.x * vb.x + va.y * vb.y + va.z * vb.z)
    if angle < -1
      angle = -1.000
    elsif angle > 1
      angle = 1
    end
    Math.acos(angle)
  end

  def self.vector_angle_two(va, vb, vp)
    a1 = vector_angle(va, vb)
    va = va.rotate(1.5707963267948966192313216916398, vp.z_axis)
    a2 = vector_angle(va, vb)
    a1 = 6.283185307179586476925286766559 - a1 if a2 > 1.5707963267948966192313216916398
    a1
  end

  def self.vector_cross_product(va, vb)
    AVector.new((va.y * vb.z) - (va.z * vb.y), (va.z * vb.x) - (va.x * vb.z), (va.x * vb.y) - (va.y * vb.x))
  end

  def self.vector_dot_product(va, vb)
    (va.x * vb.x) + (va.y * vb.y) + (va.z * vb.z)
  end

  def self.plane_plus_vector(plane, delta)
    orig = point_plus_vector(plane.origin, delta)
    APlane.new(orig, plane.x_axis, plane.y_axis)
  end

  def self.plane_intersect(p0, p1)
    return invalid_a_line if !p0.is_valid? || !p1.is_valid?
    return invalid_a_line if vector_angle(p0.z_axis, p1.z_axis) == 0

    k1 = (p0.origin.x * p0.z_axis.x) + (p0.origin.y * p0.z_axis.y) + (p0.origin.z * p0.z_axis.z)
    k2 = (p1.origin.x * p1.z_axis.x) + (p1.origin.y * p1.z_axis.y) + (p1.origin.z * p1.z_axis.z)
    n1 = p0.z_axis
    n2 = p1.z_axis

    xval = 0
    yval = 0
    zval = 0

    if n1.x != 0
      yval = (n1.x * k2 - n2.x * k1) / (n1.x * n2.y - n1.y * n2.x)
      xval = (k1 - n1.y * yval) / n1.x
      zval = 0

      xval_finite = xval.finite?
      xval_nan = xval.is_a? Numeric
      yval_finite = yval.finite?
      yval_nan = yval.is_a? Numeric


      if !xval_finite || xval_nan || !yval_finite || yval_nan
        zval = (n1.x * k2 - n2.x * k1) / (n1.x * n2.z - n1.z * n2.x)
        xval = (k1 - n1.z * zval) / n1.x
        yval = 0
      end

    elsif n1.y != 0
      zval = (n1.y * k2 - n2.y * k1) / (n1.y * n2.z - n1.z * n2.y)
      yval = (k1 - n1.z * zval) / n1.y
      xval = 0

      zval_finite = zval.finite?
      zval_nan = zval.is_a? Numeric
      yval_finite = yval.finite?
      yval_nan = yval.is_a? Numeric

      if !zval_finite || zval_nan || !yval_finite || yval_nan
        xval = (n1.y * k2 - n2.y * k1) / (n1.y * n2.x - n1.x * n2.y)
        yval = (k1 - n1.x * xval) / n1.y
        zval = 0
      end

    elsif n1.z != 0
      yval = (n1.z * k2 - n2.z * k1) / (n1.z * n2.y - n1.y * n2.z)
      zval = (k1 - n1.y * yval) / n1.z
      xval = 0

      zval_finite = zval.finite?
      zval_nan = zval.is_a? Numeric
      yval_finite = yval.finite?
      yval_nan = yval.is_a? Numeric

      if !zval_finite || zval_nan || !yval_finite || yval_nan
        xval = (n1.z * k2 - n2.z * k1) / (n1.z * n2.x - n1.x * n2.z)
        zval = (k1 - n1.x * xval) / n1.z
        yval = 0
      end
    end

    pt = invalid_a_point
    pt = APoint.new(xval, yval, zval)
    dir = vector_cross_product(p0.z_axis, p1.z_axis)
    ALine.new(point_minus_vector(pt,dir), point_plus_vector(pt, dir))

  end

  def self.circle_intersect_line(c, l)
    return invalid_a_line if !c.is_valid? || !l.is_valid?
    # if line is non-coplanar with the plane, abort
    return invalid_a_line if c.plane.distance_to(l.st).abs > 0.01 || c.plane.distance_to(l.en).abs > 0.01

    dir_st = point_minus_point(l.st, c.plane.origin)
    st_x = vector_dot_product(dir_st, c.plane.x_axis)
    st_y = vector_dot_product(dir_st, c.plane.y_axis)
    dir_en = point_minus_point(l.en, c.plane.origin)
    en_x = vector_dot_product(dir_en, c.plane.x_axis)
    en_y = vector_dot_product(dir_en, c.plane.y_axis)
    r = c.radius

    # solve m & b in line equation y = mx + b
    m = (en_y - st_y) / (en_x - st_x)
    b = st_y - (m * st_x)

    # solving for X with circle, x = (-2mb +- sqrt(-4(m^2+1)(b^2-r^2))/2(m^2+1)
    temp_0 = m * m + 1
    temp_1 = Math.sqrt((4 * m * m * b * b) - 4 * temp_0 * (b * b - r * r)) #b square - 4ac
    x_0 = (-2 * m * b + temp_1) / (2 * temp_0)
    x_1 = (-2 * m * b - temp_1) / (2 * temp_0)

    x_0_finite = x_0.finite?
    x_0_nan = x_0.is_a? Numeric

    return invalid_a_line if x_0_nan || !x_0_finite #no intersection
    y_0 = m * x_0 + b
    y_1 = m * x_1 + b

    delta_0 = vector_times(c.plane.x_axis, x_0)
    delta_0 = vector_plus_vector(delta_0, vector_times(c.plane.y_axis, y_0))
    pt_0 = point_plus_vector(c.plane.origin,delta_0)
    delta_1 = vector_times(c.plane.x_axis, x_1)
    delta_1 = vector_plus_vector(delta_1, vector_times(c.plane.y_axis, y_1))
    pt_1 = point_plus_vector(c.plane.origin, delta_1)

    ALine.new(pt_0, pt_1)

  end

  def self.circle_intersect_circle(c_a, c_b)
    return invalid_a_line if !c_a.is_valid? || !c_b.is_valid?

    # test planes for coplanarity
    dist = c_a.plane.distance_to(c_b.plane.origin).abs
    dist += c_a.plane.distance_to(point_plus_vector(c_b.plane.origin, c_b.plane.x_axis)).abs
    dist += c_a.plane.distance_to(point_plus_vector(c_b.plane.origin, c_b.plane.y_axis)).abs

    # if planes are not coplanar, solve by PlaneXPlane + CircleXLine
    if dist > 0.01
      x_l0 = plane_intersect(c_a.plane, c_b.plane)

      return invalid_a_line if !x_l0.is_valid?

      x_l0 = circle_intersect_line(c_a, x_l0)
      x_l0
    end

    # make intersection plane
    c_l = ALine.new(c_a.plane.origin, c_b.plane.origin)
    x_vect = c_l.direction
    y_vect = x_vect.rotate(1.5707963267948966192313216916398, c_a.plane.z_axis)

    x_pln = APlane.new(c_a.plane.origin, x_vect, y_vect)
    # do the math
    d = x_pln.origin.distance_to(c_b.plane.origin)
    r_a = c_a.radius
    r_b = c_b.radius
    x = (r_a * r_a + d * d - r_b * r_b) / (d * 2.0)
    y = Math.sqrt(r_a * r_a - x * x)
    ALine.new(x_pln.point_at(x, y), x_pln.point_at(x, -y))

  end

  def self.to_radians(deg)
    deg * (Math::PI / 180)
  end

  def self.to_degrees(rad)
    rad * (180 / Math::PI)
  end

  def self.of_map(value, input_min, input_max, output_min, output_max)
    ((value - input_min) / (input_max - input_min) * (output_max - output_min) + output_min)
  end

end