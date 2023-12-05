# frozen_string_literal: true

module Decidim
  module Projects
    # Simple helpers to handle markup variations for project wizard partials
    module VoteWizardHelper
      include Decidim::Projects::ProjectWizardHelper

      def path_for_wizard_vote(vote_card, go_to_step = 'step_1', options = {})
        edit_votes_card_url(vote_card, { step: go_to_step }.merge(options))
      end

      def path_for_submitting_vote(vote_card)
        publish_votes_card_path(vote_card)
      end

      def path_for_wizard_update_vote(vote_card, from_step = 'step_1')
        votes_card_path(vote_card, step: from_step)
      end

      def path_for_district_projects(vote_card)
        district_projects_votes_card_path(vote_card, step: params[:step])
      end

      def path_for_filtered_projects(vote_card, go_to_step)
        filtered_projects_votes_card_path(vote_card, step: go_to_step)
      end

      def path_for_canceling_vote(vote_card)
        finish_votes_card_path(vote_card)
      end

      # Returns the css classes used for the project wizard for the desired step
      #
      # step - A symbol of the target step
      # wizard - current voting wizard for user, for checking current step for stepper
      #
      # Returns a string with the css classes for the desired step
      def vote_wizard_step_classes(step, wizard)
        if wizard.stepper_active?(step)
          %(step--active #{step} #{wizard.stepper_step})
        elsif wizard.stepper_past?(step)
          %(step--past #{step})
        else
          %()
        end
      end

      # Returns the list with all the steps, in html
      #
      # wizard - Decidim::Projects::VotingWizard instance
      # vote_card - Decidim::Projects::VoteCard - vote_card instance for generating proper link
      def vote_wizard_stepper(wizard, vote_card)
        content_tag :ol, class: "wizard__steps voting" do
          Decidim::Projects::VotingWizard::STEPPER_LIST.map { |step|
            wizard_stepper_step(wizard, step, vote_card)
          }.join('').html_safe
        end
      end

      # Returns the list item of the given step, in html with link inside
      #
      # wizard - Decidim::Projects::VotingWizard instance
      # for_step - String -> for what step is this element created
      # vote - Decidim::Projects::Vote - vote instance for generating proper link
      def wizard_stepper_step(wizard, for_step, vote_card)
        attributes = { class: vote_wizard_step_classes(for_step, wizard).to_s }
        step_title = vote_wizard_step_name(for_step).html_safe
        if wizard.stepper_active?(for_step)
          current_step_title = vote_wizard_step_name("current_step").html_safe
          step_title = content_tag(:span, "#{current_step_title}: ", class: "show-for-sr") + step_title
          attributes["aria-current"] = "step"
        elsif wizard.stepper_past?(for_step) && wizard.step != "step_6"
          href = edit_votes_card_path(vote_card, step: for_step)
          step_title = link_to step_title, href, class: 'wizard-step-link'
        end

        content_tag(:li, step_title, attributes)
      end

      def wider_step_info(wizard)
        "Oddaj głos w Budżecie Obywatelskim - krok #{wizard.stepper_number}"
      end

      def vote_wizard_step_title(wizard, year)
        I18n.t(wizard.stepper_step, scope: "decidim.projects.votes_cards.wizard_steps.step_titles", year: year)
      end

      def voting_instruction
        content_tag :ol, class: "voting-instruction" do
          [1, 2, 3, 4].map { |i|
            instruction_element(i)
          }.join('').html_safe
        end
      end

      def instruction_element(i)
        attributes = { class: [1, 2].include?(i) ? 'choosing' : "filling" }
        interior = [
                    content_tag(:div, i, class: 'number'),
                    (content_tag(:span, '', class: 'line') if i != 4),
                    I18n.t("title_#{i}", scope: "decidim.projects.votes_cards.instruction").html_safe
                    ].join('').html_safe

        content_tag(:li, interior, attributes)
      end

      # Returns the name of the step, translated
      #
      # step - A symbol of the target step
      def vote_wizard_step_name(step)
        t("decidim.projects.votes_cards.wizard_steps.#{step}")
      end
    end
  end
end
