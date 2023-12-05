# frozen_string_literal: true

Decidim::UserConversationCell.class_eval do
  def interlocutors_names
    return username_list(interlocutors) unless interlocutors.count == 1

    "<strong>#{interlocutors.first.public_name(false)}</strong><br><span class=\"muted\">@#{interlocutors.first.nickname}</span>"
  end
end