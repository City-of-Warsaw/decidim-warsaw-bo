# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Reevaluation in admin panel.
      class ReevaluationForm  < Form
        include Decidim::AttachmentAttributes

        attribute :reevaluation_id, Integer
        # user_data
        attribute :reevaluator_department, String
        attribute :formal_appeal, Array
        attribute :meritorical_appeal, Array
        attribute :user_additional_appeal, String
        # reevaluation
        attribute :reevaluation_body, String
        attribute :reevaluation_result, Integer
        attribute :positive_reevaluation_body, String
        attribute :negative_reevaluation_body, String
        attribute :signum_number, String
        attribute :reevaluator_user_name, String
        attribute :reevaluation_date, String
        # zatwierdzenie oceny koordynator
        attribute :reevaluation_approve_name, String # nowe
        attribute :reevaluation_approve_date, String
        # zatwierdzenie oceny admin
        attribute :reevaluation_card_approve_body, String
        attribute :reevaluation_card_approve_date, String
        attribute :reevaluation_card_approve_name, String, default: 'Karolina Zdrodowska, Dyrektor Koordynator ds. przedsiębiorczości i dialogu społecznego'
        attribute :result, Integer

        attachments_attribute :documents # zdjęcia
        attribute :remove_documents, [Integer]

        validates :reevaluation_body, presence: true
        validates :reevaluation_date, presence: true

        validate :effects

        def effects
          errors.add(:reevaluation_result, 'Należy wybrać') if reevaluation_result.blank?
          errors.add(:positive_reevaluation_body, 'Dla oceny pozytywnej nalezy podać skutki realizajci projektu') if positive_reevaluation_result? && positive_reevaluation_body.blank?
          errors.add(:negative_reevaluation_body, 'Dla oceny negatywnej należy podać jej przyczynę') if negative_reevaluation_result? && negative_reevaluation_body.blank?
        end

        def positive_reevaluation_result?
          reevaluation_result == 1
        end

        def negative_reevaluation_result?
          reevaluation_result == 2
        end

        def formal_elements
          mapped = ['on_time', 'sum_of_authors', 'warsaw_authors', 'all_necessary_elements', 'endorsment_attached', 'complete_endorsment_attached',
                    'consent_attached', 'etiquette', 'proper_scope', 'name_and_body_adequacy'].map do |el|
            [I18n.t(el, scope: 'decidim.reevaluations.formal_appeal.attrs').html_safe, el]
          end

          mapped
        end

        def formal_element_checked?(el)
          formal_appeal.member?(el)
        end

        def meritorical_elements
          mapped = ['law_ok', 'warsaw_plan_inclusion', 'warsaw_property', 'author_law_ok', 'technical_ok', 'no_collision', 'no_supreme_collision',
                    'no_science_fiction', 'permits_in_year_inclusion', 'in_year_inclusion', 'more_law_ok', 'free_to_use', 'availability_time',
                    'transparent_if_with_limitations', 'not_only_documents', 'in_one_phase', 'no_corpo_suggestion', 'in_value_limit'].map do |el|
            [I18n.t(el, scope: 'decidim.reevaluations.meritorical_appeal.attrs').html_safe, el]
          end

          mapped
        end

        def meritorical_element_checked?(el)
          meritorical_appeal.member?(el)
        end

        # Public: maps reevaluation fields into FormObject attributes
        def map_model(model)
          self.reevaluation_id = model.id

          self.reevaluator_department = model.details["reevaluator_department"]
          self.formal_appeal = model.details["formal_appeal"]
          self.meritorical_appeal = model.details["meritorical_appeal"]
          self.user_additional_appeal = model.details["user_additional_appeal"]

          self.reevaluation_body = model.details["reevaluation_body"]
          self.reevaluation_result = model.details["reevaluation_result"]
          self.positive_reevaluation_body = model.details["positive_reevaluation_body"]
          self.negative_reevaluation_body = model.details["negative_reevaluation_body"]
          self.signum_number = model.details["signum_number"]
          self.reevaluation_date = model.details["reevaluation_date"]
          self.reevaluator_user_name = model.details["reevaluator_user_name"]
          self.reevaluation_approve_name = model.details["reevaluation_approve_name"]
          self.reevaluation_approve_date = model.details["reevaluation_approve_date"]
          # zatwierdzenie oceny admin
          self.reevaluation_card_approve_body = model.details["reevaluation_card_approve_body"]
          self.reevaluation_card_approve_date = model.details["reevaluation_card_approve_date"]
          self.reevaluation_card_approve_name = model.details["reevaluation_card_approve_name"]
          self.result = model.details["result"]
        end

        def attributes
          {
            reevaluator_department: reevaluator_department,
            formal_appeal: formal_appeal,
            meritorical_appeal: meritorical_appeal,
            user_additional_appeal: user_additional_appeal,
            # reevaluation
            reevaluation_body: reevaluation_body,
            reevaluation_result: reevaluation_result,
            positive_reevaluation_body: positive_reevaluation_body,
            negative_reevaluation_body: negative_reevaluation_body,
            signum_number: signum_number,
            reevaluation_date: reevaluation_date,
            reevaluator_user_name: reevaluator_user_name,
            # zatwierdzenie oceny koordynator
            reevaluation_approve_name: reevaluation_approve_name,
            reevaluation_approve_date: reevaluation_approve_date,
            # zatwierdzenie oceny mozliwe tylko przez admina
            reevaluation_card_approve_body: reevaluation_card_approve_body,
            reevaluation_card_approve_date: reevaluation_card_approve_date,
            reevaluation_card_approve_name: reevaluation_card_approve_name,
            result: result
          }
        end

        def reevaluation
          Decidim::Projects::Evaluation.find_by(id: reevaluation_id)
        end
      end
    end
  end
end
