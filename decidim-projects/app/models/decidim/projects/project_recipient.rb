# frozen_string_literal: true

module Decidim::Projects
  # ProjectRecipient are used for many-to-many association between project and recipient
  class ProjectRecipient < ApplicationRecord
    belongs_to :project,
                class_name: "Decidim::Projects::Project",
                foreign_key: :decidim_projects_project_id
    belongs_to :recipient,
                class_name: "Decidim::AdminExtended::Recipient",
                foreign_key: :decidim_admin_extended_recipient_id
  end
end
