# frozen_string_literal: true

Decidim::Admin::NewslettersHelper.class_eval do
  def select_tag_participatory_spaces(manifest_name, spaces, child_form)
    return unless spaces

    content_tag :div, class: "#{manifest_name}-block spaces-block-tag cell small-12 medium-6" do
      child_form.select :ids, options_for_select(spaces),
                        { prompt: t('select_recipients_to_deliver.none', scope: 'decidim.admin.newsletters'),
                          label: false,
                          include_hidden: false },
                        multiple: true, size: spaces.size > 10 ? 10 : spaces.size, class: 'chosen-select'
    end
  end

  def selective_newsletter_to(newsletter)
    return content_tag(:strong, t("index.not_sent", scope: "decidim.admin.newsletters"), class: "text-warning") unless newsletter.sent?
    unless newsletter.sent?
      return content_tag(:strong, t('index.not_sent', scope: 'decidim.admin.newsletters'), class: 'text-warning')
    end
    if newsletter.sent? && newsletter.extended_data.blank?
      return content_tag(:strong, t('index.all_users', scope: 'decidim.admin.newsletters'), class: 'text-success')
    end

    content_tag :div do
      concat sent_to_users newsletter
    end
  end

  def sent_to_users(newsletter)
    content_tag :p, style: 'margin-bottom:0;' do
      concat content_tag(:strong, t('index.has_been_sent_to', scope: 'decidim.admin.newsletters'), class: 'text-success')
      if newsletter.sended_to_all_users?
        concat content_tag(:strong, t('index.all_users', scope: 'decidim.admin.newsletters'))
      end
      if newsletter.sended_to_followers?
        concat content_tag(:strong, t('index.followers', scope: 'decidim.admin.newsletters'))
      end
      if newsletter.sended_to_followers? && newsletter.sended_to_participants?
        concat t('index.and', scope: 'decidim.admin.newsletters')
      end
      if newsletter.sended_to_participants?
        concat content_tag(:strong, t('index.participants', scope: 'decidim.admin.newsletters'))
      end
      if newsletter.sended_to_authors?
        concat content_tag(:strong, t('index.authors', scope: 'decidim.admin.newsletters'))
      end
      if newsletter.sended_to_coauthors?
        concat content_tag(:strong, t('index.coauthors', scope: 'decidim.admin.newsletters'))
      end
      concat content_tag(:strong, t('index.file', scope: 'decidim.admin.newsletters')) if newsletter.sended_to_file?
      if newsletter.sended_to_internal?
        concat content_tag(:strong, t('index.internal_user', role: newsletter.name_of_internal_user_roles, scope: 'decidim.admin.newsletters'))
      end
      if newsletter.sended_to_users_with_agreement_of_evaluation?
        concat content_tag(:strong, t('index.users_with_agreement_evaluation', scope: 'decidim.admin.newsletters'))
      end
    end
  end

  def spaces_user_can_admin
    @spaces_user_can_admin ||= {}
    Decidim.participatory_space_manifests.each do |manifest|
      organization_participatory_space(manifest.name)&.each do |space|
        @spaces_user_can_admin[manifest.name] ||= []
        space_as_option_for_select_data = space_as_option_for_select(space)
        @spaces_user_can_admin[manifest.name] << space_as_option_for_select_data unless @spaces_user_can_admin[manifest.name].detect do |x|
          x == space_as_option_for_select_data
        end
      end
    end
    @spaces_user_can_admin
  end
end
