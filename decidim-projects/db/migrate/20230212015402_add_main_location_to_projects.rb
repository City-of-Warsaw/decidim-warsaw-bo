class AddMainLocationToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_projects_projects, :main_location, :jsonb

    reversible do |direction|
      direction.up do

        1.tap do
          Decidim::Projects::Project.find_each do |project|
            if project.locations.any?
              project.update_column(
                :main_location,
                lat: project.locations.first[1]['lat'],
                lng: project.locations.first[1]['lng']
              )
            end
          end
        end

      end
    end

  end
end
