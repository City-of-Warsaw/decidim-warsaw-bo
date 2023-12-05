# frozen_string_literal: true

module Decidim::Projects
  module Admin::ProjectConflictsHelper
    def project_rank_status(project_rank)
      case project_rank.status
      when 'excluded_by_conflict'
        'odrzucony przez konflikt'
      when 'on_the_list'
        'na liście'
      else
        ''
      end
    end
  end
end
