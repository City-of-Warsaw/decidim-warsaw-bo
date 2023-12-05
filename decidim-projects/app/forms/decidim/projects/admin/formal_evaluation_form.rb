# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Formal Evaluation in admin panel.
      class FormalEvaluationForm  < Form
        include Decidim::AttachmentAttributes
        include FormalEvaluationFieldsDefinition

        FORMAL_FIELDS.each do |f|
          attribute f[:name], Integer
          attribute "#{f[:name]}_corrected", Integer
        end

        attribute :user, Decidim::User
        attribute :evaluation_id, Integer

        attribute :additional_info, String
        attribute :result, Integer
        attribute :summons_date, String
        attribute :summons_method, String
        attribute :notes, String
        attribute :signum_number, String
        attribute :verifier_name, String
        attribute :verification_date, String

        attachments_attribute :documents # zdjęcia
        attribute :remove_documents, [Integer]

        validate :summon_is_proper

        def summon_is_proper
          return if summons_method.present? && summons_date.present?
          return if summons_method.nil? && summons_date.blank?

          if summons_method.blank? || summons_date.blank?
            errors.add(:summons_date, 'Należy podać następujace dane: datę i sposób przekazania wezwania')
          end
        end

        # Public: maps formal evaluation fields into FormObject attributes
        def map_model(model)
          self.result = model.details["result"]
          self.additional_info = model.details['additional_info']
          self.signum_number = model.details["signum_number"]
          self.verifier_name = model.details["verifier_name"].presence || user.name_and_surname
          self.verification_date = model.details["verification_date"]

          self.evaluation_id = model.id

          FORMAL_FIELDS.each do |f|
            self.send("#{f[:name]}=", model.details[f[:name].to_s])
            self.send("#{f[:name]}_corrected=", model.details["#{f[:name]}_corrected"])
          end
        end

        def attributes
          {
            additional_info: additional_info,
            result: result,
            all_summons: actualized_summons,
            signum_number: signum_number,
            verifier_name: verifier_name,
            verification_date: verification_date
          }.tap do |h|
            FORMAL_FIELDS.each do |f|
              field = f[:name]
              field_corrected = "#{f[:name]}_corrected"
              field_negative_reason = "#{f[:name]}_negative_reason"

              h[field]                 = self.send(field)
              h[field_corrected]       = self.send(field_corrected)
              h[field_negative_reason] = (self.send(field) == 2 && self.send(field_corrected).nil?) ? f[:negative_translation] : nil
            end
          end
        end

        def actualized_summons
          # note is not necessary
          return all_summons if summons_date.blank? || summons_method.blank?

          es = all_summons << [summons_date, summons_method, notes]
          es
        end

        def all_summons
          return [] unless formal_evaluation

          formal_evaluation.details['all_summons'].presence || []
        end

        def formal_evaluation
          Decidim::Projects::Evaluation.find_by(id: evaluation_id)
        end
      end
    end
  end
end
