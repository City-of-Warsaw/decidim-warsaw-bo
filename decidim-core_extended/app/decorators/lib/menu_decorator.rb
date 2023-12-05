# frozen_string_literal: true

Decidim::Menu.class_eval do

  def item(label, url, options = {})
    hidden_labels = ['Zespoły', 'Assemblies', 'Procesy', 'Processes']
    @items << Decidim::MenuItem.new(label, url, options) unless (hidden_labels.include?(label) && self.name == :menu)
  end

  def name
    @name
  end
end
