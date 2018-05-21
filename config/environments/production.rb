Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # config.public_file_server.enabled = true

  config.action_cable.disable_request_forgery_protection = true
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_level = :info
  config.log_tags = [ :request_id ]
  config.log_formatter = ::Logger::Formatter.new

  config.active_record.dump_schema_after_migration = false

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # React
  config.react.variant = :production
end
