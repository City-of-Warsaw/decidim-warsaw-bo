# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to manually update projects status in admin panel.
      class ChangeVoteStatusForm  < Form
        attribute :status, String
        attribute :vote_id, Integer

        validates :status, presence: true

        # Public: sets Project
        def vote
          @vote ||= Decidim::Projects::VoteCard.find_by(id: vote_id)
        end

        def possible_states
          return [] unless vote

          Decidim::Projects::VoteCard::ADMIN_STATUS_FOR_UPDATE.map do |status|
            [I18n.t(status, scope: 'decidim.admin.filters.votes.status_eq.values'), status]
          end
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.vote_id = model.id
        end
      end
    end
  end
end
