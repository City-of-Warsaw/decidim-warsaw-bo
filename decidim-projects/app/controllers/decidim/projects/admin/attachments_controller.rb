# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows downloading attachments for project,
  # actual only used for endorsements, to limit for ad_admin and ad_coordinator
  # Another attachments: endorsements, various_files, consents, internal_documents
  class Admin::AttachmentsController < Admin::ApplicationController

    # returns file or redirect to project if user has no access
    def show
      if !current_user&.ad_admin? && !current_user&.ad_coordinator?
        project = endorsement.attached_to
        redirect_to project_path(project), alert: 'Brak uprawnień' and return
      end

      send_file endorsement.file.path, disposition: 'inline'
    end


    private

    def endorsement
      @endorsement ||= Decidim::Projects::Endorsement.find params[:id]
    end

  end
end
