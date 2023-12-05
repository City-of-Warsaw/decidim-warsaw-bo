# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:projects) do |component|
  component.engine = Decidim::Projects::Engine
  component.admin_engine = Decidim::Projects::AdminEngine
  component.icon = "decidim/projects/icon.svg"
  component.permissions_class_name = "Decidim::Projects::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Projects::Project.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    # Add your global settings
    # Available types: :integer, :boolean
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    # Add your settings per step
    settings.attribute :creation_enabled, type: :boolean
    settings.attribute :voting_enabled, type: :boolean
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:some_resource) do |resource|
    # Register a optional resource that can be references from other resources.
    resource.model_class_name = "Decidim::Projects::Project"
    resource.card = "decidim/projects/project"
    resource.reported_content_cell = "decidim/projects/reported_content"
    resource.actions = %w(send)
    resource.searchable = true
  end

  component.exports :projects do |exports|
    exports.collection do |component_instance, user|
      space = component_instance.participatory_space

      collection = Decidim::Projects::Project.published
      collection
    end
    exports.include_in_open_data = true
    exports.serializer Decidim::Projects::ProjectSerializer
  end

  component.exports :ranking_list do |exports|
    exports.collection do |component_instance, user, scope|
      Decidim::Projects::ProjectRanks.new(component_instance).query.for_scope(scope).default_sort
    end
    exports.include_in_open_data = false
    exports.serializer Decidim::Projects::ProjectRankSerializer
  end

  component.exports :vote_cards do |exports|
    exports.collection do |component_instance, user|
      Decidim::Projects::UserVoteCards.for(user, component_instance)
    end
    exports.include_in_open_data = false
    exports.serializer Decidim::Projects::VoteCardSerializer
  end

  component.exports :vote_cards_for_verification do |exports|
    exports.collection do |component_instance, user|
      Decidim::Projects::UserVoteCards.for(user, component_instance).for_verification
    end
    exports.include_in_open_data = false
    exports.serializer Decidim::Projects::VoteCardForVerificationSerializer
  end
end
