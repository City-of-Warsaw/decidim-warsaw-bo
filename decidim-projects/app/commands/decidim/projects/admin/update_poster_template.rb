# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when an admin updates poster template.
    class UpdatePosterTemplate < Rectify::Command

      # Public: Initializes the command.
      #
      # form            - A form object with the params.
      # poster_template - the poster_template to update
      def initialize(poster_template, form)
        @poster_template = poster_template
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      # - :invalid if there is no project.
      # - :invalid if attachments are invalid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_poster_template
        broadcast(:ok, poster_template)
      end

      private

      attr_reader :form, :poster_template

      # Private method
      #
      # Updates poster_template
      def update_poster_template
        @poster_template.update(poster_template_attributes)
      end

      # Private: poster template attributes
      #
      # returns Hash
      def poster_template_attributes
        {
          title: form.title,
          subtitle: form.subtitle,
          published: form.published,
          decidim_participatory_process_id: current_participatory_space.id,
          width: form.width,
          height: form.height,
          project_title_x: form.project_title_x,
          project_title_y: form.project_title_y,
          project_title_width: form.project_title_width,
          project_title_css: form.project_title_css,
          project_area_x: form.project_area_x,
          project_area_y: form.project_area_y,
          project_area_width: form.project_area_width,
          project_area_css: form.project_area_css,
          project_number_x: form.project_number_x,
          project_number_y: form.project_number_y,
          project_number_width: form.project_number_width,
          project_number_css: form.project_number_css,
          project_area_height: form.project_area_height,
          project_number_height: form.project_number_height,
          sample_title: form.sample_title,
          sample_project_number: form.sample_project_number,
          sample_project_area: form.sample_project_area,
          project_title_height: form.project_title_height,
          body_css: form.body_css
        }.tap do |hash|
          hash[:background_file] = form.background_file if form.background_file
        end
      end
    end
  end
end
