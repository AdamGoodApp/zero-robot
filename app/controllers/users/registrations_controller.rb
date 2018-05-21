class Users::RegistrationsController < Devise::RegistrationsController

  before_action :except => [:new, :create] do
    authenticate_user!(:force => true)
  end
  before_action :tokens
  skip_before_action :first_setup!, only: [:create]

  def create
    super do | user |
      RobotChannel.new_user({id: user.id, name: user.email}) if user.errors.empty?
    end
  end

  def update
    super do | user |
      RobotChannel.updated_user({id: user.id, name: user.email}) if user.errors.empty?
    end
  end

  def destroy
    super do | user |
      RobotChannel.deleted_user({id: user.id}) if user.errors.empty?
    end
  end

  def add_token
    @user.api_keys.create
    redirect_to edit_user_registration_path
  end

  def remove_token
    @user.api_keys.delete(params[:id])
    redirect_to edit_user_registration_path
  end

  private

  def tokens
    @tokens = @user.api_keys if @user
  end
end
