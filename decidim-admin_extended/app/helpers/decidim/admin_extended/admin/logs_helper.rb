# frozen_string_literal: true

module Decidim
  module AdminExtended
    # Custom helpers for logs
    module Admin::LogsHelper
        def applied_params_hash
          params.permit(log_search: %i[start_date end_date owner_name log_action_name]).to_h.deep_symbolize_keys
        end
    end
  end
end
