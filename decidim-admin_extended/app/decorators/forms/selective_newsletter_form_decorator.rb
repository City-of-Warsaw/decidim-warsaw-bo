# frozen_string_literal: true

Decidim::Admin::SelectiveNewsletterForm.class_eval do
  mimic :newsletter
  clear_validators!

  attribute :participatory_space_types, Array[Decidim::Admin::SelectiveNewsletterParticipatorySpaceTypeForm]
  attribute :scope_ids, Array
  attribute :send_to_all_users, Virtus::Attribute::Boolean
  attribute :send_to_participants
  attribute :send_to_followers
  # new attributes
  attribute :send_to_file, Virtus::Attribute::Boolean
  attribute :file_with_recipients

  attribute :send_to_authors, Virtus::Attribute::Boolean
  attribute :send_users_with_agreement_of_evaluation, Virtus::Attribute::Boolean
  attribute :send_to_coauthors, Virtus::Attribute::Boolean
  attribute :internal_user_roles, Array
  attribute :project_status, Array

  validate :at_least_one_type_selected
  validate :at_least_one_participatory_space_selected
  validates :file_with_recipients, presence: true, if: ->(form) { form.send_to_file }

  validate :acceptable_file_with_recipients

  def acceptable_file_with_recipients
    return unless send_to_file

    unless file_with_recipients.size.bytes <= 50.megabyte
      errors.add(:file_with_recipients, "Maksymalny rozmiar pliku to 50MB")
    end

    acceptable_types = ["application/excel", "application/vnd.ms-excel", "application/vnd.msexcel","application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]
    unless acceptable_types.include?(file_with_recipients.content_type)
      errors.add(:file_with_recipients, "Dozwolne rozszerzenia plików: xlsx")
    end
  end

  def map_model(_newsletter)
    self.participatory_space_types = Decidim.participatory_space_manifests.map do |manifest|
      Decidim::Admin::SelectiveNewsletterParticipatorySpaceTypeForm.from_model(manifest: manifest)
    end
  end

  # Make sure the empty scope is not passed because then some logic could
  # assume erroneously that some scope is selected.
  def scope_ids
    super.select(&:presence)
  end

  def at_least_one_type_selected
    return if send_to_all_users || send_users_with_agreement_of_evaluation || send_to_authors || send_to_coauthors || send_to_file || internal_user_roles.any?

    errors.add(:base, 'Musisz wybrać przynajmniej jeden typ odbiorców')
  end

  def available_internal_user_roles
    [
      %w[koord Koordynatorzy],
      %w[podkoord Podkoordynatorzy],
      %w[weryf Weryfikatorzy],
      %w[edytor Edytorzy]
    ]
  end

  private

  def at_least_one_participatory_space_selected
    if (send_to_authors || send_to_coauthors) && current_user.ad_admin?

      errors.add(:base, 'Musisz wybrać edycję') if spaces_selected.blank?
    end
  end

  def spaces_selected
    participatory_space_types.map do |type|
      spaces = type.ids.reject(&:empty?)
      [type.manifest_name, spaces] if spaces.present?
    end.compact
  end
end
