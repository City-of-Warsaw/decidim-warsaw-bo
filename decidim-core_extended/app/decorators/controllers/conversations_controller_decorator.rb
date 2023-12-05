# frozen_string_literal: true

Decidim::Messaging::ConversationsController.class_eval do
  before_action :recipient_allow_private_message, only: %i[new create]

  private

  def recipient_allow_private_message
    form = form(Decidim::Messaging::ConversationForm).from_params(params, sender: current_user)
    disallow_private_message_names = form.recipient.map { |recipient| recipient.public_name unless recipient.allow_private_message? }.compact
    if disallow_private_message_names.any?
      redirect_to conversations_path, alert: "Użytkownik/nicy #{disallow_private_message_names.join(', ')} nie wyraził/li zgody na wysyłanie wiadomości prywatnych"
    end
  end
end
