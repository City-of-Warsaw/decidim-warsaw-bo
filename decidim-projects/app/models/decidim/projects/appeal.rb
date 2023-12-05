# frozen_string_literal: true

module Decidim
  module Projects
    # Appeals are used by users as a complaint after Project was negatively evaluated.
    class Appeal < ApplicationRecord
      include Decidim::HasAttachments

      belongs_to :project,
                 class_name: 'Decidim::Projects::Project',
                 foreign_key: :project_id

      belongs_to :author,
                 class_name: 'Decidim::User',
                 foreign_key: :author_id,
                 optional: true

      delegate :title, :esog_number, to: :project
      delegate :organization, to: :project
      delegate :verification_status, to: :project

      # Public: documents of the appeal
      #
      # returns attachments
      def documents
        attachments
      end

      # Public: checks if the appeal was submitted
      #
      # returns Boolean
      def submitted?
        time_of_submit.present?
      end

      # Ransack helpers for search
      ransacker :esog_number_string do
        Arel.sql(%{cast("decidim_projects_projects"."esog_number" as text)})
      end

      ransacker :project_title do
        Arel.sql(%{cast("decidim_projects_projects"."title" as text)})
      end
    end
  end
end
