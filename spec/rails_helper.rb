ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production? or Rails.env.staging?

require 'faker'
require 'spec_helper'
require 'rspec/rails'
require 'devise'
require 'capybara/rails'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)

    @robot = FactoryGirl.build(:robot, name: "Robert-#{SecureRandom.hex}")
    @robot.save!
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include Devise::Test::IntegrationHelpers, type: :channel
  config.include Devise::Test::IntegrationHelpers, type: :job
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.include Devise::Test::ControllerHelpers, type: :view

  config.extend GenericMacros
  config.extend ChannelMacros, type: :channel
  config.extend ControllerMacros, type: :controller
  config.extend ViewMacros, type: :view

  config.include Rails.application.routes.url_helpers

  config.include Requests::JsonHelpers, type: :controller
end
