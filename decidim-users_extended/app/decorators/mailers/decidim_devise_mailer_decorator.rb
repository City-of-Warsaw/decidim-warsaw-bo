# frozen_string_literal: true

Decidim::DecidimDeviseMailer.class_eval do

  def invitation_instructions(user, token, opts = {})
    mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'activation_email_template')

    if mail_template
      Decidim::UsersExtended::TemplatedMailerJob.perform_later(user, mail_template, token)
    else
      # in case there is no template
      with_user(user) do
        @token = token
        @organization = user.organization
        @opts = opts

        opts[:subject] = I18n.t("devise.mailer.#{opts[:invitation_instructions]}.subject", organization: user.organization.name) if opts[:invitation_instructions]
      end

      devise_mail(user, opts[:invitation_instructions] || :invitation_instructions, opts)
    end
  end

  def confirmation_instructions(record, token, opts = {})
    mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'activation_email_template')

    initialize_from_record(record) # sets a resource
    user = Decidim::User.find_by(email: @resource&.email)

    if user && mail_template
      Decidim::UsersExtended::TemplatedMailerJob.perform_later(user, mail_template, token)
    else
      # in case there is no template
      @token = token
      devise_mail(record, :confirmation_instructions, opts)
    end
  end

  def reset_password_instructions(record, token, opts = {})
    mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'password_change_email_template')

    initialize_from_record(record) # sets a resource
    user = Decidim::User.find_by(email: @resource&.email)
    if user && mail_template
      Decidim::UsersExtended::TemplatedMailerJob.perform_later(user, mail_template, token)
    else
      @token = token
      devise_mail(record, :reset_password_instructions, opts)
    end
  end
end