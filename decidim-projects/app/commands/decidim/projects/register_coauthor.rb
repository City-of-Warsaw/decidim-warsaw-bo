# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user register to accept a coauthorship.
    class RegisterCoauthor < Rectify::Command
      # Public: Initializes the command.
      #
      # form             - Form Object
      # user             - Invited User that need to finish registration process.
      def initialize(user, form)
        @user = user
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when user could be saved
      # - :invalid if form is invalid
      # - :invalid if user can not be saved
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @form.valid?

        update_coauthor

        if @user.valid?
          @user.save!
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private
      # private method
      #
      # assigning data from form to user
      #
      # returns nothing
      def update_coauthor
        @user.password = @form.password
        @user.password_confirmation = @form.password_confirmation
        @user.tos_agreement = @form.tos_agreement
        @user.newsletter_notifications_at = @form.newsletter_at
        @user.accepted_tos_version = @user.organization.tos_version
        # custom
        @user.first_name = @form.first_name
        @user.last_name = @form.last_name
        @user.gender = @form.gender
        @user.show_my_name = @form.acceptance
        @user.email_on_notification = false
        @user.inform_me_about_proposal = false
      end
    end
  end
end
