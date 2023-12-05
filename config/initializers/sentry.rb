# frozen_string_literal: true

if %w[production staging].include?(Rails.env)
  Sentry.init do |config|
    config.dsn = ENV.fetch('SENTRY_DSN')
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Set tracesSampleRate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production
    config.traces_sample_rate = 0.05
    # or
    # config.traces_sampler = lambda do |context|
    #   true
    # end
  end
  # TEST message:
  # Sentry.capture_message("test message from dev")
end
