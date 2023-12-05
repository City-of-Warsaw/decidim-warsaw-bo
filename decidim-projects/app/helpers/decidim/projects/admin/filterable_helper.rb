# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Helper class for Filters in admin panel
      module FilterableHelper
        def prepare_menu_item_for(model_items, search_field_name, model_title)
          menu = "
            <li class='is-dropdown-submenu-parent is-submenu-item is-dropdown-submenu-item opens-right' role='none' aria-haspopup='true' aria-label='#{model_title}'>
              <a href='#' role='menuitem'>#{model_title}</a>
              <ul class='vertical menu submenu is-dropdown-submenu' role='menubar' data-submenu=''>"
          model_items.each do |key, state|
            menu += "<li class='is-submenu-item is-dropdown-submenu-item' role='none'>
                       <a href='#{prepare_url_for_field(search_field_name, key)}'> #{state}</a>
                     </li>"
          end
          menu += "</ul>
                 </li>"
          menu.html_safe
        end

        def applied_filters_hidden
          html = ""
          applied_params_hash.each do |filter, value|
            value.each do |v|
              html += hidden_field_tag("#{filter}[]", v) if filter != :q
            end
          end
          html.html_safe
        end

        def prepare_url_for_field(search_field_name, key)
          if applied_params_hash.with_indifferent_access[search_field_name]&.include?(key).present?
            url_for(only_path: false) + '?' + applied_params_hash.to_param
          else
            url_for(only_path: false) + '?' + applied_params_hash.merge({ search_field_name => [key] }).to_param
          end
        end

        def filter_tags_deletes
          html = ""
          applied_params_hash.each do |filter, value|
            cleared_values = value.delete_if{ |v| v == "" }
            cleared_values.each do |val|
              # To not show empty search filed
              next if filter == :q && value.values.all?(&:blank?)

              html += applied_filters_tags(filter, val, filterable_i18n_scope_from_ctx(nil))
            end
          end
          html.html_safe
        end

        def applied_filters_tags(filter, value, i18n_scope)
          content_tag(:span, class: 'label secondary') do
            concat "#{i18n_filter_label(filter, i18n_scope)}: "
            concat filter_value(filter, value, i18n_scope)
            concat remove_filter_icon(filter, value)
          end
        end

        def filter_value(filter, value, i18n_scope)
          if I18n.exists?("#{i18n_scope}.#{filter}.values.#{value}")
            t(value, scope: "#{i18n_scope}.#{filter}.values")
          else
            if filter == :scope_ids
              Decidim::Scope.find_by(id: value).name["pl"]
            elsif filter == :recipients_ids
              Decidim::AdminExtended::Recipient.active.find_by(id: value).name
            elsif filter == :q
              value.second
            elsif filter == :categories_ids
              Decidim::Area.find_by(id: value).name["pl"]
            elsif filter == :user_ids
              Decidim::User.find_by(id: value).ad_full_name
            else
              find_dynamic_translation(filter, value)
            end
          end
        end

        def query_params_without_this(filter, value)
          params_hash = applied_params_hash
          if params_hash.has_key?(filter)
            if filter == :q
              params_hash = params_hash.except(:q)
            else
              params_hash[filter].delete(value)
            end
            url_for(only_path: false) + '?' + params_hash.reject { |_, v| !v.any? }.to_param
          end
        end

        def remove_filter_icon(filter, value)
          icon_link_to(
            'circle-x',
            url_for(query_params_without_this(filter, value)),
            t('decidim.admin.actions.cancel'),
            class: 'action-icon--remove'
          )
        end

        def applied_params_hash
          params.permit(is_paper: [],
                        user_ids: [],
                        states: [],
                        verification_statuses: [],
                        scope_type_ids: [],
                        recipients_ids: [],
                        categories_ids: [],
                        project_conflict_ids: [],
                        scope_ids: [])
                .merge(params_for_text_search).to_h.deep_symbolize_keys
        end

        def params_for_text_search
          params[:q].present? ? { q: params[:q].permit(search_field_predicate) } : {}
        end

        def extra_dropdown_submenu_options_items(filter, i18n_scope)
          options = case filter
                    when :state_eq
                      tag.li(filter_link_value(:state_null, true, i18n_scope))
                    when :scope_type_eq
                      Decidim::ScopeType.all.map do |st|
                        tag.li(st.name['pl'])
                      end.join('').html_safe
                    end
          [options].compact
        end
      end
    end
  end
end
