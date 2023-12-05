class UpdateMailTemplates < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:project_assigned_for_management_email_template)
        Decidim::AdminExtended::MailTemplatesGenerator.new.update_template(:project_assigned_for_verification_email_template)
        Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:meritorical_finished)
      end
    end
  end
end
