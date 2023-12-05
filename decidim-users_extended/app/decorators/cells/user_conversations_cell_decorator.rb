# frozen_string_literal: true

Decidim::UserConversationsCell.class_eval do
  def conversation_interlocutors(conversation)
    return username_list(conversation.interlocutors(user), shorten: true) unless conversation.interlocutors(user).count == 1

    "#{conversation.interlocutors(user).first.public_name(false)} <span class=\"muted\">@#{conversation.interlocutors(user).first.nickname}</span>"
  end
end