# frozen_string_literal: true

Decidim::ContentBlocks::MetricsCell.class_eval do
  def show
    render :show_new
  end

  def costs
    Decidim::AdminExtended::BudgetInfoPosition.published_on_main_page.sorted_by_weight.with_attached_file.first(9)
  end

  def cost_page
    Decidim::StaticPage.find_by(slug: 'ile-kosztuje-miasto')
  end
end
