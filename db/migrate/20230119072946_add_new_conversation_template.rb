class AddNewConversationTemplate < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up { Decidim::AdminExtended::MailTemplatesGenerator.new.create_template(:new_conversation) }
    end
  end
end
