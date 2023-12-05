# frozen_string_literal: true

Decidim::EmailNotificationGenerator.class_eval do
  # Overwritten
  # Remove check user.email_on_notification after comment was hide by admin
  def send_email_to(recipient, user_role:)
    return unless recipient
    # return unless recipient.email_on_notification?
    # Chcę otrzymywać powiadomienia na mój adres e-mail o nowych komentarzach pod moimi projektami i w wątkach, w których brałem udział.
    return unless recipient.inform_me_about_comments?
    return if resource.respond_to?(:can_participate?) && !resource.can_participate?(recipient)

    Decidim::NotificationMailer
      .event_received(
        event,
        event_class.name,
        resource,
        recipient,
        user_role.to_s,
        extra
      )
      .deliver_later
  end
end