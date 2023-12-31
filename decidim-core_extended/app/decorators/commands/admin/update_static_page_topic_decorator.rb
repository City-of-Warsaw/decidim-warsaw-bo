# frozen_string_literal: true

Decidim::Admin::UpdateStaticPageTopic.class_eval do

  private

  def attributes
    {
      title: form.title,
      description: form.description,
      show_in_footer: form.show_in_footer,
      weight: form.weight,
      scroll_template: form.scroll_template,
      template: @form.template
    }
  end
end