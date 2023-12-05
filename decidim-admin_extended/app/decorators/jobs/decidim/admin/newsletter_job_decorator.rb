# frozen_string_literal: true

Decidim::Admin::NewsletterJob.class_eval do
  def perform(newsletter, form, recipients_ids)
    @newsletter = newsletter
    @form = form
    @recipients_ids = recipients_ids

    @newsletter.with_lock do
      raise 'Newsletter already sent' if @newsletter.sent?

      @newsletter.update!(
        sent_at: Time.current,
        extended_data: extended_data,
        total_recipients: recipients.count,
        total_deliveries: 0
      )
    end
    @recipients = newsletter.newsletter_recipients_from_file if form['send_to_file']

    recipients.find_each do |user|
       Decidim::Admin::NewsletterDeliveryJob.perform_later(user, @newsletter)
    end
  end

  private

  def extended_data
    {
      send_to_all_users: @form['send_to_all_users'],
      send_to_followers: @form['send_to_followers'],
      internal_user_roles: @form['internal_user_roles'].reject(&:blank?),
      send_to_authors: @form['send_to_authors'],
      send_users_with_agreement_of_evaluation: @form['send_users_with_agreement_of_evaluation'],
      project_status: @form['project_status'].reject(&:blank?),
      send_to_file: @form['send_to_file'],
      send_to_coauthors: @form['send_to_coauthors'],
      send_to_participants: @form['send_to_participants'],
      participatory_space_types: @form['participatory_space_types'],
      scope_ids: @form['scope_ids']
    }
  end
end
