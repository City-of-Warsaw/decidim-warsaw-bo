# frozen_string_literal: true

module Decidim
  Scope.class_eval do
    include TranslatableAttributes

    belongs_to :department,
               foreign_key: "department_id",
               class_name: "Decidim::AdminExtended::Department",
               optional: true
    has_many :scope_budgets,
             class_name: 'Decidim::ProcessesExtended::ScopeBudget',
             foreign_key: 'decidim_scope_id',
             dependent: :delete_all

    scope :active, -> { where.not(id: nil) }
    scope :by_position, -> { order position: :asc }

    # public method that returns color associated with scope
    def color
      organization.colors['primary']
    end

    def scope_with_type
      if scope_type
        "#{translated_attribute(scope_type.name)} - #{translated_attribute(name)}"
      else
        translated_attribute(name)
      end
    end

    def citywide?
      code == 'om'
    end

    def self.citywide
      find_by code: 'om'
    end
  end
end
