# frozen_string_literal: true

Decidim::Component.class_eval do

  def time_for_submitting?
    @time_for_submitting ||= begin
                               active_step = participatory_space.active_step
                               active_step&.active_step? && step_settings["#{active_step.id}"].creation_enabled
                             end
  end

  def time_for_voting?
    @time_for_voting ||= begin
                           active_step = participatory_space.active_step
                           active_step&.active_step? && step_settings["#{active_step.id}"].voting_enabled
                         end
  end
end
