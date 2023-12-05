module Decidim
  module CoreExtended
    class Note < ApplicationRecord
      belongs_to :user,
                 foreign_key: :user_id,
                 class_name: "Decidim::User"

      scope :sorted_by_title, -> { order(:title) }

      validates :title, presence: true
      validates :body, presence: true
    end
  end
end
