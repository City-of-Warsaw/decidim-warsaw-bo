module ApplicationHelper
  include Decidim::Projects::ApplicationHelper

  # This method is only for comment code like:
  #  <% comment_code do %>Some stuff that won't be rendered...<% end %>
  def comment_code; end

  def content_class
    if proposals_wizard_view? || projects_wizard_view? || voting_wizard_view?
      'wizard-content'
    elsif full_width_view?
      'full-width-content'
    else
      ''
    end
  end

  def show_no_banner
    proposals_wizard_view? || projects_wizard_view? ||
          proposal_show_view? || project_show_view? ||
          project_version_view? || appeal_view? || project_coauthorship_view? ||
          voting_wizard_view?
  end

  def full_width_view?
    proposal_show_view? || proposal_edit_view? || project_show_view? || project_edit_view? || voting_wizard_view?
  end

  def proposals_wizard_view?
    (controller_name == 'proposals' && @step.present?) || proposal_edit_view?
  end

  def proposal_show_view?
    controller_name == 'proposals' && action_name == 'show'
  end

  def proposal_edit_view?
    controller_name == 'proposals' && (action_name == 'edit' || action_name == 'update' || action_name == 'edit_draft')
  end

  # PROJECTS
  def projects_wizard_view?
    # (controller_name == 'projects' && @step.present?) || project_edit_view? ||
    #   (controller_name == 'projects_wizard' && @step.present?)
    controller_name == 'projects_wizard' || project_edit_view?
  end

  def project_show_view?
    controller_name == 'projects' && action_name == 'show'
  end

  def project_edit_view?
    controller_name == 'projects' && (action_name == 'edit' || action_name == 'update' || action_name == 'edit_draft')
  end

  def project_version_view?
    controller_name == 'versions'
  end

  def appeal_view?
    controller_name == 'appeals'
  end

  def project_coauthorship_view?
    controller_name == 'coauthorships' && action_name.in?(%w[edit update])
  end

  def voting_wizard_view?
    controller_name == 'votes_cards' && (@wizard.present? || action_name == 'publish')
  end

  def path_for_new_project
    return '' unless projects_component
    return '' unless projects_component.time_for_submitting?

    "/processes/#{latest_edition.slug}/f/#{projects_component.id}/projects_wizard/new"
  end

  def path_for_voting_start
    return '' unless projects_component
    return '' unless projects_component.time_for_voting?
    return '' unless projects_component.participatory_space.show_start_voting_button_at < Time.current

    "/processes/#{latest_edition.slug}/f/#{projects_component.id}/votes_cards/new"
  end

  def path_for_voting_results
    return '' unless projects_component
    return '' unless projects_component.participatory_space.show_voting_results_button_at < Time.current
    return '' if projects_component.participatory_space.steps.last.active? # chowamy przycisk dla etapu realizacji

    "/results?filter%5Bedition_year%5D=#{projects_component.participatory_space.edition_year}"
  end

  def time_for_submitting?(projects_component)
    return unless projects_component

    projects_component.time_for_submitting?
  end

  # tylko dla skladania projektow
  def wizard_main_header_info(wizard)
    return unless controller_name == 'projects'
    return unless controller_name == 'projects_wizard'

    proceeding_title = wizard.last_step? ? 'proposal_ended' : 'proposal_proceeding'
    t(proceeding_title, scope: 'layouts.decidim.custom_header')
  end

  def wizard_main_header_cancel_button(wizard)
    return if controller_name == 'votes_cards' && wizard.last_step?
    return if controller_name == 'projects' && wizard.last_step?
    return if controller_name == 'projects_wizard' && wizard.last_step?

    # there can be no current user for voting
    url = current_user ? decidim_core_extended.account_projects_path : '/projects'
    link_to I18n.t("cancel", scope: "layouts.decidim.custom_header"), url, class: "ml-s #{'vote-cancel-js' if controller_name == 'votes_cards'}"
  end

  def latest_edition
    @actual_edition_tmp ||= Decidim::ParticipatoryProcess.published.order('edition_year ASC, published_at ASC').last
  end

  def projects_component
    return unless latest_edition

    if latest_edition
      latest_edition.published_project_component
    else
      nil
    end
  end
end
