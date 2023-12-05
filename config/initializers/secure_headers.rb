if Rails.env.development?
  SecureHeaders::Configuration.default do |config|
    config.x_xss_protection = "0"
    # config.x_frame_options = "DENY"
    # config.x_download_options = "noopen" # Wylaczone zeby mozna bylo podgladac maile na localhost
    config.cookies = {
      secure: true, # mark all cookies as "Secure"
      httponly: true, # mark all cookies as "HttpOnly"
      samesite: {
        lax: true # mark all cookies as SameSite=lax
      }
    }
    config.csp = {
      default_src: %w(http: 'self'),
      font_src: %w('self' data: http:),
      frame_src: %w('self'),
      # Wylaczone zeby mozna bylo podgladac maile na localhost
      #frame_src: %w('none'),
      # frame_ancestors: %w('none'),
      img_src: %w('self' http: data:),
      media_src: %w(http: 'self'),
      object_src: %w('none'),
      script_src: %w('self' http: 'unsafe-inline'),
      # script_src: %w('self' http:),
      # script_src: ["'self'", "https://#{ENV['MATOMO_HOST']}"],
      style_src: %w('self' http: 'unsafe-inline')
    }
  end
else
  SecureHeaders::Configuration.default do |config|
    config.x_xss_protection = "0"
    config.x_frame_options = "DENY"
    # config.x_download_options = "noopen"
    config.cookies = {
      secure: true, # mark all cookies as "Secure"
      httponly: true, # mark all cookies as "HttpOnly"
      samesite: {
        lax: true # mark all cookies as SameSite=lax
      }
    }
    config.csp = {
      default_src: %w(https: 'self'),
      font_src: %w('self' data: https:),
      frame_ancestors: %w('self'),
      img_src: %w('self' http: https: data: www.googletagmanager.com https://*.google-analytics.com https://*.analytics.google.com https://*.googletagmanager.com https://*.g.doubleclick.net https://*.google.com http://bo.um.warszawa.pl),
      object_src: %w('none'),
      script_src: if Rails.env.production?
                    ["'self'", "'unsafe-eval'",
                     'http://bo.testum.warszawa.pl', 'https://bo.testum.warszawa.pl', 'https://nominatim.cdsh.dev',
                     'https://*.googletagmanager.com', 'https://cdnjs.cloudflare.com', 'https://cdn.jsdelivr.net']
                  else
                    ["'self'", "'unsafe-inline'", "'unsafe-eval'",
                     'http://bo.testum.warszawa.pl', 'https://bo.testum.warszawa.pl', 'https://nominatim.cdsh.dev',
                     'https://*.googletagmanager.com', 'https://cdnjs.cloudflare.com', 'https://cdn.jsdelivr.net']
                  end,
      style_src: %w('self' https: 'unsafe-inline'),
      connect_src: ["'self'", "https://nominatim.cdsh.dev", "https://*.googletagmanager.com", "https://*.google-analytics.com", "https://*.analytics.google.com", "https://*.g.doubleclick.net", "https://*.google.com"]
    }
  end
end
