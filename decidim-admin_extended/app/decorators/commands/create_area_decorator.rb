# frozen_string_literal: true

# A command with all the business logic when creating an area
Decidim::Admin::CreateArea.class_eval do

  # OVERWRITTEN DECIDIM METHOD
  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if the form wasn't valid and we couldn't proceed.
  #
  # Returns nothing.
  def call
    return broadcast(:invalid) if form.invalid?

    res = create_area

    if res
      broadcast(:ok)
    else
      form.errors.add(:icon, @area.errors[:icon]) if @area.errors.include? :icon
      broadcast(:invalid)
    end
  end

  private

  # OVERWRITTEN DECIDIM METHOD
  # added custom attribute:
  # icon - allows setting up custom icon for Area
  def create_area
    @area = Decidim::Area.new(
      name: form.name,
      organization: form.organization,
      area_type: form.area_type,
      icon: form.icon.presence || nil
    )
    return unless @area.valid?

    Decidim.traceability.create!(
      Decidim::Area,
      form.current_user,
      name: form.name,
      organization: form.organization,
      area_type: form.area_type,
      active: form.active,
      icon: form.icon.presence || nil
    )
    true
  end
end
