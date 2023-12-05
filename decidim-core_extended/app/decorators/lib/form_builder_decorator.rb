# frozen_string_literal: true

require "foundation_rails_helper/form_builder"

Decidim::FormBuilder.class_eval do
  include ActionView::Helpers::AssetUrlHelper

  def data_picker(attribute, options = {}, prompt_params = {})
    picker_options = {
      id: "#{@object_name}_#{attribute}",
      class: "picker-#{options[:multiple] ? "multiple" : "single"}",
      name: options[:name] || "#{@object_name}[#{attribute}]"
    }
    picker_options[:class] += " is-invalid-input" if error?(attribute)
    picker_options[:class] += " picker-autosort" if options[:autosort]

    items = object.send(attribute).collect { |item| [item, yield(item)] }

    template = ""
    template += label(attribute, label_for(attribute) + required_for_attribute(attribute, options)) unless options[:label] == false
    template += error_and_help_text(attribute, options)
    template += @template.render("decidim/widgets/data_picker", picker_options: picker_options, prompt_params: prompt_params, items: items)
    template.html_safe
  end

  def date_field(attribute, options = {})
    value = object.send(attribute)
    data = { datepicker: "" }
    data[:startdate] = I18n.l(value, format: :decidim_short) if value.present? && value.is_a?(Date)
    datepicker_format = ruby_format_to_datepicker(I18n.t("date.formats.decidim_short"))
    data[:"date-format"] = datepicker_format

    options[:help_text] ||= I18n.t("decidim.datepicker.help_text", datepicker_format: datepicker_format)

    template = text_field(
      attribute,
      options.merge(data: data, autocomplete: 'off')
    )

    template.html_safe
  end

  def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
    custom_label(attribute, options[:label], options[:label_options], options[:tooltip_helper], field_before_label: true) do
      options.delete(:label)
      options.delete(:label_options)
      @template.check_box(@object_name, attribute, objectify_options(options), checked_value, unchecked_value)
    end + error_and_help_text(attribute, options)
  end

  private

  def field(attribute, options, html_options = nil, &block)
    label = options.delete(:label)
    label_options = options.delete(:label_options)
    tooltip_helper = options.delete(:tooltip_helper)

    custom_label(attribute, label, label_options, tooltip_helper) do
      field_with_validations(attribute, options, html_options, &block)
    end
  end

  def custom_label(attribute, text, options, tooltip_helper, field_before_label: false, show_required: true)
    return block_given? ? yield.html_safe : "".html_safe if text == false

    hint = tooltip_helper || ''
    main_label = text.presence || default_label_text(object, attribute)
    main_label += required_for_attribute(attribute, hint) if show_required
    additional_hint = additional_hint(hint) if show_required

    final_input = if field_before_label && block_given?
                       safe_join([yield, additional_hint.html_safe])
                     elsif block_given?
                       safe_join([additional_hint.html_safe, yield])
                     end

    options = options ? options.merge(class: 'styled-label') : { class: 'styled-label' }

    if field_before_label
      (final_input + label(attribute, main_label, options)).html_safe
    else
      (label(attribute, main_label, options) + final_input).html_safe
    end
  end

  def field_with_validations(attribute, options, html_options)
    class_options = html_options || options

    if error?(attribute)
      class_options[:class] = class_options[:class].to_s
      class_options[:class] += " is-invalid-input"
    end

    help_text = options.delete(:help_text)
    prefix = options.delete(:prefix)
    postfix = options.delete(:postfix)

    unless self.object.class.name == 'Decidim::Projects::ProjectForm'
      class_options = extract_validations(attribute, options).merge(class_options)
    end

    content = yield(class_options)
    content += abide_error_element(attribute) if class_options[:pattern] || class_options[:required]
    content = content.html_safe
    html = wrap_prefix_and_postfix(content, prefix, postfix)
    new_help = help_text.present? ? content_tag(:span, help_text, class: "help-text") : ''
    new_error = error_for(attribute, options.merge(help_text: help_text))
    "#{new_help}#{html}#{new_error}".html_safe
  end

  def required_for_attribute(attribute, hint = nil)
    asterix = if one_of_project_forms?
                ''
              elsif attribute_required?(attribute)
                visible_title = content_tag(:span, "*", "aria-hidden": true)
                screenreader_title = content_tag(
                  :span,
                  I18n.t("required", scope: "forms"),
                  class: "show-for-sr"
                )
                content_tag(
                  :span,
                  visible_title + screenreader_title,
                  # title: I18n.t("required", scope: "forms"),
                  # data: { tooltip: false, disable_hover: false, keep_on_hover: false },
                  # "aria-haspopup": false,
                  class: "label-required"
                ).html_safe
              else
                ''
              end
    asterix
  end

  def additional_hint(raw_hint)
    hint = if raw_hint.is_a?(Hash)
             raw_hint[:tooltip_helper]
           else
             raw_hint
           end

    if hint.present?
      visible_title = content_tag(:span, '', "aria-hidden": true)
      screenreader_title = content_tag(
        :span,
        hint,
        class: "show-for-sr"
      )
      content_tag(
        :span,
        visible_title + screenreader_title,
        title: hint,
        data: { tooltip: true, disable_hover: false, keep_on_hover: true },
        "aria-haspopup": true,
        class: "additional-hint",
        tabindex: 0
      ).html_safe
    else
      ''
    end
  end

  def one_of_project_forms?
    self.object.class.name == 'Decidim::Projects::ProjectForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardAuthorStepForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardAuthorStepWithValidationsForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardCreateStepForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardFirstStepWithValidationForm'
  end

  def one_of_project_validated_forms?
    self.object.class.name == 'Decidim::Projects::ProjectForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardAuthorStepWithValidationsForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardFirstStepWithValidationForm'
  end

  def one_of_project_not_validated_forms?
    self.object.class.name == 'Decidim::Projects::ProjectWizardAuthorStepForm' ||
      self.object.class.name == 'Decidim::Projects::ProjectWizardCreateStepForm'
  end

  def abide_error_element(attribute)
    ''
  end

  def extract_validations(attribute, options)
    min_length = options.delete(:minlength) || length_for_attribute(attribute, :minimum) || 0
    max_length = options.delete(:maxlength) || length_for_attribute(attribute, :maximum)

    validation_options = {}
    validation_options[:pattern] = "^(.|[\n\r]){#{min_length},#{max_length}}$" if min_length.to_i.positive? || max_length.to_i.positive?
    validation_options[:required] = options[:required] || attribute_required?(attribute)
    validation_options[:'aria-required'] = options[:'aria-required']
    validation_options[:minlength] ||= min_length if min_length.to_i.positive?
    validation_options[:maxlength] ||= max_length if max_length.to_i.positive?
    validation_options
  end
end
