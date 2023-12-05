# frozen_string_literal: true

Decidim::CreateReport.class_eval do

  private

  # Overwritten decidim method
  # Changed participatory space moderators to admins only
  def participatory_space_moderators
    @participatory_space_moderators ||= Decidim::User.admins
  end
end