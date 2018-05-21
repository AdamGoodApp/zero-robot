ActiveSupport.on_load :active_job do
  ActiveJob::Base.logger = Logger.new(nil) if not Rails.env.development?
end

ActiveSupport.on_load :action_cable do
  ActionCable::Server::Base.config.logger = Logger.new(nil) if not Rails.env.development?
end
