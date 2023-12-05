# frozen_string_literal: true

module Interceptors
  # Prevent sending emails to users from @example.com domain
  class StagingEmailInterceptor
    def self.delivering_email(mail)
      unless deliver?(mail)
        mail.perform_deliveries = false
        Rails.logger.debug "Interceptor prevented sending mail #{mail.inspect}!"
      end
    end

    def self.deliver?(mail)
      !mail.header[:to].to_s.include?("example")
    end
  end
end