class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Add Flash types corresponding )loosely) to Bootstrap's ones
  add_flash_types :success, :warning, :error, :info

  before_action :first_setup!, except: [:setup]
  before_action :authenticate_user!, except: [:setup]
  before_action :assign_user!
  before_action :should_prerender!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def setup
    if already_setup?
      redirect_to root_path
    end
    @must_setup = true
  end

  private

  def first_setup!
    unless already_setup?
      redirect_to setup_path
    end
  end

  def already_setup?
    if Rails.env.test?
      return true
    end
    User.where(role: 'admin').count > 0
  end

  def assign_user!
    @user = current_user if user_signed_in?
  end

  def should_prerender!
    # TODO: temp
    @should_prerender = false #Rails.env.development? or Rails.env.test?
  end

end
