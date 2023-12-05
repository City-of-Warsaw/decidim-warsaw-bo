# frozen_string_literal: true

# OVERWRITTEN DECIDIM PRESENTER
# BasePresenter implements shared methods for displaying ActionLogs
# It was expanded with a method that allows to get translation of the log for Exported files
Decidim::Log::BasePresenter.class_eval do
  # Public method for retrieving translation for given ActionLog
  #
  # Returns String
  def translated_action_explanation
    I18n.t(
      action_string,
      i18n_params
    )
  end
end