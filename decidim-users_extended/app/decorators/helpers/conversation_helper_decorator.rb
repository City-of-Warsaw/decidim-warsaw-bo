# frozen_string_literal: true

Decidim::Messaging::ConversationHelper.class_eval do
  def username_list(users, shorten: false)
    return users.map { |u| u.public_name(false) }.join(", ") unless shorten
    return users.map { |u| u.public_name(false) }.join(", ") unless users.count > 3

    "#{users.first(3).map { |u| u.public_name(false) }.join(", ")} + #{users.count - 3}"
  end
end