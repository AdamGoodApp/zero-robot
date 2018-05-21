class RobotController < ApplicationController
  def dashboard
    @view_config = {
      cache: CacheJob.read_cache!(),
      toolpaths: get_toolpaths(),
    }
  end

  def expert_dashboard
    authorize! :read_expert_dashboard, current_user
    @view_config = {
      joint_number: get_joint_number(),
      cache: CacheJob.read_cache!(),
    }
  end

  def viewer
    @view_config = {
      joint_number: get_joint_number(),
      cache: CacheJob.read_cache!(),
      online_enabled: can?(:set_robot_online, @user),
      toolpaths: get_toolpaths(),
      users: get_users(),
    }
  end

  private

  def get_joint_number
    6 # JOINTS
  end

  def get_toolpaths
    @user.toolpaths.map do |toolpath|
      {id: toolpath.id, name: toolpath.name}
    end
  end

  def get_users
    User.where.not(id: @user.id).map do |user|
      {id: user.id, name: user.email}
    end
  end
end
