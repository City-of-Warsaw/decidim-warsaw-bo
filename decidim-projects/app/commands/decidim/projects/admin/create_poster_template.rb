# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when an admin creates poster template.
    class CreatePosterTemplate < Rectify::Command

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        create_poster_template
        broadcast(:ok)
      end

      private

      attr_reader :form, :poster_template

      # Private method
      #
      # Creates poster_template
      def create_poster_template
        @poster_template = Decidim::Projects::PosterTemplate.create(poster_template_attributes)
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
          background_file: form.background_file,
          project_title_x: form.project_title_x,
          project_title_y: form.project_title_y,
          project_title_width: form.project_title_width,
          project_title_height: form.project_title_height,
          project_title_css: form.project_title_css,
          project_area_x: form.project_area_x,
          project_area_y: form.project_area_y,
          project_area_width: form.project_area_width,
          project_area_height: form.project_area_height,
          project_area_css: form.project_area_css,
          project_number_x: form.project_number_x,
          project_number_y: form.project_number_y,
          project_number_width: form.project_number_width,
          project_number_height: form.project_number_height,
          project_number_css: form.project_number_css,
          sample_title: form.sample_title,
          sample_project_number: form.sample_project_number,
          sample_project_area: form.sample_project_area,
          body_css: form.body_css
        }
      end
    end
  end
end
