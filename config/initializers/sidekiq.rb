# frozen_string_literal: true

redis_url = ENV['REDIS_SERVER_URL'].present? ? ENV['REDIS_SERVER_URL'] : 'redis://localhost:6379'

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
