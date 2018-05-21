class Users::SessionsController < Devise::SessionsController
  def destroy
    ActionCable.server.disconnect(current_user: @user)
    super
  end
end
