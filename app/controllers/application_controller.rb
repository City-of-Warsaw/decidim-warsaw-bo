class ApplicationController < ActionController::Base

  # before_action :show_headers # setup in rails_headers.rb
  # after_action :show_headers # setup in rails_headers.rb
  # before_action :put_headers # setup in rails_headers.rb

  # this is only for Rails 5, it is fixed in rails 6
  def put_headers
    response.set_header('Referrer-Policy', 'strict-origin-when-cross-origin')
    # response.set_header('X-Content-Type-Options', 'nosniff')
    response.set_header('X-Frame-Options', 'DENY')
    response.set_header('X-XSS-Protection', '0') # https://stackoverflow.com/questions/9090577/what-is-the-http-header-x-xss-protection/57802070#57802070
    response.set_header('Content-Security-Policy', "default-src 'self' https:; " \
        "font-src 'self' https: data:;" \
        "img-src 'self' https: data:;" \
        "media-src 'none'; " \
        "object-src 'none'; " \
        "script-src 'self'; " \
        "style-src 'self' https: 'unsafe-inline' ")
  end

  def show_headers
    ap "headers - " * 10
    # ap response.headers
    ap response.get_header('Content-Security-Policy')
  end
end
