# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to manage notes added to project in admin panel.
      class StatisticForm < Form
        attribute :participatory_process_id, Integer
        attribute :scope_id, Integer
        attribute :number_of_project_voters_0_18, Integer
        attribute :number_of_project_voters_19_24, Integer
        attribute :number_of_project_voters_25_34, Integer
        attribute :number_of_project_voters_35_44, Integer
        attribute :number_of_project_voters_45_64, Integer
        attribute :number_of_project_voters_65_100, Integer

        validates :scope_id, presence: true
        validates :participatory_process_id, presence: true
        validates :number_of_project_voters_0_18, numericality: { only_integer: true }
        validates :number_of_project_voters_19_24, numericality: { only_integer: true }
        validates :number_of_project_voters_25_34, numericality: { only_integer: true }
        validates :number_of_project_voters_35_44, numericality: { only_integer: true }
        validates :number_of_project_voters_45_64, numericality: { only_integer: true }
        validates :number_of_project_voters_65_100, numericality: { only_integer: true }
        # Public: maps project fields into FormObject attributes
        #
        def map_model(model)
          super
        end
      end
    end
  end
end
