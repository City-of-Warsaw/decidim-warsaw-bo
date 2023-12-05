# frozen_string_literal: true

class OldModels::User
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :firstName, String
  attribute :lastName, String
  attribute :sex, String
  attribute :email, String
  attribute :phone, String
  attribute :street, String
  attribute :homeNo, String
  attribute :flatNo, String
  attribute :postCode, String
  attribute :city, String
  attribute :status, String
  attribute :officeId, String
  attribute :unitId, String
  attribute :endActivationDate, Date
  attribute :registrationDataAgree, Boolean
  attribute :namePublicDataAgree, Boolean

  attribute :newsletterRealizationAcceptance, Boolean
  attribute :newsletterRealization2021Acceptance, Boolean
  attribute :newsletterRealization2022Acceptance, Boolean
  attribute :newsletterEvaluation2022, Boolean
  attribute :region, [String]
  attribute :role, [String]
  attribute :displayName, String

  def simple_user?
    email.blank? || ["***", "502824825", "503677898", "-", "606785755", "matmieciek", 'nie posiadam', "Nie posiadam", "brak", "537489363"].include?(email)
  end

  def nickname
    nick = displayName.gsub(' ','').gsub('ł','l').gsub('Ł','L').gsub('ń','n').gsub('ś','s').
      gsub('ą','a').gsub('ę','e').gsub('ż','z').gsub('Ż','Z').gsub('Ń','N').
      gsub('Ś','S').gsub('ź','z').gsub('ó','o').gsub('.','').gsub('ć','c').gsub('-','').gsub('(','').gsub(')','')
    "#{nick.first(5)}#{rand(Time.current.to_i)}".first(20)
  end

  def generate_anonymous_number
    rand(Time.current.to_i)
  end

  def generate_password
    @pass ||= SecureRandom.hex 16
  end

  def fixed_name
    name.gsub('@','').gsub('&','').gsub('|','').gsub('=','').gsub('#','').gsub('*','').gsub('^','').
      gsub('(','').gsub(')','').gsub('[','').gsub(']','').gsub('<','').gsub('>','').gsub('+','').
      gsub('%','').gsub(':','').gsub('"','').gsub('?','').gsub('\\','').presence || "name#{Time.current.to_i}"
  end

  def fixed_email
    em = case email
         when "oliver@zdanowicz@eu" then "oliver@zdanowicz.eu"
         when "marcel.buczek@716@gmail.com" then "marcel.buczek716@gmail.com"
         when "bp24@bppragapd.pl paolamaria@wp.pl" then "bp24@bppragapd.pl"
         when "kubalonik356@gmail.com ; psmolak@poczta.wp.pl" then "kubalonik356@gmail.com"
         when "kasia_nowak@12@wp.pl" then "kasia_nowak12@wp.pl"
         when "b.f.k.@interia .pl" then "b.f.k.@interia.pl"
         when "jjedrych@ccpg@com.pl" then "jjedrychccpg@com.pl"
         when "wozawadzki@um. warszawa.pl" then "wozawadzki@um.warszawa.pl"
         when "paolamaria@wp.pl ; bp24@bppragapd.pl" then "paolamaria@wp.pl"
         when "mitekj@interia.pl, m.jedrusik@lopuszanska36.com.pl " then "mitekj@interia.pl"
         when "agata.tomala@neostrada.pl, lawenda64@op.pl" then "agata.tomala@neostrada.pl"
         when "fenix.warszawa @op.pl" then "fenix.warszawa@op.pl"
         when "djstrazakggmail.com" then "djstrazak@gmail.com"
         when "odz@bibliotekawawer.pl    jolakom9@wp.pl" then "odz@bibliotekawawer.pl"
         when "d.szymanski@gim142.pl    lukikicak@wp.pl" then "d.szymanski@gim142.pl"
         when "m.dyjas72gmail.com" then "m.dyjas72@gmail.com"
         when "anna.jablonska.8@gmail.com " then "anna.jablonska.8@gmail.com"
         when "diagram.janolszewski.com" then "diagram.janolszewski@gmail.com"
         when "jolakom(@wp.pl,odz@bibliotekawawer.pl" then "jolakom9@wp.pl"
         else
           email.gsub(' ','').split(',').first.split(';').first
         end
    em.rstrip.lstrip.downcase
  end

  def get_gender
    return if displayName.blank?

    if displayName == "Mieszkanka"
      'female'
    elsif displayName == "Mieszkaniec"
      'male'
    end
  end

  def build_user(organization)
    Decidim::User.new(
      tos_agreement: true,

      old_id: id,
      email: fixed_email,
      name: fixed_name,

      nickname: "user-#{id}",
      display_name: displayName,
      first_name: firstName,
      last_name: lastName,
      password: generate_password,
      password_confirmation: generate_password,
      organization: organization,
      locale: 'pl',
      gender: get_gender,
      inform_me_about_proposal: newsletterRealization2022Acceptance,
      email_on_notification: newsletterEvaluation2022,

      phone_number: phone,
      street: street,
      street_number: homeNo,
      flat_number: flatNo,
      zip_code: postCode,
      city: city,
      anonymous_number: generate_anonymous_number,

      skip_invitation: true,
      confirmed_at: Time.current
    )
  end

  def build_simple_user(organization)
    Decidim::Projects::SimpleUser.new(
      old_id: id,
      organization: organization,

      first_name: firstName,
      last_name: lastName,

      phone_number: phone,
      street: street,
      street_number: homeNo,
      flat_number: flatNo,
      zip_code: postCode,
      city: city,
      anonymous_number: generate_anonymous_number,

      # agreements
      show_my_name: false,
      inform_me_about_proposal: false,
      email_on_notification: false
      )
  end
end
