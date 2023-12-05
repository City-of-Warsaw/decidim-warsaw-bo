# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to manually update projects status in admin panel.
      class ChangeStatusForm  < Form
        attribute :state, String
        attribute :body, String
        attribute :project_id, Integer

        validates :state, presence: true
        validate :if_can_send_notification

        def if_can_send_notification
          return if body.blank?

          errors.add(:status, 'Nie można wysłać wiadomości, spróbuj zmienić status bez dodatkowego powiadomienia') unless project.within_status_change_notification_time?
        end

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end

        def edition
          project.participatory_space
        end

        def possible_states
          return [] unless project

          [
            [I18n.t('draft', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::DRAFT],
            [I18n.t('admin_draft', scope: 'decidim.admin.filters.projects.state_eq.values'), 'admin_draft'],
            [I18n.t('published', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::PUBLISHED],
            [I18n.t('withdrawn', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::WITHDRAWN],
            [I18n.t('accepted', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::ACCEPTED],
            [I18n.t('rejected', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::REJECTED],
            [I18n.t('selected', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::SELECTED],
            [I18n.t('not_selected', scope: 'decidim.admin.filters.projects.state_eq.values'), Decidim::Projects::Project::POSSIBLE_STATES::NOT_SELECTED]
          ]
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.project_id = model.id
          self.body = ''
        end
      end
    end
  end
end
