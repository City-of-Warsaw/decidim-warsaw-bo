# frozen_string_literal: true

Decidim::ContentBlocks::HowToParticipateCell.class_eval do
  include Decidim::ProcessesExtended::ApplicationHelper

  def show
    render :show_new
  end

  private

  def actual_edition
    Decidim::ParticipatoryProcess.actual_edition
  end

  def actual_edition_schedule_title
    # num = Decidim::ParticipatoryProcess.past.count + 1 # po wynikach pokazywalo 12 edycja - a jest 10ta
    num = Decidim::ParticipatoryProcess.where.not(published_at: nil).count
    t("decidim.pages.home.extended.how_to_participate", number: num).html_safe
  end
end
