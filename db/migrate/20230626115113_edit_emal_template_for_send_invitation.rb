class EditEmalTemplateForSendInvitation < ActiveRecord::Migration[5.2]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:resend_invitation_for_voting)
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:invitation_for_voting)
    Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:thank_you_for_voting)
  end
end
