# frozen_string_literal: true

#
# OVERWRITTEN DECIDIM MODEL

# Model was expanded with:
# - has_one association with email from file recipients

Decidim::Newsletter.class_eval do
  has_many :newsletter_recipients_from_file,
           class_name: 'Decidim::AdminExtended::NewsletterRecipientsFromFile',
           foreign_key: 'newsletter_id',
           dependent: :destroy

  def sended_to_authors?
    extended_data['send_to_authors']
  end

  def sended_to_coauthors?
    extended_data['send_to_coauthors']
  end

  def sended_to_file?
    extended_data['send_to_file']
  end

  def sended_to_internal?
    !extended_data['internal_user_roles'].nil? && extended_data['internal_user_roles'].any?
  end

  def sended_to_users_with_agreement_of_evaluation?
    extended_data['send_users_with_agreement_of_evaluation']
  end

  def name_of_internal_user_roles
    return unless sended_to_internal?

    role_types = { 'koord' => 'koordynatorzy',
                    'podkoord' => 'podkoordynatorzy',
                    'weryf' => 'weryfikatorzy',
                    'edytor' => 'edytorzy' }

    extended_data['internal_user_roles'].map { |role| role_types[role] }.join(',')
  end
end
