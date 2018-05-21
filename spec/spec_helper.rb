require 'simplecov'
require 'simplecov-csv'

if not ENV['COVERAGE_REPORTS'].nil?
  SimpleCov.formatter = SimpleCov::Formatter::CSVFormatter
  SimpleCov.coverage_dir(ENV['COVERAGE_REPORTS'])
end
if not ENV['MIN_COV'].nil?
  SimpleCov.minimum_coverage(ENV['MIN_COV'])
end
if not ENV['MAX_DROP'].nil?
  SimpleCov.maximum_coverage_drop(ENV['MAX_DROP'])
end
SimpleCov.start 'rails'
SimpleCov.add_group 'Channels', 'app/channels'
SimpleCov.add_group 'Libraries', ['lib/(?!api_constraints).*', 'app/classes/motion_plan.rb']
SimpleCov.add_group 'Old Stuff', ['app/classes/(?!motion_plan).*']
SimpleCov.add_group 'Adam', ['app/classes/motion_plan.rb', 'app/controllers/api', 'app/controllers/application_controller.rb', 'app/models', 'lib/api_constraints.rb']
SimpleCov.add_group 'Louis', ['app/channels', 'app/controllers/(?!api).*', 'app/helpers', 'app/jobs', 'app/views', 'lib/cache', 'lib/queue', 'lib/zmq'] #'app/classes/motion_plan.rb', 'app/models/segment.rb'
# SimpleCov.add_group 'Front-End', ['app/controllers/(?!api).*', 'app/helpers', 'app/views']
SimpleCov.add_filter 'lib/protocol'
SimpleCov.groups.delete 'Mailers'

RSpec.configure do |config|
  # TODO: fix specs or Server Side Rendering
  config.filter_run_excluding ssr: true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

end
