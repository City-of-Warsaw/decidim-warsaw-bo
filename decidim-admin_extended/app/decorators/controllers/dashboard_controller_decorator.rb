# frozen_string_literal: true

# OVERWRITTEN DECIDIM CONTROLLER
# Controller that shows a simple dashboard
Decidim::Admin::DashboardController.class_eval do
  helper_method :applied_params_hash

  private

  def applied_params_hash
    params.permit(log_search: [:start_date, :end_date, :owner_name, :log_action_name]).to_h.deep_symbolize_keys
  end


end
