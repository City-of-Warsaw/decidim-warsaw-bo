# frozen_string_literal: true

#
# A class used to find the recipients of the
# Newsletter depending on the params of the form

Decidim::Admin::NewsletterRecipients.class_eval do
  def query
    return Decidim::User.none if @form.send_to_file

    recipients = Decidim::User.where(organization: @form.current_organization)
                              .where.not(email: nil, confirmed_at: nil)
                              .not_deleted

    if @form.send_to_all_users?
      recipients = recipients.where(newsletter: true)
    end

    if @form.internal_user_roles.any?
      recipients = recipients.verificators if @form.internal_user_roles.include?('weryf')
      recipients = recipients.sub_coordinators if @form.internal_user_roles.include?('podkoord')
      recipients = recipients.coordinators if @form.internal_user_roles.include?('koord')
      recipients = recipients.editors if @form.internal_user_roles.include?('edytor')
    end

    if @form.send_users_with_agreement_of_evaluation?
      recipients = recipients.where(email_on_notification: true)
    end

    if (@form.send_to_authors? || @form.send_to_coauthors?) && spaces.any?
      if @form.send_to_authors? && @form.send_to_coauthors?
        recipients = recipients.where(id: (project_authors + project_coauthors))
      elsif @form.send_to_authors?
        recipients = recipients.where(id: project_authors)
      elsif @form.send_to_coauthors?
        recipients = recipients.where(id: project_coauthors)
      end
    elsif (@form.send_to_authors? || @form.send_to_coauthors?) && spaces.empty?
      recipients = Decidim::User.none
    end

    recipients
  end

  private

  # Return the ids of the ParticipatorySpace selected
  # in form, grouped by type
  # This will be used to take followers and
  # participants of each ParticipatorySpace
  def spaces
    return if @form.participatory_space_types.blank?

    @spaces ||= @form.participatory_space_types.map do |type|
      next if type.ids.blank?

      object_class = "Decidim::#{type.manifest_name.classify}"
      if type.ids.include?('all')
        object_class.constantize.where(organization: @organization)
      else
        object_class.constantize.where(id: type.ids.reject(&:blank?))
      end
    end.flatten.compact
  end

  def project_authors
    return unless @form.send_to_authors?
    return if spaces.blank?

    authors_ids = spaces.map do |participatory_process|
      project_list = Decidim::Projects::Project.where(decidim_component_id: participatory_process.projects_component.id)
      project_list = project_list.where(state: @form.project_status) if @form.project_status.reject(&:empty?).any?
      Decidim::Coauthorship.where(coauthor: false, coauthorable_type: 'Decidim::Projects::Project', coauthorable_id: project_list.pluck(:id)).pluck(:decidim_author_id)
    end
    authors_ids.flatten.uniq
  end

  def project_coauthors
    return unless @form.send_to_coauthors?
    return if spaces.blank?

    authors_ids = spaces.map do |participatory_process|
      projects_list = Decidim::Projects::Project.where(decidim_component_id: participatory_process.projects_component.id)
      projects_list = projects_list.where(state: @form.project_status) if @form.project_status.reject(&:empty?).any?
      Decidim::Coauthorship.where(coauthor: true,
                                  coauthorable_type: 'Decidim::Projects::Project',
                                  confirmation_status: 'confirmed',
                                  coauthorable_id: projects_list.pluck(:id))
                           .pluck(:decidim_author_id)
    end
    authors_ids.flatten.uniq
  end

  # Return the ids of Users that are following
  # the spaces selected in form
  def user_id_of_followers
    return if spaces.blank?
    return unless @form.send_to_followers

    Decidim::Follow.user_follower_ids_for_participatory_spaces(spaces)
  end

  # Return the ids of Users that have participate
  # the spaces selected in form
  def participant_ids
    return if spaces.blank?
    return unless @form.send_to_participants

    participant_ids = []
    spaces.each do |space|
      next unless defined? space.component_ids

      available_components = Decidim.component_manifests.map do |m|
        m.name.to_s if m.newsletter_participant_entities.present?
      end .compact
      Decidim::Component.where(id: space.component_ids, manifest_name: available_components).published.each do |component|
        Decidim.find_component_manifest(component.manifest_name).try(&:newsletter_participant_entities).flatten.each do |object|
          klass = Object.const_get(object)
          participant_ids |= klass.newsletter_participant_ids(component)
        end
      end
    end

    participant_ids.flatten.compact.uniq
  end
end
