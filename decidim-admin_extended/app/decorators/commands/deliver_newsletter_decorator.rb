# frozen_string_literal: true

# Delivers the newsletter to its recipients.
Decidim::Admin::DeliverNewsletter.class_eval do
  # OVERWRITTEN DECIDIM METHOD
  # changed permission for sending newsletter:
  # only user with ad_admin permission is allowed to send newsletter to all users
  def call
    @newsletter.with_lock do
      return broadcast(:invalid) if @form.send_to_all_users && !@user.ad_admin? # overwritten line
      return broadcast(:invalid) unless @form.valid?

      return broadcast(:invalid) if @newsletter.sent?
      return broadcast(:no_recipients) if recipients.blank? && !@form.send_to_file

      if @form.send_to_file
        return broadcast(:invalid_email_recipients) if parse_file_to_send(@form.file_with_recipients)

        @recipients = @newsletter.newsletter_recipients_from_file
      end

      send_newsletter!
    end

    broadcast(:ok, @newsletter)
  end

  private

  def parse_file_to_send(file)
    creek = Creek::Book.new file.path
    sheet = creek.sheets[0]
    transaction do
      sheet.simple_rows.each_with_index do |row, index|
        next if index.zero? || row['A'].blank?

        file_recipient_form = Decidim::AdminExtended::Admin::FileRecipientForm.new(row)
        if file_recipient_form.valid?
          Decidim::AdminExtended::NewsletterRecipientsFromFile.create(organization: current_organization,
                                                                      email: file_recipient_form.email,
                                                                      name: file_recipient_form.email,
                                                                      newsletter: @newsletter)
        else
          return true
        end
      end
    end
  end
end
