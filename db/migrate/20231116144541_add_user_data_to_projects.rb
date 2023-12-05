# frozen_string_literal: true

class AddUserDataToProjects < ActiveRecord::Migration[5.2]
  require 'ruby-progressbar'

  def change
    add_column :decidim_projects_projects, :author_data, :jsonb, default: {}
    add_column :decidim_projects_projects, :coauthor1_data, :jsonb, default: {}
    add_column :decidim_projects_projects, :coauthor2_data, :jsonb, default: {}

    reversible do |dir|
      dir.up do
        # copy_users_data_to_projects
      end

      dir.down do
        Decidim::Projects::Project.update_all(author_data: {}, coauthor1_data: {}, coauthor2_data: {})
      end
    end
  end

  private

  def copy_users_data_to_projects
    all_projects = Decidim::Projects::Project.all
    # Creating progress bar for very long migration..
    progress = ProgressBar.create(total: all_projects.count, format: 'Progress: %a %p%% <%B>', smoothing: 1)

    all_projects.each do |project|
      author = project.creator
      coauthor1 = project.coauthorship_one
      coauthor2 = project.coauthorship_two

      project.update(author_data: user_data_for(author))
      project.update(coauthor1_data: user_data_for(coauthor1)) if coauthor1.present?
      project.update(coauthor2_data: user_data_for(coauthor2)) if coauthor2.present?

      progress.increment
    end
  end

  def user_data_for(coauthorship)
    author = coauthorship.author
    {
      first_name: author.first_name,
      last_name: author.last_name,
      phone_number: author.phone_number,
      gender: author.gender,
      street: author.street,
      street_number: author.street_number,
      flat_number: author.flat_number,
      zip_code: author.zip_code,
      city: author.city,
      email: author&.email,
      # zgody
      show_author_name: author.show_my_name,
      inform_author_about_implementations: author.inform_me_about_proposal
    }
  end
end
