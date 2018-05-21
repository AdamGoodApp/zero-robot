class Origin

  # class with functions that relate to the movement of the robot
  # outputs an ikres (current_ik) with all the required info to move the robot
  attr_accessor :current_ik

  # ikres being made from incoming pose from tables
  def initialize(pose)
    @current_ik = IKres.from_pose(pose)
  end

  # move robot based on joint rotations, in_axis is used to get desired a0-a5
  def update_origin_by_axis(in_axis)
    temp_ik = IKres.new( in_axis.a0, in_axis.a1 , in_axis.a2 , in_axis.a3 , in_axis.a4 , in_axis.a5 )
    result_ik = MotionPlan.ik_step([@current_ik.a0, @current_ik.a1, @current_ik.a2, @current_ik.a3, @current_ik.a4, @current_ik.a5],
                                   [temp_ik.res_plane.origin.x, temp_ik.res_plane.origin.y, temp_ik.res_plane.origin.z],
                                   [temp_ik.res_plane.x_axis.x, temp_ik.res_plane.x_axis.y, temp_ik.res_plane.x_axis.z],
                                   [temp_ik.res_plane.y_axis.x, temp_ik.res_plane.y_axis.y, temp_ik.res_plane.y_axis.z]
    )
    # update(result_ik) if result_ik[:success]
    update_front(result_ik, in_axis) if result_ik[:success]
  end

  # move robot based on gizmo or nudge
  def translate_origin(axis, offset)
    case axis
      when "x"
        axis = 0
      when "y"
        axis = 1
      when "z"
        axis = 2
      else
        # Raise error
    end

    result_ik = MotionPlan.nudge(axis, offset, [@current_ik.a0, @current_ik.a1, @current_ik.a2, @current_ik.a3, @current_ik.a4, @current_ik.a5])
    update(result_ik) if result_ik[:success]
  end

  # move robot by specifying a target point
  def goto_point(in_point, tRo_x ,tRo_y, tRo_z)
    tem_pln = APlane.new(in_point.x, in_point.y, in_point.z, tRo_x, tRo_y, tRo_z)
    result_ik = MotionPlan.IKsolverNew(tem_pln , @current_ik)
    update(result_ik) if result_ik[:success]
  end


  private
  # update all params of the current ikres
  def update(in_res)
    @current_ik.a0 = in_res[:a0]
    @current_ik.a1 = in_res[:a1]
    @current_ik.a2 = in_res[:a2]
    @current_ik.a3 = in_res[:a3]
    @current_ik.a4 = in_res[:a4]
    @current_ik.a5 = in_res[:a5]
    @current_ik.a6 = in_res[:a6]
    @current_ik.generate_local_frame
    @current_ik
  end

  def update_front(in_res, front_axis)
    @current_ik.a0 = front_axis.a0
    @current_ik.a1 = front_axis.a1
    @current_ik.a2 = front_axis.a2
    @current_ik.a3 = front_axis.a3
    @current_ik.a4 = front_axis.a4
    @current_ik.a5 = front_axis.a5
    @current_ik.a6 = front_axis.a6
    @current_ik.generate_local_frame
    @current_ik
  end
end