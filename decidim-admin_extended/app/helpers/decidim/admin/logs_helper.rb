# frozen_string_literal: true

module Decidim
  module Admin
    # Custom helpers for logs
    module LogsHelper
      def log_actions_select(f)
        action_list = []
        Decidim::ActionLog.distinct.pluck(:resource_type, :action).each do |action_log|
          action_list << [ I18n.t("decidim.admin_log.#{action_log.first.underscore}.#{action_log.last}"),"#{action_log.first.underscore}.#{action_log.last}"]
        end

        f.select :log_action_name, action_list,
                 { label: 'Akcje',
                   include_hidden: false,
                   include_blank: true },
                 multiple: false
      end
    end
  end
end

