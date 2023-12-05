# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to holding all shared methods for Each step Vote Wizard Form
    class WizardVoteForm < Decidim::Form
      GLOBAL_SCOPE_ID = Decidim::Scope.find_by(code: 'om').id

      mimic :vote_card

      attribute :scope, Decidim::Scope
      attribute :scope_id, Integer
      attribute :status, String

      attribute :global_projects
      attribute :district_projects

      attribute :first_name, String
      attribute :last_name, String
      attribute :email, String
      attribute :street, String
      attribute :street_number, String
      attribute :flat_number, String
      attribute :zip_code, String
      attribute :city, String
      attribute :pesel_number, String
      attribute :pesel_number_confirmation, String

      # editor fields
      attribute :identity_confirmed, GraphQL::Types::Boolean
      attribute :card_signed, GraphQL::Types::Boolean
      attribute :data_unreadable, GraphQL::Types::Boolean
      attribute :card_invalid, GraphQL::Types::Boolean
      attribute :card_received_late, GraphQL::Types::Boolean
      attribute :pesel_warnings, Hash

      # fields to filter
      attribute :search_text, String
      attribute :category, Integer
      attribute :potential_recipient, Integer

      attribute :vote_validity_service
      attribute :global_scope_projects_voting_limit
      attribute :district_scope_projects_voting_limit
      attribute :district_scope_projects_voting_limit
      attribute :projects_in_global_scope, Hash
      attribute :projects_in_districts_scope, Hash

      validate :scope_id_is_in_scope_districts_range, if: proc { |attrs| attrs[:scope_id].present? }

      def scope_id_is_in_scope_districts_range
        errors.add(:scope_id, 'Wystąpił błąd podczas wyboru dzielnicy') unless available_district_scopes_ids.include?(scope_id)
      end

      def map_model(model)
        super

        self.projects_in_global_scope = model.projects.in_global_scope.pluck(:id)
        self.projects_in_districts_scope = model.projects.in_district_scope.pluck(:id)
        self.pesel_number_confirmation = model.pesel_number
        self.global_projects = model.projects.in_global_scope.pluck(:id).join(',')
        self.district_projects = model.projects.in_district_scope.pluck(:id).join(',')

        self.vote_validity_service = Decidim::Projects::VoteCardValidityService.new(model)
      end

      def component
        current_component
      end

      def global_scope_projects_voting_limit
        current_component.participatory_space.global_scope_projects_voting_limit
      end

      def district_scope_projects_voting_limit
        current_component.participatory_space.district_scope_projects_voting_limit
      end

      def district_projects_ids
        district_projects.is_a?(Array) ? district_projects.first.split(',') : district_projects.split(',')
      end

      def global_projects_ids
        global_projects.is_a?(Array) ? global_projects.first.split(',') : global_projects.split(',')
      end

      # Public method for showing initial view of district projects list with no scope chosen
      def no_projects
        Decidim::Projects::Project.none
      end

      def listed_global_projects
        @listed_global_projects ||= projects_for_voting.in_global_scope
      end

      def all_listed_district_projects
        @all_listed_district_projects ||= projects_for_voting.in_district_scope
      end

      def listed_district_projects(scope_id)
        return no_projects if scope_id.blank?

        projects_for_voting.where(decidim_scope_id: scope_id)
      end

      def vote_validity_service
        Decidim::Projects::VoteCardValidityService.new(self)
      end

      private

      def available_district_scopes
        @available_district_scopes ||= Decidim::Projects::DistrictScopes.new.query
      end

      def available_district_scopes_ids
        available_district_scopes.pluck(:id)
      end

      def projects_for_voting
        @projects_for_voting ||= Decidim::Projects::ProjectsForVoting.new(current_component).query.order(voting_number: :asc)
      end
    end
  end
end
