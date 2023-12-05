# frozen_string_literal: true

require 'csv'
require 'charlock_holmes'

module Decidim
  module Projects
    module Admin
      # A command for import voters
      class ImportVoters < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, import succeed.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :invalid if there was problem with import.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            remove_all_voters if form.remove_voters_only?
            import_voters
            create_log(Decidim::Projects::VoteCard.first, :import_voters)
          end

          broadcast(:ok)
        end

        private

        attr_reader :form

        def import_voters
          return unless form.file

          remove_all_voters

          content = form.file.read
          detection = CharlockHolmes::EncodingDetector.detect(content)
          utf8_encoded_content = CharlockHolmes::Converter.convert(content, detection[:encoding], 'UTF-8')

          voters = []
          CSV.parse(utf8_encoded_content, col_sep: ';', headers: true, liberal_parsing: true) do |row|
            next if row.blank?
            next if row.header_row?

            voters << Voter.new( pesel: row[0]&.downcase, first_name: row[1]&.downcase, last_name: row[2]&.downcase)
          end
          Voter.import voters
        end

        def create_log(resource, log_type)
          Decidim::ActionLogger.log(
            log_type,
            current_user,
            resource,
            nil,
            { visibility: 'admin-only' }
          )
        end

        def remove_all_voters
          Decidim::Projects::Voter.delete_all
        end
      end
    end
  end
end
