# frozen_string_literal: true

module Decidim
  module CoreExtended
    class CostCell < Decidim::CardMCell
      include ActionView::Helpers::NumberHelper

      def show
        if @options[:size] == :page
          render :show_page
        else
          render :show
        end
      end

      private

      def title
        model.name
      end

      def description
        model.description
      end

      def value
        model.amount
      end

      def translation_name
        model[1]
      end

      def resource_image_path
        Rails.application.routes.url_helpers.rails_representation_path(model.thumbnail_180, only_path: true)
      end

      def has_image?
        model.file.attached?
      end

      def has_link_to_resource?
        false
      end

      def has_authors?
        false
      end
    end
  end
end
