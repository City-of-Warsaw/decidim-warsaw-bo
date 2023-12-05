# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Helper class for Bulk Actions
      module ProjectBulkActionsHelper
        # Public: Generates a select field with the valuators of the given participatory space.
        #
        # participatory_space - A participatory space instance.
        # prompt - An i18n string to show as prompt
        #
        # Returns a String.
        def bulk_evaluators_select(prompt)
          options_for_select = find_valuators_for_select
          select(:valuator, :id, options_for_select, prompt: prompt)
        end

        def bulk_users_select(prompt)
          select_tag("user_ids[]", options_for_select(find_user_for_select), prompt: prompt)
        end

        def find_user_for_select
          users = if current_user.ad_admin?
                        Decidim::User.verificators.
                          or(Decidim::User.sub_coordinators).
                          or(Decidim::User.coordinators)
                      elsif current_user.department
                        current_user.department.coordinators.
                          or(current_user.department.sub_coordinators).
                          or(current_user.department.verificators)
                      else
                        Decidim::User.none
                      end
          users.order("LOWER(last_name) ASC ").map do |user|
            ["#{user.ad_full_name} - #{user.department&.name}", user.id]
          end
        end

        # Internal: A method to cache to queries to find the valuators for the
        # current space.
        def find_valuators_for_select
          return @valuators_for_select if @valuators_for_select

          valuators = if current_user.ad_admin?
                        Decidim::User.verificators.
                          or(Decidim::User.sub_coordinators).
                          or(Decidim::User.coordinators)
                      elsif current_user.department
                        current_user.department.coordinators.
                          or(current_user.department.sub_coordinators).
                          or(current_user.department.verificators)
                      else
                        Decidim::User.none
                      end

          @valuators_for_select = valuators.with_ad_access.order(ad_role: :asc).map do |valuator|
            ["#{valuator.department&.name} - #{valuator.ad_full_name}", valuator.id]
          end
        end

        def bulk_departments_select(prompt)
          departments = if current_user.ad_admin?
                          Decidim::AdminExtended::Department.with_ad_name.active.sorted_by_name
                        elsif current_user.ad_coordinator? && current_user.department
                          current_user.department.departments.with_ad_name.active.sorted_by_name
                        else
                          []
                        end
          select(:department, :id, departments.map{ |d| [d.name, d.id] }, prompt: prompt)
        end
      end
    end
  end
end
