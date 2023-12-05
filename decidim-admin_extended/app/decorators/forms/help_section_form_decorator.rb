# frozen_string_literal: true

Decidim::Admin::HelpSectionForm.class_eval do
  def name
    if manifest
      multi_translation("activerecord.models.#{manifest.model_class_name.underscore}.other")
    else
      multi_translation("activerecord.models.#{id}.other")
    end
  end
end