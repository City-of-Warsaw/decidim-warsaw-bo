# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "0.24.3"
# gem "decidim-conferences", "0.24.3"
# gem "decidim-consultations", "0.24.3"
# gem "decidim-elections", "0.24.3"
# gem "decidim-initiatives", "0.24.3"
# gem "decidim-templates", "0.24.3"

gem "bootsnap", "1.7.4"

gem "puma", ">= 5.0.0"
gem "uglifier", "~> 4.1"

gem "faker", "~> 2.14"

gem "wicked_pdf", "~> 1.4"
gem 'sidekiq'
gem "mina-sidekiq"
gem "valid_email2", "~> 2.1"

# Deployment
gem 'mina'
gem 'dotenv-rails'

gem 'http'

# Security
gem 'brakeman'

# Do obslugi wulgaryzmow
gem 'obscenity', '1.0.2'

# sentry.io
gem "sentry-ruby"
gem "sentry-rails"

# Active directory
gem 'net-ldap', '0.17'

# Export to Excel
gem 'caxlsx', '3.2.0'
gem 'caxlsx_rails'
gem 'creek'
# gem 'rails_same_site_cookie'
gem 'secure_headers'

gem 'awesome_print'

# import bazy glosujacych
gem 'activerecord-import'

# obsluga SOAP dla Signum
gem "savon", '2.12.0'

# Profiling
# gem 'rack-mini-profiler'
# group :development do
#   gem 'meta_request'
# end
# For call-stack profiling flamegraphs
# gem 'stackprof'

# Swagger
gem 'rswag'

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", "0.24.3"
  gem "pry-byebug"
  gem "pry-rails"
  gem "timecop"
  gem 'pry-rescue'
end

gem 'wkhtmltoimage-binary'
gem 'imgkit'

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
  gem "yard", require: false
end

group :test do
  gem 'database_cleaner-active_record'
end

group :production, :staging do
  gem 'rack_password'
end


# extended functionalities
gem "decidim-admin_extended", path: "decidim-admin_extended"
gem "decidim-core_extended", path: "decidim-core_extended"
gem "decidim-processes_extended", path: "decidim-processes_extended"
gem 'decidim-projects', path: 'decidim-projects'
gem 'decidim-users_extended', path: 'decidim-users_extended'

# Rest API
gem 'active_model_serializers'
gem 'decidim-rest_api', path: 'decidim-module-rest_api'

gem 'whenever', require: false
#4 big migrations
gem 'ruby-progressbar'
gem 'sitemap_generator'
