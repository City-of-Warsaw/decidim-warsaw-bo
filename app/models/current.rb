# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :actual_edition
  attribute :actual_edition_tmp

  # return actual edition (participatory process)
  def actual_edition
    self.actual_edition_tmp ||= Decidim::ParticipatoryProcess.published.order('edition_year ASC, published_at ASC').last
    actual_edition_tmp
  end

  # return current organization
  def organization
    @organization ||= Decidim::Organization.first
  end
end