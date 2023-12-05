# frozen_string_literal: true
require 'obscenity/active_model'

Decidim::Comments::CommentForm.class_eval do
  validates :body, obscenity: { message: "Nie może zawierać wulgaryzmów" }
end
