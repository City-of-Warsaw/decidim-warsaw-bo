# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Common logic to paginate projects
  module Projects
    module Paginable
      extend ActiveSupport::Concern

      OPTIONS = [30, 60, 90, 120].freeze

      included do
        helper_method :per_page, :page_offset, :per_page_options
        helper Decidim::PaginateHelper

        def paginate(resources)
          resources.page(params[:page]).per(per_page)
        end

        def per_page
          return OPTIONS.first unless params[:filter]

          if OPTIONS.include?(params[:filter][:per_page])
            params[:filter][:per_page]
          elsif params[:filter][:per_page]
            sorted = OPTIONS.sort
            params[:filter][:per_page].to_i.clamp(sorted.first, sorted.last)
          else
            OPTIONS.first
          end
        end

        def page_offset
          [params[:page].to_i - 1, 0].max * per_page
        end

        def per_page_options
          OPTIONS
        end
      end
    end
  end
end
