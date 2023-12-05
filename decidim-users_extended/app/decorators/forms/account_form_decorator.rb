# frozen_string_literal: true

Decidim::AccountForm.class_eval do
  attribute :gender

  attribute :first_name
  attribute :last_name

  # notifications
  attribute :email_on_notification
  attribute :allow_private_message
  attribute :inform_me_about_comments
  attribute :newsletter
  attribute :watched_implementations_updates
  attribute :inform_about_admin_changes

  attribute :street, String
  attribute :street_number, String
  attribute :flat_number, String
  attribute :zip_code, String
  attribute :city, String
  attribute :phone_number, String

  validate :password_characters
  validates :zip_code, format: { with: /\A[0-9]{2}-[0-9]{3}\z/ }, allow_blank: true

  def gender_for_select
    Decidim::User::GENDERS.map do |g|
      [
        I18n.t("gender.#{g}", scope: "decidim.users"),
        g
      ]
    end
  end

  def name
    current_user.name
  end

  def password_characters
    return unless password

    errors.add :password, 'Nie spełnia wymienionych warunków' unless correct_password(password)
  end

  def correct_password(pass)
    !!pass.match(/[a-z]/) && !!pass.match(/[A-Z]/) && !!pass.match(/[0-9]/) && !!pass.match(/[!@#$%^&*()_,<>';\\\]\[|":{}=\-\+\.?]/)
  end
end
