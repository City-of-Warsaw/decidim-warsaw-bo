# frozen_string_literal: true

module Decidim
  module Projects
    # This class serializes a project rank so can be exported to CSV, JSON or other
    # formats.
    class ProjectRankSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper
      include Decidim::TranslationsHelper
      include Decidim::Projects::Admin::VotesCardsHelper

      # Public: Initializes the serializer with a vote.
      def initialize(project_rank)
        @pr = project_rank
      end

      # Public: Exports a hash with the serialized data for this vote.
      def serialize
        {
          "Numer na liście": pr.project.voting_number,
          "Numer ESOG": pr.project.esog_number,
          "Nazwa projektu": pr.project.title,
          "Koszt realizacji": pr.project.budget_value,
          "Liczba ważnych głosów": pr.valid_votes_count,
          "Liczba niezweryfikowanych głosów": pr.not_verified_votes_count,
          "Liczba nieważnych głosów": pr.invalid_votes_count,
          "Liczba głosów elektronicznych": pr.votes_electronic_count,
          "Liczba głosów papierowych": pr.votes_in_paper_count,
          "Odsetek niezweryfikowanych": pr.percentage_of_not_verified_votes,
          "Czy jest na liście": (pr.on_the_list? ? "Tak" : "Nie")
        }
      end

      private

      attr_reader :pr

    end
  end
end
