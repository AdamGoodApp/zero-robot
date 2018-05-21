class ApplicationJob < ActiveJob::Base
  rescue_from(Exception) do |exception|
    Rails.logger.debug("ActiveJob Exception: #{exception}\n\t#{exception.backtrace.join("\n\t")}")
  end
end
