# frozen_string_literal: true

Decidim::AuthorCell.class_eval do
  def profile_inline
    render :profile_inline_new
  end

  def profile_path?
    if model.respond_to?(:nickname) && model.nickname.present?
      model.show_my_name
    else
      false
    end
  end

  def author_name
    project = find_project

    if project && project.created_by?(model)
      "#{model.public_name(false)} - Autor projektu"
    elsif project && project.authored_by?(model)
      "#{model.public_name(false)} - Współautor projektu"
    else
      model.public_name(true)
    end
  end

  def find_project
    if params[:controller] == "decidim/projects/projects"
      Decidim::Projects::Project.find_by(id: params[:id])
    else
      nil
    end
  end
end
