# frozen_string_literal: true

Decidim::Messaging::ConversationMailer.class_eval do
  private

  # rubocop:disable Metrics/ParameterLists
  def notification_mail(from:, to:, conversation:, action:, message: nil, third_party: nil)
    return unless to.allow_private_message

    with_user(to) do
      @organization = to.organization
      @conversation = conversation
      @sender = from
      @recipient = to
      @third_party = third_party
      @message = message
      @host = @organization.host

      subject = I18n.t(
        "conversation_mailer.#{action}.subject",
        scope: "decidim.messaging",
        sender: @sender.public_name(true),
        manager: @third_party&.public_name(false),
        group: @third_party&.name
      )

      mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'new_conversation')

      mail(to: to.email, subject: mail_template.subject, body: mail_template.body.html_safe, content_type: "text/html")
    end
  end
end