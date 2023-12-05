# frozen_string_literal: true

Decidim::Admin::HideResource.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  # Public: Initializes the command.
  #
  # reportable - A Decidim::Reportable
  # current_user - the user that performs the action
  # admin_action - not required param, if passed it indicates,
  #                that comment is being hidden in admin panel without report
  def initialize(reportable, current_user, admin_action = false)
    @reportable = reportable
    @current_user = current_user
    @admin_action = admin_action
  end

  def call
    return broadcast(:invalid) unless hideable?

    if action_is_performed_by_author? || action_is_performed_by_admin?
      user_hide!
      send_hide_notification_to_author if action_is_performed_by_admin?
    else
      hide!
      send_hide_notification_to_author
    end

    broadcast(:ok, @reportable)
  end

  private

  # Private method that allows hiding resource in special cases even if it was not reported
  #
  # Returns @reportable
  def user_hide!
    create_moderation!
    @reportable.reload
    Decidim.traceability.perform_action!(
      "hide",
      @reportable.moderation,
      @current_user,
      extra: {
        reportable_type: @reportable.class.name
      }
    ) do
      @reportable.moderation.update!(hidden_at: Time.current)
    end
  end

  # Private method determininghideability of the resource.
  # Resource is hideable if it is not yet hidden and
  #   - if it was reported OR
  #   - if method action_is_performed_by_author? returns true OR
  #   - if action_is_performed_by_admin? returns true
  def hideable?
    !@reportable.hidden? &&
      (@reportable.reported? ||
        action_is_performed_by_author? ||
        action_is_performed_by_admin?
      )
  end

  def action_is_performed_by_admin?
    @admin_action == 'admin_hide'
  end

  def action_is_performed_by_author?
    @reportable.is_a?(Decidim::Comments::Comment) && @current_user == @reportable.author && !@reportable.moderation
  end

  def create_moderation!
    moderation = Decidim::Moderation.find_or_create_by!(reportable: @reportable, participatory_space: @reportable.participatory_space)
    moderation.update!(reported_content: @reportable.reported_searchable_content_text)
    report = Decidim::Report.create!(
      moderation: moderation,
      user: @current_user,
      reason: 'spam',
      details: action_is_performed_by_admin? ? 'Ukryty przez administratora' : 'Ukryty przez autora',
      locale: I18n.locale
    )
    report.update_column('reason', @admin_action.presence || 'user_hide') # update to skip validations
    moderation.update!(report_count: moderation.report_count + 1)
  end

  # Overwritten Decidim Method that sets fixed report reasons for comments hidden by author or admin
  #
  # Returns Array of Strings
  def report_reasons
    if action_is_performed_by_author?
      ["user_hide"]
    elsif action_is_performed_by_admin?
      ["admin_hide_reason"]
    else
      @reportable.moderation.reports.pluck(:reason).uniq
    end
  end
end
