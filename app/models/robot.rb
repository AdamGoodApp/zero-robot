class Robot < ApplicationRecord

  has_many :users

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def home?
    home
  end

  def go_home
    robot_origin = Origin.new(poses.first)
    robot_origin.update_origin_by_axis(IKres.new)
    pose_update(robot_origin.current_ik)
    update(home: true)
  end

  def move(axis, increment, rotations)
    pose = Pose.new(rotations)
    if Robot.check_for_collision([pose.a0, pose.a1, pose.a2, pose.a3, pose.a4, pose.a5]) == 0
      robot_origin = Origin.new(pose)
      robot_origin.translate_origin(axis, increment)
      pose_update(robot_origin.current_ik)
      poses.first
    else
      { error: "Collision found" }
    end
  end

  def rotate_joints(in_res)
    if Robot.check_for_collision([in_res[:a0].to_f, in_res[:a1].to_f, in_res[:a2].to_f, in_res[:a3].to_f, in_res[:a4].to_f, in_res[:a5].to_f]) == 0
      temp_origin = Origin.new(poses.first)
      ikres = IKres.new(in_res[:a0].to_f, in_res[:a1].to_f, in_res[:a2].to_f, in_res[:a3].to_f, in_res[:a4].to_f, in_res[:a5].to_f, in_res[:a6].to_f)
      temp_origin.update_origin_by_axis(ikres)
      pose_update(temp_origin.current_ik)
      poses.first
    else
      { error: "Collision found" }
    end
  end

  def get_current_pose
    poses.first
  end

  def pose_update(inIk)
    poses.first.update(pos_x: inIk.res_point.x,
                pos_y: inIk.res_point.y,
                pos_z: inIk.res_point.z,
                vec1_x: inIk.res_plane.x_axis.x,
                vec1_y: inIk.res_plane.x_axis.y,
                vec1_z: inIk.res_plane.x_axis.z,
                vec2_x: inIk.res_plane.y_axis.x,
                vec2_y: inIk.res_plane.y_axis.y,
                vec2_z: inIk.res_plane.y_axis.z,
                a0: inIk.a0,
                a1: inIk.a1,
                a2: inIk.a2,
                a3: inIk.a3,
                a4: inIk.a4,
                a5: inIk.a5,
                a6: inIk.a6
    )
  end

  def self.check_for_collision(angles)
    MotionPlan.self_collision_step(angles)
  end

  def self.active
    Robot.first
  end

end