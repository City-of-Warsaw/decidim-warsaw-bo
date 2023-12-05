# frozen_string_literal: true

Decidim::VersionAuthorCell.class_eval do

  def show
    render :show_new
  end

  def author_name
    project = find_project

    if project && project.created_by?(model)
      "#{model.public_name(false)} - Autor projektu"
    elsif project && project.authored_by?(model)
      "#{model.public_name(false)} - Współautor projektu"
    elsif model.is_a?(String)
      user_id = model.split(',')[0].split('=>')[1]
      user = Decidim::User.find_by(id: user_id)
      user ? user.public_name(true) : 'Administrator'
    else
      model.public_name(true)
    end
  end

  def find_project
    if params[:controller] == "decidim/projects/projects"
      Decidim::Projects::Project.find_by(id: params[:id])
    elsif params[:project_id].present?
      Decidim::Projects::Project.find_by(id: params[:project_id])
    else
      nil
    end
  end
end
