require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimBo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set local tieme to Warsow
    config.time_zone = 'Warsaw'
    # Set store timie in database the same as local time, not UTC
    config.active_record.default_timezone = :local

    config.after_initialize do
      if ActiveRecord::Base.connection.table_exists? 'decidim_admin_extended_banned_words'
        Obscenity::Base.blacklist = Decidim::AdminExtended::BannedWord.pluck(:name)
      end
    end

    # Defaults from Rails 7
    config.active_storage.variable_content_types = %w(image/png image/gif image/jpeg image/tiff image/bmp image/vnd.adobe.photoshop image/vnd.microsoft.icon image/webp image/avif image/heic image/heif)

    # Defaults for Rails 5
    # config.action_dispatch.default_headers = {
    #   'X-Frame-Options' => 'SAMEORIGIN',
    #   'X-XSS-Protection' => '1; mode=block',
    #   'X-Content-Type-Options' => 'nosniff'
    # }
  end
end

