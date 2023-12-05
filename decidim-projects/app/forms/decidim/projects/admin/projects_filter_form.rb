# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Project in admin panel.
      class ProjectsFilterForm < Form
        attribute :states, Array[String]
        attribute :project_conflict_ids, Array[String]
        attribute :verification_statuses, Array[String]
        attribute :scope_type_ids, Array[Integer]
        attribute :scope_ids, Array[Integer]
        attribute :categories_ids, Array[Integer]
        attribute :recipients_ids, Array[Integer]
        attribute :user_ids, Array[Integer]
        attribute :is_paper, Array[Boolean]
        attribute :q

        validate :states_is_in_available_states_range, if: proc { |attrs| attrs[:states].present? }
        validate :scope_ids_is_in_scope_districts_range, if: proc { |attrs| attrs[:scope_ids].present? }
        validate :scope_type_ids_is_in_available_scopes_range, if: proc { |attrs| attrs[:scope_ids].present? }
        validate :verification_status_is_in_available_verification_status_range, if: proc { |attrs| attrs[:verification_statuses].present? }
        validate :categories_ids_is_in_available_categories_range, if: proc { |attrs| attrs[:categories_ids].present? }
        validate :recipients_ids_is_in_available_recipients_range, if: proc { |attrs| attrs[:recipients_ids].present? }
        validate :project_conflict_ids_available_conflicts_range, if: proc { |attrs| attrs[:project_conflict_ids].present? }

        def available_states
          states = Decidim::Projects::Project::ADMIN_STATES_FOR_SEARCH
          states.each_with_object({}) do |scope, hash|
            hash[scope] = I18n.t("decidim.admin.filters.projects.state_eq.values.#{scope}")
          end
        end

        def available_verification_status
          verification_statuses = Decidim::Projects::Project::ADMIN_VERIFICATION_STATES_FOR_SEARCH
          verification_statuses.each_with_object({}) do |scope, hash|
            hash[scope] = I18n.t("decidim.admin.filters.projects.verification_status_eq.values.#{scope}")
          end
        end

        def available_scope_types
          scopes = Decidim::ScopeType.all
          scopes.each_with_object({}) do |scope, hash|
            hash[scope.id] = scope.name['pl']
          end
        end

        def available_scopes
          scopes = Decidim::Projects::DistrictScopes.new.query_all_sorted
          scopes.each_with_object({}) do |scope, hash|
            hash[scope.id] = scope.name['pl']
          end
        end

        def available_recipients
          recipients = Decidim::AdminExtended::Recipient.active.sorted_by_name
          recipients.each_with_object({}) do |recipient, hash|
            hash[recipient.id] = recipient.name
          end
        end

        def available_categories
          areas = Decidim::Area.sorted_by_name
          areas.each_with_object({}) do |cat, hash|
            hash[cat.id] = cat.name['pl']
          end
        end

        def available_paper
          { 'true' => 'Papierowy', 'false' => 'Elektroniczny' }
        end

        def project_conflict
          statuses = Decidim::Projects::Project.conflict_statuses.keys
          statuses.each_with_object({}) do |stat, hash|
            next if stat == "not_set"

            hash[stat] = I18n.t("decidim.admin.filters.project_conflict_ids.values.#{stat}")
          end
        end

        def scope_ids_is_in_scope_districts_range
          unless scope_ids.all? { |scope| available_scopes.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra typu')
          end
        end

        def states_is_in_available_states_range
          unless states.all? { |scope| available_states.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra statusu')
          end
        end

        def verification_status_is_in_available_verification_status_range
          unless verification_statuses.all? { |scope| available_verification_status.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra statusu weryfikacji')
          end
        end

        def scope_type_ids_is_in_available_scopes_range
          unless scope_ids.all? { |scope| available_scopes.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra dzielnicy')
          end
        end

        def categories_ids_is_in_available_categories_range
          unless categories_ids.all? { |scope| available_categories.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra kategorii')
          end
        end

        def recipients_ids_is_in_available_recipients_range
          unless recipients_ids.all? { |scope| available_recipients.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra grupy docelowej')
          end
        end

        def project_conflict_ids_available_conflicts_range
          unless project_conflict_ids.all? { |scope| Decidim::Projects::Project.conflict_statuses.keys.include?(scope) }
            errors.add(:scope_id, 'Wystąpił błąd podczas wyboru filtra konfliktów')
          end
        end
      end
    end
  end
end
