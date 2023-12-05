# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A form object to create and update Votes in admin panel.
    class VoteForm < Decidim::Form
      mimic :vote_card

      attribute :component, Decidim::Component
      attribute :decidim_component_id, Integer
      attribute :scope, Decidim::Scope
      attribute :scope_id, Integer
      attribute :status, String

      attribute :global_projects, Array[Integer]
      attribute :district_projects, Array[Integer]

      attribute :first_name, String
      attribute :last_name, String
      attribute :email, String
      attribute :street, String
      attribute :street_number, String
      attribute :flat_number, String
      attribute :zip_code, String
      attribute :city, String
      attribute :pesel_number, String

      # editor fields
      attribute :identity_confirmed, GraphQL::Types::Boolean
      attribute :card_signed, GraphQL::Types::Boolean
      attribute :data_unreadable, GraphQL::Types::Boolean
      attribute :card_invalid, GraphQL::Types::Boolean
      attribute :card_received_late, GraphQL::Types::Boolean
      attribute :pesel_warnings, Hash
      attribute :projects_in_global_scope, Hash
      attribute :projects_in_districts_scope, Hash

      validates :pesel_number, pesel: { pass_with_errors: false }, if: proc { |attrs| attrs[:pesel_number].present? }
      validate :scope_id_is_in_scope_districts_range, if: proc { |attrs| attrs[:scope_id].present? }

      def scope_id_is_in_scope_districts_range
        errors.add(:scope_id, 'Wystąpił błąd podczas wyboru dzielnicy') unless available_district_scopes_ids.include?(scope_id)
      end

      # Public: maps vote fields into FormObject attributes
      def map_model(model)
        super

        self.global_projects = model.projects.in_global_scope.pluck(:id)
        self.projects_in_global_scope = model.projects.in_global_scope.pluck(:id)
        self.projects_in_districts_scope = model.projects.in_district_scope.pluck(:id)
        self.district_projects = model.projects.in_district_scope.pluck(:id)
        self.pesel_warnings = model.pesel_warnings
        self.component = model.component
      end

      def organization
        component.organization
      end

      alias_method :component, :current_component

      def global_scope_projects_for_select
        projects_for_voting.in_global_scope.map do |project|
          ["#{project.voting_number} - #{project.title}", project.id]
        end
      end

      def district_scope_projects_for_select(scope)
        if available_district_scopes.include?(scope)
          projects_for_voting.where(decidim_scope_id: scope.id).map do |project|
            ["#{project.voting_number} - #{project.title}", project.id]
          end
        else
          []
        end
      end

      def scopes_for_select
        available_district_scopes.map do |scope|
          [scope.name["pl"], scope.id]
        end
      end

      def all_picked_projects
        Decidim::Projects::Project.where(id: global_projects + district_projects)
      end

      def scope
        available_district_scopes.find_by(id: scope_id)
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
