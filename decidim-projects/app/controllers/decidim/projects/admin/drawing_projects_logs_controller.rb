# frozen_string_literal: true

module Decidim::Projects
  class Admin::DrawingProjectsLogsController < Admin::ApplicationController
    def show
      @drawing_log = Decidim::Projects::DrawingProjectsLog.find params[:id]

      respond_to do |format|
        format.pdf do
          render pdf: "wynik losowania", disposition: 'attachment'
        end
      end
    end
  end
end
