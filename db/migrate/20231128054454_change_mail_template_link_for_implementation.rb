class ChangeMailTemplateLinkForImplementation < ActiveRecord::Migration[5.2]
  def up
    mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'implementation_status_changed_author_info_email_template')
    body = mail_template.body
    body = body.gsub('project_link', 'project_public_url')
    mail_template.update(body: body)
  end

  def down
  end
end
