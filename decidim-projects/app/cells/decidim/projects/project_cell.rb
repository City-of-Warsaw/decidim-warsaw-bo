# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Projects
    # This cell renders the project card for an instance of a Project
    # the default size is the Medium Card (:m)
    class ProjectCell < Decidim::ViewModel
      include Decidim::Proposals::ProposalCellsHelper
      include Cell::ViewModel::Partial
      include Messaging::ConversationHelper

      # public method
      #
      # renders cell view based on the methid card_size
      def show
        cell card_size, model, options
      end

      private

      # private method
      #
      # sets the card size pased on the
      # value of @option[:size]
      #
      # returns String - cell path
      def card_size
        case @options[:size]
        when :highlighted_list_item
          # slider
          "decidim/projects/project_highlighted_list_item"
        when :list_item
          # list
          "decidim/projects/project_list_item"
        when :list_result_item
          # results list
          "decidim/projects/result_list_item"
        when :voting_list_item
          # list on voting form
          "decidim/projects/voting_list_item"
        when :s
          "decidim/projects/project_s"
        else
          # default - tiles
          "decidim/projects/project_m"
        end
      end

      # private method
      #
      # returns path to model (Decidim::Projects::Project instance)
      def resource_path
        resource_locator(model).path
      end

      # private method
      #
      # returns Object - participatory_space for model (Decidim::Projects::Project instance)
      def current_participatory_space
        model.component.participatory_space
      end

      # private method
      #
      # returns Object - component for model (Decidim::Projects::Project instance)
      def current_component
        model.component
      end

      # private method
      #
      # returns String - translated name of the component
      # for model (Decidim::Projects::Project instance)
      def component_name
        translated_attribute model.component.name
      end

      # private method
      #
      # returns String - humanized model_name of the component
      # for model (Decidim::Projects::Project instance)
      def component_type_name
        model.class.model_name.human
      end

      # private method
      #
      # returns String - translated name of the participatory_space
      # for model (Decidim::Projects::Project instance)
      def participatory_space_name
        translated_attribute current_participatory_space.title
      end

      # private method
      #
      # returns String - humanized model_name of the participatory_space
      # for model (Decidim::Projects::Project instance)
      def participatory_space_type_name
        translated_attribute current_participatory_space.model_name.human
      end


      # private method
      #
      # OVERWRITING METHOD
      # Builds data be added to a _path or _url method as params
      #
      # returns nil
      def filter_link_params
        nil
      end
    end
  end
end
