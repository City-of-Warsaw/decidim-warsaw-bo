# frozen_string_literal: true

Devise.setup do |config|
  config.password_length = 10..128

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = Rails.env.development? ? nil : 30.minutes
end
