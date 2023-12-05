# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A form object to create or update banned words.
    class StatisticForm < Form
      attribute :scope_type, Array
      attribute :edition_year, Array, default: Decidim::ParticipatoryProcess.actual_edition.edition_year
      attribute :scope_id, Array

      def default_participatory
        Decidim::ParticipatoryProcess.actual_edition
      end

      def default_scope
        Decidim::Scope.find_by(code: 'om')
      end

      def districts_scope_ids
        Decidim::Scope.where.not(code: 'om').pluck(:id)
      end

      def scope_collection
        return Array.wrap(default_scope.id) if scope_type.empty?

        if (%w[1 2] & scope_type).size == 2 && scope_id.empty?
          districts_scope_ids + [default_scope.id]
        elsif (%w[1 2] & scope_type).size == 2 && scope_id.present?
          [default_scope.id] + scope_id
        elsif scope_type.include?('1') && scope_id.present?
          scope_id
        elsif scope_type.include?('1') && scope_id.empty?
          districts_scope_ids
        elsif scope_type.include?('2')
          Array.wrap(default_scope.id)
        end
      end
    end
  end
end
