# frozen_string_literal: true

Decidim::PagesController.class_eval do
  helper_method :faq_groups
  helper_method :contact_info_groups
  helper_method :budget_info_groups

  def index
    redirect_to '/pages/o-budzecie'
  end

  private

  # Return groups with faq
  def faq_groups
    @faq_groups ||= Decidim::AdminExtended::FaqGroup.sorted_by_weight.published.includes(:faqs)
  end

  # Return groups with contacts
  def contact_info_groups
    @contact_info_groups ||= Decidim::AdminExtended::ContactInfoGroup.published.includes(:contact_info_positions)
  end

  # Return groups with budget info
  def budget_info_groups
    @budget_info_groups ||= Decidim::AdminExtended::BudgetInfoGroup.published.includes(:published_budget_info_positions)
  end

end