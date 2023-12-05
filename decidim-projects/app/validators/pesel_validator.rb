# frozen_string_literal: true

# PeselVerificator handles the
class PeselValidator < ActiveModel::EachValidator

  # value - pesel string
  def validate_each(record, attribute, value)
    pesel = Decidim::Projects::PeselValue.new(record, value)

    if options.key?(:pass_with_errors) && record.respond_to?(:pesel_warnings)
      record.pesel_warnings = pesel.warnings_collection
    else
      # we set only one of the errors, cause they go one after another
      if !pesel.has_proper_value?
        record.errors.add(attribute, :not_eleven_digits_number)
      elsif !pesel.has_proper_control_value?
        record.errors.add(attribute, :not_eleven_digits_number)
      elsif !pesel.has_valid_date_structure?
        record.errors.add(attribute, :not_eleven_digits_number)
      elsif !pesel.date_is_in_the_past?
        record.errors.add(attribute, :date_is_not_in_the_past)
      elsif pesel.pesel_already_used?
        record.errors.add(attribute, :pesel_used)
      end
    end
  end
end