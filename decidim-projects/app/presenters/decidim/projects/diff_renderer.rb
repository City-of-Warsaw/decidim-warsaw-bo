# frozen_string_literal: true

module Decidim
  module Projects
    # This class holds logic for diffing projects.
    class DiffRenderer < BaseDiffRenderer
      private

      # Private: Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          title: :string,
          body: :string,
          budget_description: :string,
          scope: :scope,
          decidim_scope_id: :scope,
          categories: :areas,
          category_names: :areas,
          custom_categories: :string,
          recipients: :recipients,
          recipient_names: :recipients,
          public_attachment_names: :attachments,
          custom_recipients: :string,
          published_at: :date,
          state: :state,
          short_description: :string,
          universal_design: :boolean,
          universal_design_argumentation: :string,
          justification_info: :string,
          localization_info: :string,
          localization_additional_info: :string,
          locations: :location,
          budget_value: :integer
        }
      end

      # Private: Parses the values before parsing the changeset.
      def parse_changeset(attribute, values, type, diff)
        return parse_state_changeset(attribute, values, type, diff) if type == :state
        return parse_scope_changeset(attribute, values, type, diff) if type == :scope
        return parse_area_changeset(attribute, values, type, diff) if type == :areas
        return parse_recipients_changeset(attribute, values, type, diff) if type == :recipients
        return parse_attachments_changeset(attribute, values, type, diff) if type == :attachments
        return parse_location_changeset(attribute, values, type, diff) if type == :location
        return parse_boolean_changeset(attribute, values, type, diff) if type == :boolean

        values = parse_values(attribute, values)
        old_value = values[0]
        new_value = values[1]

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_value,
            new_value: new_value
          }
        )
      end

      # Private: Method for parsing area changes
      def parse_area_changeset(attribute, values, type, diff)
        return unless diff

        old_v = values[0].is_a?(String) ? values[0].split(',') : values[0]
        new_v = values[1].is_a?(String) ? values[1].split(',') : values[1]
        old_scope = Decidim::Area.where(id: old_v)
        new_scope = Decidim::Area.where(id: new_v)

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_scope.any? ? old_scope.map{ |s| translated_attribute(s.name) }.join(', ') : "",
            new_value: new_scope.any? ? new_scope.map{ |s| translated_attribute(s.name) }.join(', ') : ""
          }
        )
      end

      # Private: Method for parsing recipients changes
      def parse_recipients_changeset(attribute, values, type, diff)
        return unless diff

        old_v = values[0].is_a?(String) ? values[0].split(',') : values[0]
        new_v = values[1].is_a?(String) ? values[1].split(',') : values[1]
        old_scope = Decidim::AdminExtended::Recipient.where(id: old_v)
        new_scope = Decidim::AdminExtended::Recipient.where(id: new_v)

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_scope.any? ? old_scope.map(&:name).join(', ') : "",
            new_value: new_scope.any? ? new_scope.map(&:name).join(', ') : "",
          }
        )
      end

      # Private: Method for attachments area changes
      def parse_attachments_changeset(attribute, values, type, diff)
        return unless diff

        old_v = values[0].is_a?(String) ? values[0].split(',') : values[0]
        new_v = values[1].is_a?(String) ? values[1].split(',') : values[1]
        old_scope = Decidim::Attachment.where(id: old_v)
        new_scope = Decidim::Attachment.where(id: new_v)

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_scope.any? ? old_scope.map{ |a| translated_attribute(a.title) }.join(', ') : "",
            new_value: new_scope.any? ? new_scope.map{ |a| translated_attribute(a.title) }.join(', ') : "",
          }
        )
      end

      # Handles which values to use when diffing emendations and
      # normalizes line endings of the :body attribute values.
      # Returns and Array of two Strings.
      def parse_values(attribute, values)
        # values = [amended_previous_value(attribute), values[1]] if project&.emendation?
        values = values.map { |value| normalize_line_endings(value) } if attribute == :body
        values
      end

      # Sets the previous value so the emendation can be compared with the amended project.
      # If the amendment is being evaluated, returns the CURRENT attribute value of the amended project;
      # else, returns the attribute value of amended project at the moment of making the amendment.
      def parse_location_changeset(attribute, values, type, diff)
        old_value = values[0]
        new_value = values[1]

        o = []
        old_value.each { |k,v| o << v['display_name'] } if old_value.any?
        n = []
        new_value.each { |k,v| n << v['display_name'] } if new_value.any?

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: o.any? ? o.join(', ') : o,
            new_value: n.any? ? n.join(', ') : n
          }
        )
      end

      # Private: Method for parsing state changes
      def parse_state_changeset(attribute, values, type, diff)
        old_value = I18n.t(values[0], scope: 'decidim.admin.filters.projects.state_eq.values')
        new_value = I18n.t(values[1], scope: 'decidim.admin.filters.projects.state_eq.values')

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_value,
            new_value: new_value
          }
        )
      end

      # Private: Method for parsing boolean changes
      def parse_boolean_changeset(attribute, values, type, diff)
        old_value = I18n.t(values[0], scope: 'booleans', default: '')
        new_value = I18n.t(values[1], scope: 'booleans', default: '')

        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: i18n_scope),
            old_value: old_value,
            new_value: new_value
          }
        )
      end

      # Returns a String with the newline escape sequences normalized.
      def normalize_line_endings(value)
        if value.is_a?(Hash)
          value.values.map { |subvalue| normalize_line_endings(subvalue) }
        else
          Decidim::ContentParsers::NewlineParser.new(value, context: {}).rewrite
        end
      end

      # Private: fetches project from resource (version variable)
      def project
        @project ||= Project.find_by(id: version.item_id)
      end
    end
  end
end
