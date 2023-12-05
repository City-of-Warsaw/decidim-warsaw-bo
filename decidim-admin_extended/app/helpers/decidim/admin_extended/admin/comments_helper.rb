# frozen_string_literal: true

module Decidim::AdminExtended
  # Custom helpers for banned words
  module Admin::CommentsHelper
    def applied_params_hash
      params.permit(q:[:body_cont], comment_search:[:start_date,:end_date]).to_h.deep_symbolize_keys
    end
  end
end
