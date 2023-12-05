# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to search action logs for admin
      class LogSearchForm < Form
        attribute :start_date, Decidim::Attributes::LocalizedDate
        attribute :end_date, Decidim::Attributes::LocalizedDate
        attribute :project_id, Integer
        attribute :owner_name, String
        attribute :log_action_name, String

        mimic :log_search


        def find_logs
          logs = Decidim::ActionLog
                 .where(organization: current_organization).joins(:user)
                 .includes(:participatory_space, :resource, :component, :version)
                 .for_admin

          if project_id.present?
            return logs.reorder(created_at: :asc)
                       .where(resource_type: 'Decidim::Projects::Project', resource_id: project_id)
          end

          if owner_name.present?
            owner_name.split(' ').each do |name|
              logs = logs.where('decidim_users.name ILIKE :q OR
                                decidim_users.last_name ILIKE :q OR decidim_users.first_name ILIKE :q OR
                                decidim_users.display_name ILIKE :q',
                                q: "%#{name}%")
            end
          end

          if log_action_name.present?
            log_action = log_action_name.split('.')
            logs = logs.where(resource_type: log_action.first.classify, action: log_action.last)
          end

          if start_date.present? && end_date.present?
            days_between_date = end_date.mjd - start_date.mjd
            if days_between_date > 15
              errors.add(:start_date, 'Maksymalny okres to 15 dni')
            else
              logs = logs.where('DATE(decidim_action_logs.created_at) >= ? AND DATE(decidim_action_logs.created_at) <= ?', start_date, end_date)
            end
          end
          logs = logs.where('DATE(decidim_action_logs.created_at) >= ?', start_date) if start_date.present? && end_date.blank?
          logs = logs.where('DATE(decidim_action_logs.created_at) <= ?', end_date) if end_date.present? && start_date.blank?

          logs.order(created_at: :desc)
        end
      end
    end
  end
end
