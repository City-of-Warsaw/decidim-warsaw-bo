module Decidim
  module UsersExtended
    class ApplicationMailer < Decidim::ApplicationMailer

      def notify_from_template(user, mail_template, token=nil)
        @mail_template_body = mail_template.body
        @user = user
        @organization = @user.organization
        organization_link = decidim.root_url(host: @organization.host)
        # shared
        activation_link = decidim.user_confirmation_url(confirmation_token: token, host: "https://#{@organization.host}")
        registration_link = decidim.new_user_registration_url(host: "https://#{@organization.host}")
        password_reset_link = decidim.edit_user_password_url(reset_password_token: token, host: "https://#{@organization.host}")
        @body = @mail_template_body.gsub('%{user_name}', @user.public_name(true))
                     .gsub('%{organization_name}', @organization.name)
                     .gsub('%{organization_link}', organization_link)
                     .gsub('%{activation_link}', activation_link)
                     .gsub('%{registration_link}', registration_link)
                     .gsub('%{password_reset_link}', password_reset_link)

        mail(to: @user.email, subject: mail_template.subject)
      end
    end
  end
end
