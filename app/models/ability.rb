class Ability
  include CanCan::Ability

  def initialize(user)
      user ||= User.new # guest user (not logged in)
      if user.admin?
        can :manage, :all
      elsif user.client?
        can :manage, :all
        cannot :read_expert_dashboard, User
        cannot :set_robot_online, User
      end
  end

end
