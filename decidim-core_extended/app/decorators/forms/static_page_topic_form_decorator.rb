# frozen_string_literal: true

Decidim::Admin::StaticPageTopicForm.class_eval do
  attribute :scroll_template, GraphQL::Types::Boolean
  attribute :template, String
end