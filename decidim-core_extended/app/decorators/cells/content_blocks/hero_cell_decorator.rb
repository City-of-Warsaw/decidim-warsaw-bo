# frozen_string_literal: true

Decidim::ContentBlocks::HeroCell.class_eval do
  include ApplicationHelper

  def show
    render :show_new
  end

  private

  def cta_button_new
    return '' unless cta_button_path.present?

    link_to button_text, cta_button_path, class: "hero-cta button expanded large button--sc"
  end

  def cta_button_path
    path_for_new_project.presence || path_for_voting_start.presence || path_for_voting_results
  end

  def button_text
    active_step = newest_edition.active_step.presence || newest_edition.steps.first
    translated_text = translated_attribute(newest_edition&.active_step&.cta_text)

    if translated_text.present?
      translated_text
    elsif projects_component && projects_component.step_settings["#{active_step&.id}"]&.creation_enabled?
      'ZGŁOŚ PROJEKT'
    elsif projects_component && projects_component.step_settings["#{active_step&.id}"]&.voting_enabled?
      'ZAGŁOSUJ'
    else
      # To tylko domyslne dla etapu wynikow
      'WYNIKI GŁOSOWANIA'
    end
  end

  def newest_edition_dates
    return '' unless newest_edition

    # set active or first step in newest edition
    step = newest_edition.active_step.presence || newest_edition.steps.first
    return '' unless step
    return '' if step.start_date.blank? || step.end_date.blank?


    "#{fomat_date(step.start_date)} - #{fomat_date(step.end_date)}"
  end

  def newest_edition
    Current.actual_edition
  end

  def fomat_date(date)
    l date, format: "%-d %B %Y"
  end

  def cache_hash
    # hash = []
    # hash << "decidim/content_blocks/hero"
    # hash << Digest::MD5.hexdigest(model.attributes.to_s) # content block version
    # hash << current_organization.cache_key_with_version # organization "#{cache_key = "#{model_name.cache_key}/#{id}"}-#{version = organization.created_at.utc.to_s(:usec) }"
    # hash << I18n.locale.to_s
    #
    # hash.join("/")
    # it returns: "decidim/content_blocks/hero/1a756a44fade20f57884ffb09bef4f80/decidim/organizations/1-20220407082438002142/pl"
    # nil
    hash = []
    hash << "decidim/content_blocks/hero"
    hash << Digest::MD5.hexdigest(model.attributes.to_s) # for cache translated_welcome_text
    hash << Digest::MD5.hexdigest(Current.organization.updated_at.to_s)
    hash << Digest::MD5.hexdigest(newest_edition_dates)
    hash << Digest::MD5.hexdigest(cta_button_path)
    hash << Digest::MD5.hexdigest(button_text)
    hash << Digest::MD5.hexdigest(newest_edition.show_start_voting_button_at.to_s)
    hash << Digest::MD5.hexdigest(newest_edition.show_voting_results_button_at.to_s)
    hash.join("/")
  end
end
