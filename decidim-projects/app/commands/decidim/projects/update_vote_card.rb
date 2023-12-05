# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user updates a vote.
    class UpdateVoteCard < Rectify::Command
      include Decidim::Projects::VoteWizardHelper

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user or nil.
      def initialize(vote_card, form, current_user)
        @vote_card = vote_card
        @form = form
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # - :invalid if the attachments are invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_vote
        end

        broadcast(:ok, vote_card)
      end

      private

      attr_reader :form, :vote_card, :current_user

      # Private: Updating vote
      #
      # There is no versioning added and no ActionLog created
      #
      # returns nothing
      def update_vote
        if form.is_a?(Decidim::Projects::WizardVoteDistrictProjectsForm)
          # all projects:
          # - district projects passed in this form
          # - global scope projects that were already signed to vote on different form
          all_projects = Decidim::Projects::Project.where(id: form.district_projects_ids)
                                                   .or(Decidim::Projects::Project.where(id: @vote_card.projects.in_global_scope.pluck(:id)))
          @vote_card.projects = all_projects
          @vote_card.update(scope_id: form.scope_id, projects_in_districts_scope: form.district_projects_ids.map(&:to_i))

        elsif form.is_a?(Decidim::Projects::WizardVoteGlobalProjectsForm)
          # all projects:
          # - global scope projects passed in this form
          # - district projects that were already signed to vote on different form
          all_projects = Decidim::Projects::Project.where(id: form.global_projects_ids)
                                                   .or(Decidim::Projects::Project.where(id: @vote_card.projects.in_district_scope.pluck(:id)))

          @vote_card.projects = all_projects
          @vote_card.update(projects_in_global_scope: form.global_projects_ids.map(&:to_i))

        elsif form.is_a?(Decidim::Projects::WizardVoteUserDataForm)
          @vote_card.update(user_data_attributes)
        end
      end

      # Private: vote user data attributes
      #
      # returns Hash
      def user_data_attributes
        {
          first_name: form.first_name,
          last_name: form.last_name,
          # email: form.email,
          pesel_number: form.pesel_number,
          # address
          street: form.street,
          street_number: form.street_number,
          flat_number: form.flat_number, # can be cleared
          zip_code: form.zip_code.presence,
          city: form.city
        }
      end
    end
  end
end
