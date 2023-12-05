# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Meritorical Evaluation in admin panel.
      class MeritoricalEvaluationForm  < Form
        include Decidim::AttachmentAttributes
        include MeritoricalEvaluationFieldsDefinition

        # define attribute and validations
        MERITORICAL_FIELDS.each do |f|
          if f[:type] == 'radio'
            attribute f[:name], Integer
            attribute "#{f[:name]}_comment", String
            validates f[:name], presence: {  message: 'pole nie może być puste albo musi posiadać uwagi' }, if: Proc.new { |obj| obj.send("#{f[:name]}_comment").blank? }

          elsif f[:type] == 'radio2'
            f[:fields].each do |ff|
              attribute ff[:name], Integer
              validates ff[:name], presence: {  message: 'pole nie może być puste albo musi posiadać uwagi' }, if: Proc.new { |obj| obj.send("#{f[:name]}_comment").blank? }
            end
            attribute "#{f[:name]}_comment", String

          elsif f[:type] == 'text'
            attribute f[:name], String
          end
        end

        attribute :notes, String # Dodatkowe informacje
        attribute :result, Integer
        attribute :result_description, String
        attribute :project_implementation_effects, String
        attribute :signum_number, String
        attribute :unit_name, String
        attribute :verifier_name, String
        attribute :verification_date, String
        attribute :accept_user_name, String
        attribute :accept_date, String

        attribute :changes_info_send, Boolean
        attribute :changes_info_date, String
        attribute :changes_info_method, Integer
        attribute :changes_info_notes, String
        attribute :changes_info_agreement, Integer

        attachments_attribute :documents # zdjęcia
        attribute :remove_documents, [Integer]

        validates :estimate,
                  presence: { message: 'w przypadku pozytywnego wyniku oceny merytorycznej pole kosztorys musi być wypełnione' },
                  if: Proc.new { |obj| obj.result == 1 }
        validates :result_description,
                  presence: {  message: 'w przypadku negatywnego wyniku oceny merytorycznej uzasadnienie negatywnej oceny projektu musi zostać wypełnione' },
                  if: Proc.new { |obj| obj.result == 2 }
        validates :project_implementation_effects,
                  presence: {  message: 'w przypadku pozytywnego wyniku oceny merytorycznej skutki realizacji projektu muszą być wypełnione' },
                  if: Proc.new { |obj| obj.result == 1 }
        validates :verification_date, presence: true

        # Public: maps meritorical evaluation fields into FormObject attributes
        def map_model(model)
          self.id = model.id
          self.notes = model.details["notes"]
          self.result = model.details["result"]
          self.result_description = model.details["result_description"]
          self.project_implementation_effects = model.details["project_implementation_effects"]
          self.signum_number = model.details["signum_number"]
          self.unit_name = model.details["unit_name"]
          self.verifier_name = model.details["verifier_name"]
          self.verification_date = model.details["verification_date"]
          self.accept_user_name = model.details["accept_user_name"]
          self.accept_date = model.details["accept_date"]
          MERITORICAL_FIELDS.each do |f|
            if f[:type] == 'radio'
              self.send("#{f[:name]}=", model.details[f[:name].to_s])
              self.send("#{f[:name]}_comment=", model.details["#{f[:name]}_comment"])
            elsif f[:type] == 'radio2'
              f[:fields].each do |ff|
                self.send("#{ff[:name]}=", model.details[ff[:name].to_s])
              end
              self.send("#{f[:name]}_comment=", model.details["#{f[:name]}_comment"])
            elsif f[:type] == 'text'
              self.send("#{f[:name]}=", model.details[f[:name].to_s])
            end
          end
        end

        def attributes
          {
            notes: notes,
            result: result,
            result_description: result_description,
            project_implementation_effects: project_implementation_effects,
            signum_number: signum_number,
            unit_name: unit_name,
            verifier_name: verifier_name,
            verification_date: verification_date,
            accept_user_name: accept_user_name,
            accept_date: accept_date,

            all_changes_info: actualized_changes_info,
          }.tap do |h|
            MERITORICAL_FIELDS.each do |f|
              field = f[:name]
              field_comment = "#{f[:name]}_comment"

              case f[:type]
              when 'radio'
                h[field]         = self.send(field)
                h[field_comment] = self.send(field_comment)
              when 'radio2'
                f[:fields].each do |ff|
                  h[ff[:name]] = self.send(ff[:name])
                end
                h[field_comment] = self.send(field_comment)
              when 'text'
                h[field] = self.send(field)
              end
            end
          end
        end

        # add changes_info to Array,
        def actualized_changes_info
          return all_changes_info if changes_info_send.blank? ||
            changes_info_date.blank? ||
            changes_info_method.blank? ||
            changes_info_agreement.blank?

          if changes_info_send.present?
            eci = all_changes_info << [changes_info_date, changes_info_method, changes_info_notes, changes_info_agreement]
          end
          eci
        end

        def all_changes_info
          return [] unless meritorical_evaluation

          meritorical_evaluation.details["all_changes_info"].presence || []
        end

        def meritorical_evaluation
          Decidim::Projects::Evaluation.find_by(id: id)
        end

      end
    end
  end
end
