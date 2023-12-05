# frozen_string_literal: true

module Decidim::AdminExtended
  # MaiTemplate are used to handle customized email messages
  class MailTemplate < ApplicationRecord
    scope :sorted_by_name, -> { order(:name) }

    validates :name, presence: true
    validates :body, presence: true
    validates :subject, presence: true
  end
end
