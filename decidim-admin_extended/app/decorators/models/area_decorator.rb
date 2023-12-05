# frozen_string_literal: true

# OVERWRITTEN DECIDIM MODEL
# Areas are used in Assemblies to help users know which is
# the Area of a participatory space.
# Model was expanded with:
# - has_many association to the transitive table
#   for many-to-many associations between Areas and Projects
# - Decidim logic for uploading icon files
Decidim::Area.class_eval do
  has_many :project_areas,
            class_name: "Decidim::Projects::ProjectArea",
            foreign_key: :decidim_area_id,
            dependent: :destroy

  mount_uploader :icon, Decidim::ImageUploader

  scope :active, -> { where(active: true) }
  scope :sorted_by_name, -> { order("name ->'pl' ASC") }
end
