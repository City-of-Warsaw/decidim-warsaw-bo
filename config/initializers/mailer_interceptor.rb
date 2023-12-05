# frozen_string_literal: true

if Rails.env.staging?
  ActionMailer::Base.register_interceptor(Interceptors::StagingEmailInterceptor)
end