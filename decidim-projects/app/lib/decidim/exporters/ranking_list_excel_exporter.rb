# frozen_string_literal: true

module Decidim
  module Exporters
    class RankingListExcelExporter < Excel

      def initialize(collection, serializer = Serializer, scope, budget_value, projects_total_budget_value, valid_cards_count)
        @collection = collection
        @serializer = serializer
        @scope = scope
        @budget_value = budget_value
        @projects_total_budget_value = projects_total_budget_value
        @valid_cards_count = valid_cards_count
      end

      def export
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet
        sheet.name = "Export"

        sheet.row(0).default_format = Spreadsheet::Format.new(
          weight: :bold,
          pattern: 1,
          pattern_fg_color: :xls_color_14,
          horizontal_align: :center
        )

        sheet.row(0).replace headers

        headers.length.times.each do |index|
          sheet.column(index).width = 20
        end

        format = Spreadsheet::Format.new :pattern_fg_color => :builtin_green,
                                         :pattern => 1

        processed_collection.each_with_index do |resource, index|
          sheet.row(index + 1).replace(headers.map { |header| custom_sanitize(resource[header]) })
          sheet.row(index + 1).default_format = format if resource['Czy jest na liście'] == 'Tak'
        end

        sheet.row(sheet.last_row_index + 2).push '', '', 'Kwota przeznaczona na realizację pomysłów', @budget_value
        sheet.row(sheet.last_row_index + 1).push '', '', 'Koszt wybranych pomysłów', @projects_total_budget_value
        sheet.row(sheet.last_row_index + 1).push '', '', 'Liczba kart ważnych', @valid_cards_count

        output = StringIO.new
        book.write output

        ExportData.new(output.string, "xls")
      end

    end
  end
end
