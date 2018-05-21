module GenericMacros
  # Class
  def make_protected_public(clazz)
    before(:all) do
      @protected_methods = clazz.protected_instance_methods
      clazz.send(:public, *@protected_methods)
    end
    after(:all) do
      clazz.send(:protected, *@protected_methods)
      @protected_methods = nil
    end
  end
  def make_private_public(clazz)
    before(:all) do
      @private_methods = clazz.private_instance_methods
      clazz.send(:public, *@private_methods)
    end
    after(:all) do
      clazz.send(:private, *@private_methods)
      @private_methods = nil
    end
  end

  # Test
  def make_pending(message, force=false)
    before (:each) do
      if force
        skip(message)
      else
        pending(message)
      end
    end
  end

  # Devise
  def setup_devise
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end
  end

  # User
  def create_user(force=false)
    setup_devise

    if force
      before (:each) do
        @user = FactoryGirl.create(:user)
        @user.toolpaths.create!(name: 'Dream')
      end
    else
      let (:user) do
        FactoryGirl.create(:user)
      end
      before (:each) do
        user.toolpaths.create!(name: 'Dream')
      end
    end
  end

  def create_user2(force=false)
    setup_devise

    if force
      before (:each) do
        @user2 = FactoryGirl.create(:user2)
        @user2.toolpaths.create!(name: 'Dream')
      end
    else
      let (:user2) do
        FactoryGirl.create(:user2)
      end
      before (:each) do
        user.toolpaths.create!(name: 'Dream')
      end
    end
  end

  def login_user
    create_user

    before (:each) do
      sign_in user
    end
  end

  def fetch_robot
    let (:robot) { Robot.first }
  end
end

# Mock classes

class FakeUser
  attr_accessor :id, :email, :remember_me, :errors

  def initialize(email, id: 1, remember_me: true, errors: {})
    @id = id
    @email = email
    @remember_me = remember_me
    @errors = ::FakeErrors.new(errors)
  end

  def reset_password_token
    ''
  end

  class << self
    def model_name
      ActiveModel::Name.new(User)
    end
  end
end

class FakeErrors
  def initialize(errors)
    @errors = errors
  end

  def [](key)
    @errors[key]
  end

  def []=(key, value)
    @errors[key] = value
  end

  def empty?
    return @errors.empty?
  end

  def count
    return @errors.count
  end

  def full_messages
    return @errors
  end
end
