# frozen_string_literal: true

Decidim::ActionLogger.class_eval do

  private

  # Overwritten Decidim method
  #
  # Private: Defines some extra data that will be saved in the action log `extra`
  # field.
  # Changed, so the user name would return anonymous version if needed.
  #
  # Returns a Hash.
  def extra_data
    {
      component: {
        manifest_name: component.try(:manifest_name),
        title: title_for(component)
      }.compact,
      participatory_space: {
        manifest_name: participatory_space_manifest_name,
        title: title_for(participatory_space)
      }.compact,
      resource: {
        title: title_for(resource)
      }.compact,
      user: {
        ip: user.current_sign_in_ip,
        name: user.public_name(true),
        nickname: user.nickname
      }.compact
    }.deep_merge(resource_extra)
  end
end
