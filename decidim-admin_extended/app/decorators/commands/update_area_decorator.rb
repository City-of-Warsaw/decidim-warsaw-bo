# frozen_string_literal: true

Decidim::Admin::UpdateArea.class_eval do

  # overwritten method
  # expand it with double check validations and add to errors :icon
  def call
    return broadcast(:invalid) if form.invalid?

    update_area

    if @area.valid?
      broadcast(:ok)
    else
      form.errors.add(:icon, @area.errors[:icon]) if @area.errors.include? :icon
      broadcast(:invalid)
    end
  end

  private

  # overwritten method
  # expand it with double assigning attrs and next check validations
  def update_area
    @area.assign_attributes(attributes)
    return unless @area.valid?

    Decidim.traceability.update!(
      @area,
      form.current_user,
      attributes
    )
  end

  # overwritten method
  # added custom attributes
  def attributes
    {
      name: form.name,
      area_type: form.area_type,
      # custom
      active: form.active,
      icon: form.icon.presence || @area.icon,
      remove_icon: form.remove_icon
    }
  end
end
