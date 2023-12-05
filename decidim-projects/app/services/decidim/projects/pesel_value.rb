# frozen_string_literal: true

module Decidim
  module Projects
    # Class holds all the logict to verify and retrieve data from pesel number.
    #
    # All the logic was based on the GOV page:
    # https://obywatel.gov.pl/pl/dokumenty-i-dane-osobowe/czym-jest-numer-pesel
    class PeselValue
      WEIGHTS = [1, 3, 7, 9, 1, 3, 7, 9, 1, 3]

      # Public: Initializes the service.
      # vote     - Vote or record in validation
      def initialize(record, pesel)
        @pesel = pesel
        @record = record
      end

      # Public method checks all of the pesel requirements
      #
      # Returns Boolean
      def valid?
        has_proper_value? &&
          has_proper_control_value? &&
          has_valid_date_structure? &&
          date_is_in_the_past?
      end

      # Public method checks if pesel is an 11 digit number
      #
      # Returns Boolean
      def has_proper_value?
        return false if @pesel.blank?

        !!(@pesel =~ /^[0-9]{11}$/)
      end

      # Public method checks if pesel's last digit (control number) is equal to the control number from the
      # provided function
      #
      # Returns Boolean
      def has_proper_control_value?
        return unless has_proper_value?

        control_digit == control_number
      end

      # Public method calculating the control number based on the given pesel number.
      #
      # Calclutaions are as follows:
      # - Each element of pesel is multiplied with the corresponding digit in WEIGHTS constant
      # - Results of the multiplications are summed
      # - Last digit of sum is substracted from 10
      # - Last digit of substraction (in nace it equals 10) is the control number
      #
      # Returns Integer
      def control_number
        arrayed_pesel = @pesel.split("").map(&:to_i)
        sum = 0
        10.times do |i|
          sum += (WEIGHTS[i] * arrayed_pesel[i])
        end
        (10 - sum.modulo(10)).modulo(10)
      end

      # Public method checks if data retrieved from pesel is valid to create a DateTime object
      #
      # Returns Boolean
      def has_valid_date_structure?
        return unless has_proper_value?

        check_date = Date.new(year,month,day) rescue false

        return false unless check_date

        case month
        when 4, 6, 9, 11
          return !(day > 30)
        when 2
          y = year
          if y.modulo(4) == 0
            return !(day > 29)
          else
            return !(day > 28)
          end
        else
          true
        end
      end

      # Public method checks if date created from the pesel is in the past
      #
      # Returns Boolean
      def date_is_in_the_past?
        return unless has_valid_date_structure?

        birth_date.past?
      end

      # Public method retrieving year from the pesel number
      #
      # Returns Integer
      def year
        @year ||= case
                  when month_digits >= 1 && month_digits <= 12
                    # 1900
                    1900 + year_digits
                  when month_digits >= 21 && month_digits <= 32
                    # 2000
                    2000 + year_digits
                  when month_digits >= 81 && month_digits <= 92
                    # 1800
                    1800 + year_digits
                  when month_digits >= 41 && month_digits <= 52
                    # 2100
                    2100 + year_digits
                  when month_digits >= 61 && month_digits <= 72
                    # 2200
                    2200 + year_digits
                  else
                    0
                  end
      end

      # Public method retrieving month from the pesel number
      #
      # Returns Integer
      def month
        @month ||= case
                   when month_digits >= 1 && month_digits <= 12
                     # 1900
                     month_digits
                   when month_digits >= 21 && month_digits <= 32
                     # 2000
                     month_digits - 20
                   when month_digits >= 81 && month_digits <= 92
                     # 1800
                     month_digits - 80
                   when month_digits >= 41 && month_digits <= 52
                     # 2100
                     month_digits - 40
                   when month_digits >= 61 && month_digits <= 72
                     # 2200
                     month_digits - 60
                   else
                     # to return error
                     13
                   end
      end

      # Public method retrieving day from the pesel number
      #
      # Returns Integer
      def day
        @day ||= @pesel[4..5].to_i
      end

      # Public method retrieving gender from the pesel number
      #
      # Returns String
      def gender
        gender_digit.odd? ? 'male' : 'female'
      end

      def age
        now = Time.now.to_date
        now.year - birth_date.year - ((now.month > birth_date.month || (now.month == birth_date.month && now.day >= birth_date.day)) ? 0 : 1)
      end

      def birth_date
        @birth_date ||= Date.new(year, month, day)
      end

      def warnings_collection
        translation_scope = 'activerecord.errors.models.vote_card.attributes.pesel_number'
        pw_collection = {}

        if !has_proper_value?
          pw_collection[:not_eleven_digits_number] = I18n.t('not_eleven_digits_number', scope: translation_scope)
        elsif !has_valid_date_structure?
          pw_collection[:has_valid_date_structure] = I18n.t('not_proper_date_structure', scope: translation_scope)
        elsif !date_is_in_the_past?
          pw_collection[:date_is_in_the_past] = I18n.t('date_is_not_in_the_past', scope: translation_scope)
        elsif !has_proper_control_value?
          pw_collection[:wrong_control_digit] = I18n.t('wrong_control_digit', scope: translation_scope)
        end

        pw_collection[:pesel_used] = I18n.t('pesel_used', scope: translation_scope) if pesel_already_used?
        pw_collection
      end

      def pesel_already_used?(list_of_used_pesels=nil)
        return if @pesel.blank?

        list_of_used_pesels ||= get_list_of_used_pesels

        if Decidim::Projects::VoteCard::STATUSES_ACCEPTED.include?(@record.status)
          # if the record has a status set, double it
          occurrences = list_of_used_pesels.count{ |m| m == @pesel }
          occurrences > 1
        else
          # link_sent waiting
          list_of_used_pesels.include? @pesel
        end
      end

      def month_digits
        @month_digits ||= @pesel[2..3].to_i
      end

      def year_digits
        @year_digits ||= @pesel[0..1].to_i
      end

      def gender_digit
        @gender_digit ||= @pesel[9].to_i
      end

      def control_digit
        @control_digit ||= @pesel[10].to_i
      end

      def get_list_of_used_pesels
        component = @record.component
        all_accepted_votes = Decidim::Projects::VoteCard.where(component: component).accepted_votes
        all_accepted_votes.with_pesel.pluck(:pesel_number)
      end
    end
  end
end
