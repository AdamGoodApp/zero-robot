class IKres

  attr_accessor :a0, :a1, :a2, :a3, :a4, :a5, :a6, :reach_score, :error_code, :warning_code, :res_plane, :res_point

  def initialize(a0 = 0, a1 = 0, a2 = 0, a3 = 0, a4 = 0, a5 = 0, a6 = 0, reach_score = 0, error_code = 0, warning_code = 0)
    @a0 = a0
    @a1 = a1
    @a2 = a2
    @a3 = a3
    @a4 = a4
    @a5 = a5
    @a6 = a6
    @reach_score = reach_score
    @error_code = error_code
    @warning_code = warning_code

    generate_local_frame
  end

  def self.from_pose(in_pose)
    temp=IKres.new
    temp.a0 = in_pose.a0
    temp.a1 = in_pose.a1
    temp.a2 = in_pose.a2
    temp.a3 = in_pose.a3
    temp.a4 = in_pose.a4
    temp.a5 = in_pose.a5
    temp.a6 = in_pose.a6
    temp.generate_local_frame
    temp
  end

  def generate_local_frame
    ht1 = TransformationMatrix.new(0, 0, GeoFunctions.l1, @a0)
    ht2 = TransformationMatrix.new(Math::PI/2, GeoFunctions.l2, 0, @a1)
    ht3 = TransformationMatrix.new(-(Math::PI/2), -GeoFunctions.l2, GeoFunctions.l3, @a2)
    ht4 = TransformationMatrix.new(Math::PI/2, GeoFunctions.l4, 0, @a3)
    ht5 = TransformationMatrix.new(-(Math::PI/2), -GeoFunctions.l4, GeoFunctions.l5, @a4)
    ht6 = TransformationMatrix.new(Math::PI/2, GeoFunctions.l6, 0, @a5)
    ht7 = TransformationMatrix.new(-(Math::PI/2), -GeoFunctions.l6, GeoFunctions.l7, @a6)

    hfull = ht1.M * ht2.M * ht3.M * ht4.M * ht5.M * ht6.M * ht7.M
    p_des = APoint.new(hfull[0,3], hfull[1,3], hfull[2,3])
    x_axis_des = AVector.new(hfull[0,0], hfull[1,0], hfull[2,0])
    y_axis_des = AVector.new(hfull[0,1], hfull[1,1], hfull[2,1])
    z_axis_des = AVector.new(hfull[0,2], hfull[1,2], hfull[2,2])

    @res_plane = APlane.new(p_des, x_axis_des, y_axis_des, z_axis_des)
    @res_point = APoint.new(@res_plane.origin.x, @res_plane.origin.y, @res_plane.origin.z)
    APlane.new(p_des, x_axis_des, y_axis_des, z_axis_des)
  end

end