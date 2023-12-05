# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :projects_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :projects).i18n_name }
    manifest_name { :projects }
    participatory_space { create(:participatory_process, :with_steps) }
    weight { 0 }
    permissions { nil }
    published_at { '2022-11-14T14:24:00.000+02:00' }
  end

  # Add engine factories here
  factory :projects_project, class: Decidim::Projects::Project do
    # here will be factory projects_project's content
  end

  factory :projects_project_customization, class: Decidim::Projects::ProjectCustomization do
    # here will be factory projects_project_customization's content
  end

  factory :projects_project_recipient, class: Decidim::Projects::ProjectRecipient do
    project
    recipient
  end
end
