# frozen_string_literal: true

Decidim::ApplicationMailer.class_eval do
  before_action :set_logo

  def set_logo
    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')
  end
end