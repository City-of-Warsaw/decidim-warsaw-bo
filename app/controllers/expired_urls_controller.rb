# frozen_string_literal: true

class ExpiredUrlsController < ApplicationController

  # Redirect 'Moved permanently' old project urls to new one
  # exemple old URL:
  #   http://localhost:3000/projekt/22884?user=
  def redirect_to_project
    if project
      redirect_to Decidim::ResourceLocatorPresenter.new(project).path, status: 301
    else
      flash[:alert] = 'Nie znaleziono szukanego projektu.'
      redirect_to decidim_projects.projects_path
    end
  end

  private

  def project
    @project ||= Decidim::Projects::Project.find_by old_id: params[:id]
  end
end
