# frozen_string_literal: true

EtiquetteValidator.class_eval do

  private

  def validate_caps(record, attribute, value)
    if value.is_a?(Hash)
      return if value['pl'].blank?
      return if value['pl'].scan(/[A-Z]/).length < (value['pl'].length / 4)
    else
      return if value.scan(/[A-Z]/).length < (value.length / 4)
    end

    record.errors.add(attribute, options[:message] || :too_much_caps)
  end

  def validate_marks(record, attribute, value)
    if value.is_a?(Hash)
      return if value['pl'].blank?
      return if value['pl'].scan(/[!?¡¿]{2,}/).empty?
    else
      return if value.scan(/[!?¡¿]{2,}/).empty?
    end

    record.errors.add(attribute, options[:message] || :too_many_marks)
  end

  def validate_caps_first(record, attribute, value)
    if value.is_a?(Hash)
      return if value['pl'].blank?
      return if value['pl'].scan(/\A[a-z]{1}/).empty?
    else
      return if value.scan(/\A[a-z]{1}/).empty?
    end

    record.errors.add(attribute, options[:message] || :must_start_with_caps)
  end
end
