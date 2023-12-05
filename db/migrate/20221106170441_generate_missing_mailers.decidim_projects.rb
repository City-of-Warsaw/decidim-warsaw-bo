# This migration comes from decidim_projects (originally 20221106170311)
class GenerateMissingMailers < ActiveRecord::Migration[5.2]
  def change
    Decidim::AdminExtended::MailTemplatesGenerator.new.load
  end
end
