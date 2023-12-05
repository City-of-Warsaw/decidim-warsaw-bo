# frozen_string_literal: true

module Decidim::Projects
  # SimpleUser is used to authors and coauthors when Project is added in Admin Panel,
  # and autors/coauthors didn't provide email address on their project form
  class SimpleUser < ApplicationRecord
    include Decidim::ActsAsAuthor

    belongs_to :organization

    # Returns the presenter for this author, to be used in the views.
    # Required by ActsAsAuthor.
    def presenter
      Decidim::Projects::SimpleUserPresenter.new(self)
    end

    # Public: returns proper name - in anonymous or normal form - for the SimpleUser
    # based on the agreements that were put on the project form.
    # Method is used by Decidim::ActAsAuthor based elements.
    #
    # returns String
    def name(with_number = false)
      if show_my_name && (first_name.present? || last_name.present?)
        name_and_surname
      else
        an = with_number ? " #{anonymous_number}" : ''
        if gender.present?
          "#{I18n.t(gender, scope: 'decidim.users.gender', default: I18n.t('decidim.users.gender.male'))}#{an}"
        else
          "Mieszkaniec#{an}"
        end
      end
    end

    # alias public_name name

    # for additional notifications - notify organization admins
    def followers
      Decidim::User.where(organization: organization).where(ad_role: 'admin')
    end

    # for displaying author name in comments thread
    def deleted?
      false
    end

    # Public: does user accept conversations
    # SimpleUsers as they are not used as ones that can log in,
    # can not accept conversations
    #
    # returns: false
    def accepts_conversation?(u)
      false
    end

    # Public: returns proper public_name - in anonymous or normal form - for the SimpleUser
    # based on the agreements that were put on the project form.
    #
    # returns String
    def public_name(with_number = false)
      if show_my_name && (first_name.present? || last_name.present?)
        name_and_surname
      else
        an = with_number ? " #{anonymous_number}" : ''
        if gender.present?
          "#{I18n.t(gender, scope: 'decidim.users.gender', default: I18n.t('decidim.users.gender.male'))}#{an}"
        else
          "Mieszkaniec#{an}"
        end
      end
    end

    # Public: returns user's first and last name
    def name_and_surname
      [first_name.presence, last_name.presence].compact.join(' ')
    end

    def anonymous_name(with_number = false)
      an = with_number ? " #{anonymous_number}" : ''
      if gender.present?
        "#{I18n.t(gender, scope: 'decidim.users.gender', default: I18n.t('decidim.users.gender.male'))}#{an}"
      else
        "Mieszkaniec#{an}"
      end
    end

    # Public: returns user's address
    def address
      "#{street} #{street_number}#{flat_number.present? ? '/' : nil}#{flat_number}, #{zip_code} #{city}"
    end

    # Public: sign in count
    #
    # SimpleUsers can non log in so method always returns 0.
    # Method is used by Decidim::ActAsAuthor based elements.
    #
    # returns Integer
    def sign_in_count
      0
    end

    # Public: return user's nickname
    #
    # SimpleUsers do not have nickname, it is generated from anonymous number.
    # Method is for users export to xls.
    #
    # returns String
    def nickname
      "user-#{anonymous_number}"
    end

    # Public: set notification_types for SimpleUser
    #
    # SimpleUsers do not have notifications
    #
    # returns String
    def notification_types
      "none"
    end
  end
end
