# frozen_string_literal: true

module Decidim
  module Projects
    # Permissions class defines all the permissions in public scope
    class Permissions < Decidim::DefaultPermissions
      # Public: main method called to check permissions.
      def permissions
        # return permission_action unless permission_action.subject == :projects

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Projects::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        allowed_project_showing?
        allowed_project_creating?
        allowed_project_publishing?
        allowed_changing_project?
        allowed_submitting_project?
        allowed_withdrawing_project?
        allowed_appealing?
        allowed_appealing_read?
        allowed_coauthor_acceptance?

        allowed_creating_votes?
        allowed_submitting_vote?

        permission_action
      end

      # Public: method for fetching project from the context
      def project
        @project ||= context.fetch(:project, nil)
      end

      # Public: method for fetching vote_card from the context
      def vote_card
        @vote_card ||= context.fetch(:vote_card, nil)
      end

      # Public: method for fetching component from the context
      def component
        @component ||= context.fetch(:component, nil) || context.fetch(:current_component, nil)
      end

      # Public: method for defining step based on the component in context
      def step
        return nil unless component&.participatory_space.respond_to?(:active_step)

        @step ||= component.participatory_space.active_step
      end

      # Public: method for determining if submitting projects is allowed
      #
      # returns Boolean
      def submitting_allowed?
        return false unless step
        return false unless component
        return false unless component.published?

        step.system_name == 'submitting' || component.step_settings[step.id.to_s].creation_enabled
      end

      # Public: method for determining if project from the context is public.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.
      #
      #
      # returns noting
      def allowed_project_showing?
        return unless permission_action.subject == :project
        return unless permission_action.action == :show

        toggle_allow(true)
      end

      # Public: method for determining if creating projects is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.
      #
      # returns nothing
      def allowed_project_creating?
        return unless user
        return if user.has_ad_role? && !Rails.env.development?
        return unless permission_action.subject == :project
        return unless permission_action.action == :create

        toggle_allow(user && submitting_allowed?)
      end

      # Public: method for determining if publishing projects is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.
      #
      # returns nothing
      def allowed_project_publishing?
        return unless user
        return if user.has_ad_role? && !Rails.env.development?
        return unless permission_action.subject == :project
        return unless permission_action.action == :publish

        toggle_allow(project.editable_by?(user) && submitting_allowed?)
      end

      # Public: method for determining if editing projects is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_changing_project?
        return unless user
        return if user.has_ad_role? && !Rails.env.development?
        return unless project
        return unless permission_action.subject == :project
        return unless permission_action.action == :edit

        toggle_allow(project.editable_by?(user))
      end

      # Public: method for determining if submitting projects is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_submitting_project?
        return unless user
        return if user.has_ad_role? && !Rails.env.development?
        return unless project
        return unless permission_action.subject == :project
        return unless permission_action.action == :publish

        toggle_allow(project.publicable_by?(user))
      end

      # Public: method for determining if withdrawing projects is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_withdrawing_project?
        return unless project
        return unless permission_action.subject == :project
        return unless permission_action.action == :withdraw

        toggle_allow(user && project.withdrawable_by?(user))
      end

      # Public: method for determining if appealing is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_appealing?
        return unless project
        return unless user
        return unless permission_action.subject == :project
        return unless permission_action.action == :appeal

        toggle_allow(project.appealable_by?(user))
      end

      # Public: method for determining if reading appeal is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_appealing_read?
        return unless project
        return unless user
        return unless permission_action.subject == :project
        return unless permission_action.action == :read_appeal

        toggle_allow(project.created_by?(user))
      end

      # Public: method for determining if acceptance of coauthorship is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_coauthor_acceptance?
        return unless project
        return unless user
        return unless permission_action.subject == :project
        return unless permission_action.action == :coauthor

        toggle_allow(coauthorships.any? && coauthorship_for_user && coauthorship_for_user.in_acceptance_time?)
      end

      # Public: method returns collection of coauthorships that are waiting for acceptance
      # for the project fetched from the context
      def coauthorships
        @coauthorships ||= project.coauthorships.for_acceptance.for_decidim_users
      end

      # Public: method returns coauthorship of the currently logged in user
      # based on the coauthorships collection
      def coauthorship_for_user
        coauthorships.find_by(decidim_author_id: user.id)
      end

      # Public: method for determining if voting in given component is allowed.
      # Based on the outcome, method sets the permission_action as allowed or disallowed.      #
      #
      # returns nothing
      def allowed_creating_votes?
        return unless permission_action.subject == :voting
        return unless permission_action.action == :create

        toggle_allow(voting_enabled?)
      end

      def allowed_submitting_vote?
        return unless permission_action.subject == :voting
        return unless permission_action.action == :edit
        return unless vote_card
        return unless vote_card.status == Decidim::Projects::VoteCard::STATUSES::LINK_SENT

        @step = vote_card.participatory_space.active_step
        @component = vote_card.component

        toggle_allow(voting_enabled?)
      end

      def voting_enabled?
        return false unless step
        return false unless component
        return false unless component.published?

        component.step_settings[step.id.to_s].voting_enabled
      end
    end
  end
end
