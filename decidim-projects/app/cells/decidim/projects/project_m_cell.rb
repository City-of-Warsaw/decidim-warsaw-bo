# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Projects
    # This cell renders a project with its M-size card.
    class ProjectMCell < Decidim::CardMCell
      include Decidim::Proposals::ProposalCellsHelper
      include ActionView::Helpers::NumberHelper
      include Decidim::Projects::ApplicationHelper

      delegate :current_locale, to: :controller

      # public method
      #
      # returns badge view if has_badge? is true
      def badge
        render if has_badge?
      end

      # public method
      #
      # returns renders categories view
      def categories
        render :categories
      end

      # public method
      #
      # returns Integer - count of categories that are to be shown
      def categories_number
        5
      end

      # public method
      #
      # returns Object - Decidim::Scope
      def scope
        model.scope
      end

      # public method
      #
      # returns String - based on the models *implementation status*
      #                  method returns one of the predefined hex colors
      def scope_color
        s = model.implementation_status
        case s
        when 0
          # abandoned - odstapiono
          # '#E4E4E4'
          '373737'
        when 1, 2, 3, 4
          # in_progress - w trakcie realizacji
          '1F72AE'
        when 5
          # finished - zrealizowano
          '5A7C1B'
        else
          '1F72AE'
        end
      end

      def scope_color_class
        "scope-#{scope_color}"
      end

      # public method
      #
      # params: color [String] - required, color name
      # returns String - based on the color parameter
      #                  method returns one of the predefined color class
      def icon_color_class(color)
        case color
        when 'blue'
          'icon-blue'
        when 'gray'
          'icon-gray'
        when 'green'
          'icon-green'
        else
          'icon-default'
        end
      end

      # public method
      #
      # params: color [String] - optional
      #
      # returns String - HTML code for the view with model data:
      #   <div class='scope-and-number'>
      #      <span style='color: #000000'>SCOPE_NAME</span>
      #      / ESOG_NUMBER
      #   </div>
      def scope_and_number(color = nil)
        final_color_class = color.present? ? icon_color_class(color) : scope_color_class
        content_tag 'div', class: 'scope-and-number' do
          (content_tag 'span', class: final_color_class do
            translated_attribute scope&.name
          end) +
          " / #{model.esog_number}"
        end
      end

      # public method
      #
      # determines if cell is a preview based on options[:preview] value
      #
      # returns Boolean
      def preview?
        options[:preview]
      end

      # public method
      #
      # returns String - truncated to 100 characters model title
      def title
        html_truncate decidim_html_escape(present(model).title), length: 100, escape: false
      end

      # public method
      #
      # returns String - sanitized model body
      def body
        html_truncate decidim_sanitize(present(model).body), length: 180, escape: false
      end

      # public method
      #
      # returns Boolean - based on model publication state
      def has_state?
        model.published?
      end

      # public method
      #
      # returns Boolean - based on model publication state
      def has_badge?
        published_state? || withdrawn?
      end

      # public method
      #
      # returns Boolean - based on model publication state
      def has_link_to_resource?
        model.published?
      end

      # public method
      # OVERWRITTEN METHOD
      #
      # returns true
      def has_footer?
        true
      end

      # public method
      #
      # returns String - stripped from tags truncated to 100 characters model body
      def description
        strip_tags(body).truncate(100, separator: /\s/)
      end

      # public method
      #
      # returns String - collection of classes
      def badge_classes
        return super unless options[:full_badge]

        state_classes.concat(["label", "project-status"]).join(" ")
      end

      # public method
      #
      # returns Array - default statuses
      def base_statuses
        @base_statuses ||= begin
          [:comments_count]
        end
      end

      # public method
      #
      # returns Array - all statuses
      def statuses
        return [] if preview?
        return base_statuses if model.draft?
        return [:creation_date] + base_statuses if !has_link_to_resource? || !can_be_followed?

        [:creation_date, :follow] + base_statuses
      end

      # public method
      #
      # method depends on the controller action that called the Cell View
      #
      # for action *realizations* -> method translates implementation status
      #
      # for different action -> method calls public_status method with model as it's param
      #
      # returns String - translation for status
      def status
        if params[:action] == 'realizations'
          case model.implementation_status
          when 0
            # abandoned - odstapiono
            s = 'abandoned'
          when 1, 2, 3, 4
            # in_progress - w trakcie realizacji
            s = 'in_progress'
          when 5
            # finished - zrealizowano
            s = 'finished'
          else
            s = 'in_progress'
          end
          I18n.t(s, scope: "decidim.admin.filters.projects.implementation_state_eq.values")
        else
          # model.state.present? ? I18n.t(model.state, scope: "decidim.admin.filters.projects.state_eq.values") : ''
          public_status(model)
        end
      end

      # public method
      #
      # returns String - model.state
      def status_class
        model.state
      end

      # public method
      #
      # returns String - model.state
      def creation_date_status
        explanation = tag.strong(t("activemodel.attributes.common.created_at"))
        "#{explanation}<br>#{l(model.published_at.to_date, format: :decidim_short)}"
      end

      # public method
      # OVERWRITTEN METHOD
      #
      # returns false
      def can_be_followed?
        false
      end

      # public method
      #
      # returns true
      def has_image?
        true
      end

      def parsed_resource_path(vote=nil)
        vote ? "#{resource_path.split('?').first}?step=#{step}&voting=#{vote_token}" : resource_path.split('?').first
      end

      def step
        options[:step]
      end

      def vote_token
        options[:voting_token]
      end

      # public method
      #
      # returns:
      #     String - path to attachment
      #     nil - if no image
      def resource_image_path
        return unless resource_image

        @resource_image_path ||= if resource_image.is_a? Decidim::Projects::ImplementationPhoto
                                   Rails.application.routes.url_helpers.rails_representation_path(resource_image.big, only_path: true)
                                 else
                                   resource_image.url
                                 end
      end

      # public method
      #
      # returns:
      #     Object - Image from model
      #     nil - if no image found
      def resource_image
        @resource_image ||= if model.implementation_photos.any?
                              model.implementation_photos.reorder(main_attachment: :desc).first
                            elsif model.participatory_space.hero_image
                              model.participatory_space.hero_image
                            else
                              nil
                            end
      end
    end
  end
end
