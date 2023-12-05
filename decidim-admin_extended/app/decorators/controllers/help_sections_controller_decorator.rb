# frozen_string_literal: true

Decidim::Admin::HelpSectionsController.class_eval do
  private

  def sections
    @sections ||= Decidim.participatory_space_manifests.map do |manifest|
      OpenStruct.new(
        id: manifest.name.to_s,
        content: Decidim::ContextualHelpSection.find_content(current_organization, manifest.name)
      )
    end.+(
      [
        OpenStruct.new(
          id: 'notes',
          content: Decidim::ContextualHelpSection.find_content(current_organization, 'notes')
        )
      ]
    )
  end
end
