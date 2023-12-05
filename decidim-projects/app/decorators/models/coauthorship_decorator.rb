# frozen_string_literal: true

# Coauthorsip model allows managing authors for different models.
# For the purposes of new Projects Component, new methods were added.
# confirmation_status:
#  - waiting - after creation, it waiting for send
#  - invited - after invitation was send
#  - confirmed - after confirmation by user
Decidim::Coauthorship.class_eval do

  scope :confirmed,      -> { where(confirmation_status: 'confirmed') }
  scope :for_acceptance, -> { where.not(confirmation_status: 'confirmed') }
  scope :for_invitation, -> { where(confirmation_status: 'waiting') }
  scope :already_invited,-> { where.not(confirmation_status: 'waiting') } # all after invitation was send with all confirmed
  scope :for_all_users,  -> { where(decidim_author_type: ["Decidim::UserBaseEntity", "Decidim::Projects::SimpleUser"]) }
  scope :for_decidim_users, -> { where(decidim_author_type: 'Decidim::UserBaseEntity') }
  scope :with_coauthors, -> { where(coauthor: true) }

  # Mark coauthorship after confirmation by user
  def confirm
    update_columns(confirmation_status: 'confirmed', coauthorship_acceptance_date: Date.current)
  end

  # Mark coauthorship after invitation was send
  def mark_invited
    update_columns(confirmation_status: 'invited')
  end

  # Public: checks if user can still accept coauthorship of a project
  #
  # returns Boolean
  def in_acceptance_time?
    if coauthorship_acceptance_date.present?
      DateTime.current <= coauthorship_acceptance_date
    elsif project
      project.within_publication_time?
    else
      false
    end
  end

  # Public: project of given coauthorable
  #
  # Syntactic sugar method, that returns coauthorable if it is
  # and instance of Decidim::Projects::Project
  #
  # returns object - Decidim::Projects::Project
  def project
    coauthorable if coauthorable_type == "Decidim::Projects::Project"
  end

  private

  # Overwritten
  # Project's author should not observe his own project
  def author_is_follower
    return unless author.is_a?(Decidim::User)
    return unless coauthorable.is_a?(Decidim::Followable)
    return if coauthorable.is_a?(Decidim::Projects::Project)

    Decidim::Follow.find_or_create_by!(followable: coauthorable, user: author)
  end
end
