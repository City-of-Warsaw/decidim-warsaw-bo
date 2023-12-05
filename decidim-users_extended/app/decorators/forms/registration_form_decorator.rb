# frozen_string_literal: true

Decidim::RegistrationForm.class_eval do
  attribute :gender
  attribute :first_name
  attribute :last_name

  attribute :rodo

  validates :rodo, allow_nil: false, acceptance: true
  validates :password, presence: true

  validate :password_characters

  def gender_for_select
    Decidim::User::GENDERS.map do |g|
      [
        I18n.t("gender.#{g}", scope: "decidim.users"),
        g
      ]
    end
  end

  def name
    "#{generate_random_number}"
  end

  def nickname
    "user-#{generate_random_number}".first(20)
  end

  def generate_random_number
    rand(Time.current.to_i)
  end

  def password_characters
    return unless password

    errors.add :password, 'Nie spełnia wymienionych warunków' unless correct_password(password)
  end

  def correct_password(pass)
    !!pass.match(/[a-z]/) &&
      !!pass.match(/[A-Z]/) &&
      !!pass.match(/[0-9]/) &&
      !!pass.match(/[!@#$%^&§£*()_,<>'~`\;\/\\\]\[|":;{}=\?\-\+\.?]/)
  end
end
