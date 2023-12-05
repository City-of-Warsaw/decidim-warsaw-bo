IMGKit.configure do |config|
  if Rails.env.production?
    config.wkhtmltoimage = '/usr/local/bin/wkhtmltoimage'
  end
  config.default_options = { "enable-local-file-access" => 1 }
end