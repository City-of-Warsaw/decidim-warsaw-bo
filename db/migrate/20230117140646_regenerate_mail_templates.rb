class RegenerateMailTemplates < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up { Decidim::AdminExtended::MailTemplatesGenerator.new.load(overwrite_all: true) }
    end
  end
end
