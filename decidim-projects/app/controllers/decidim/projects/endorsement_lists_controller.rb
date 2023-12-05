# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows generating endorsement list for project
  class EndorsementListsController < Decidim::Projects::ApplicationController
    include Decidim::FormFactory

    layout false
    helper_method :participatory_process_header, :participatory_process_footer, :participatory_process_endorsement_logo

    def show
      unless project.can_generate_endorsement_list?
        redirect_to project, alert: 'Czas na generowanie listy już minął' and return
      end

      respond_to do |format|
        format.pdf do
          render pdf: "lista_poparcia_#{project.esog_number}", disposition: 'attachment'
        end
      end
    end

    # Blank endorsement list for next edition
    def actual_edition
      @edition_year = current_participatory_space.edition_year
      @project = nil

      respond_to do |format|
        format.pdf do
          render template: 'decidim/projects/endorsement_lists/show', pdf: "lista_poparcia_#{@edition_year}", disposition: 'attachment'
        end
      end
    end

    private

    def participatory_process_header
      headers = current_participatory_space.endorsement_list_setting.header_description
      headers = headers.gsub('%{process_year}', current_participatory_space.edition_year.to_s)
      return headers
    end

    def participatory_process_footer
      current_participatory_space.endorsement_list_setting.footer_description
    end

    def participatory_process_endorsement_logo
      ActiveStorage::Blob.service.send(:path_for, current_participatory_space.endorsement_list_setting.image_header.blob.key)
    end

    def project
      @project ||= Decidim::Projects::Project.published.not_hidden.find_by id: params[:project_id]
    end
  end
end
